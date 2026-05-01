# GitHub — Refine Story

## Fetching the story and its context

### Story body and comments

```bash
gh issue view <number> --json number,title,body,comments,url
```

Read all comments — they may contain prior discussion, decisions, or constraints that affect the refinement.

### Finding the source PRD

Search comments for the derivation link added by `/user-story`:

```bash
gh issue view <number> --json comments --jq '.comments[].body' | grep "Derived from PRD"
```

If found, fetch the PRD:

```bash
gh issue view <prd_number> --json title,body
```

### Finding the parent Epic

```bash
gh issue view <number> --json parent --jq '.parent.number // empty'
```

If a parent Epic exists, fetch its Success Criteria:

```bash
gh issue view <epic_number> --json title,body
```

---

## Listing stories available for refinement

```bash
gh issue list --json number,title,url \
  --search "is:open" \
  | jq '.[]'
```

To filter by project status field (requires knowing the project number):

```bash
gh api graphql -f query='
query($owner: String!, $number: Int!) {
  organization(login: $owner) {
    projectV2(number: $number) {
      items(first: 50) {
        nodes {
          content {
            ... on Issue { number title url }
          }
          fieldValues(first: 20) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                field { ... on ProjectV2SingleSelectField { name } }
              }
            }
          }
        }
      }
    }
  }
}' -f owner="<org-or-user>" -F number=<project-number> \
| jq '[.data.organization.projectV2.items.nodes[] | select(.fieldValues.nodes[] | select(.field.name == "Status" and .name == "Ready for Refinement"))]'
```

---

## Resolving project field IDs

Fetch once per session. Record all field IDs and option IDs — reuse for every mutation.

```bash
gh api graphql -f query='
query($owner: String!, $number: Int!) {
  organization(login: $owner) {
    projectV2(number: $number) {
      id
      fields(first: 30) {
        nodes {
          ... on ProjectV2Field {
            id
            name
          }
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
          ... on ProjectV2IterationField {
            id
            name
          }
        }
      }
    }
  }
}' -f owner="<org-or-user>" -F number=<project-number>
```

Fields needed for this skill:
- **Status** field ID + option IDs for: `In Refinement`, `Ready for Implementation`
- **Risk** field ID + option IDs for: `Low`, `Medium`, `High`
- **Estimate** field ID (numeric or single-select, depending on project config)
- **Size** field ID + option IDs for: `Small`, `Medium`, `Large`
- **Value** field ID (numeric or single-select, depending on project config)

---

## Setting the Status field

```bash
gh api graphql -f query='
mutation($project: ID!, $item: ID!, $field: ID!, $option: String!) {
  updateProjectV2ItemFieldValue(input: {
    projectId: $project
    itemId: $item
    fieldId: $field
    value: { singleSelectOptionId: $option }
  }) {
    projectV2Item { id }
  }
}' \
  -f project="<project-id>" \
  -f item="<item-id>" \
  -f field="<status-field-id>" \
  -f option="<in-refinement-option-id>"
```

Replace `<in-refinement-option-id>` with `<ready-for-implementation-option-id>` for the final transition.

---

## Setting the Size field (single-select)

```bash
gh api graphql -f query='
mutation($project: ID!, $item: ID!, $field: ID!, $option: String!) {
  updateProjectV2ItemFieldValue(input: {
    projectId: $project
    itemId: $item
    fieldId: $field
    value: { singleSelectOptionId: $option }
  }) {
    projectV2Item { id }
  }
}' \
  -f project="<project-id>" \
  -f item="<item-id>" \
  -f field="<size-field-id>" \
  -f option="<XS|S|M|L|XL-option-id>"
```

---

## Setting the Risk field (text: L / M / H)

Risk is a **text** field — use `{ text: "..." }`, not `singleSelectOptionId`:

```bash
gh api graphql -f query='
mutation($project: ID!, $item: ID!, $field: ID!, $value: String!) {
  updateProjectV2ItemFieldValue(input: {
    projectId: $project
    itemId: $item
    fieldId: $field
    value: { text: $value }
  }) {
    projectV2Item { id }
  }
}' \
  -f project="<project-id>" \
  -f item="<item-id>" \
  -f field="<risk-field-id>" \
  -f value="L"   # or "M" or "H"
```

---

## Setting numeric fields (Estimate, Value)

Use this pattern for fields that store a number:

```bash
gh api graphql -f query='
mutation($project: ID!, $item: ID!, $field: ID!, $value: Float!) {
  updateProjectV2ItemFieldValue(input: {
    projectId: $project
    itemId: $item
    fieldId: $field
    value: { number: $value }
  }) {
    projectV2Item { id }
  }
}' \
  -f project="<project-id>" \
  -f item="<item-id>" \
  -f field="<field-id>" \
  -F value=<number>
```

- **Estimate**: Fibonacci value (1, 2, 3, 5, 8, 13)
- **Value**: business value as configured in the project

> If Estimate or Value is a SingleSelect field instead of numeric, use `singleSelectOptionId` and fetch option IDs from the field metadata query.

---

## Getting the project item ID for an issue

```bash
# Get issue node ID
NODE_ID=$(gh issue view <number> --json id --jq '.id')

# Add to project (or get existing item ID)
ITEM_ID=$(gh api graphql -f query='
mutation($project: ID!, $content: ID!) {
  addProjectV2ItemById(input: { projectId: $project, contentId: $content }) {
    item { id }
  }
}' -f project="<project-id>" -f content="$NODE_ID" --jq '.data.addProjectV2ItemById.item.id')
```

If the issue is already in the project, this mutation returns the existing item ID without duplicating.

---

## Updating the issue body

```bash
gh issue edit <number> --body "$(cat <<'EOF'
<refined body content from template>
EOF
)"
```

---

## Adding the refinement session comment

```bash
gh issue comment <number> --body "$(cat <<'EOF'
## Refinement Session — <date>

**Risk**: <Low | Medium | High> | **Estimate**: <N> pts

**Functional Requirements identified**: <FR-1, FR-2, ...>
**Non-Functional Requirements**:
- <NFR description> → <AC added | Covered by DoD>

**Decisions**: <key decisions made during the session>
**Open questions**: <unresolved questions, or "None">
EOF
)"
```

---

## Searching for the DoD and DoR docs issues

```bash
gh issue list --search "Definition of Done in:title" --json number,title,url,state --limit 1
gh issue list --search "Definition of Ready in:title" --json number,title,url,state --limit 1
```
