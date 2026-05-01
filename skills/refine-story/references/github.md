# GitHub — Refine Story

Stories operated on by this skill are **GitHub Project items** (draft issues). They have no
backing repository issue. Never use `gh issue view`, `gh issue edit`, or `gh issue comment`.
All reads and writes go through `gh project` CLI or the GraphQL API.

---

## Resolving the GitHub Project

Check `AGENTS.md` / `CLAUDE.md` for a configured project name/number and owner, or ask once:

```bash
gh project list --owner <org-or-user>
```

Record the **project number**, **owner**, and **project node ID** — reused in every mutation.

---

## Resolving project field IDs

Fetch once per session. Record all field IDs and option IDs.

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
- **Risk** field ID (text field: `L`, `M`, or `H`)
- **Estimate** field ID (numeric: Fibonacci value)
- **Size** field ID + option IDs for: `Small`, `Medium`, `Large`
- **Value** field ID (numeric or single-select, depending on project config)

---

## Listing stories available for refinement

```bash
gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '[.items[] | select(.status == "Ready for Refinement")]'
```

To filter by status via GraphQL (more precise):

```bash
gh api graphql -f query='
query($owner: String!, $number: Int!) {
  organization(login: $owner) {
    projectV2(number: $number) {
      items(first: 50) {
        nodes {
          id
          content {
            ... on DraftIssue { title body }
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

## Fetching a project item's full content

```bash
gh api graphql -f query='
query($id: ID!) {
  node(id: $id) {
    ... on ProjectV2Item {
      id
      content {
        ... on DraftIssue {
          id
          title
          body
        }
      }
      fieldValues(first: 20) {
        nodes {
          ... on ProjectV2ItemFieldSingleSelectValue {
            name
            field { ... on ProjectV2SingleSelectField { name } }
          }
          ... on ProjectV2ItemFieldNumberValue {
            number
            field { ... on ProjectV2Field { name } }
          }
          ... on ProjectV2ItemFieldTextValue {
            text
            field { ... on ProjectV2Field { name } }
          }
        }
      }
    }
  }
}' -f id="<project-item-id>"
```

This returns both:
- `content.id` — the **Draft Issue ID** (used in `updateProjectV2DraftIssue`)
- `id` — the **Project Item ID** (used in `updateProjectV2ItemFieldValue`)

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
  -f item="<project-item-id>" \
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
  -f item="<project-item-id>" \
  -f field="<size-field-id>" \
  -f option="<S|M|L-option-id>"
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
  -f item="<project-item-id>" \
  -f field="<risk-field-id>" \
  -f value="M"   # or "L" or "H"
```

---

## Setting numeric fields (Estimate, Value)

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
  -f item="<project-item-id>" \
  -f field="<field-id>" \
  -F value=<number>
```

- **Estimate**: Fibonacci value (1, 2, 3, 5, 8, 13)
- **Value**: business value as configured in the project

> If Estimate or Value is a SingleSelect field instead of numeric, use `singleSelectOptionId`.

---

## Updating the story body (rewrite after refinement)

Draft items do not support comments. All session context (refinement notes, decisions, open
questions) must be incorporated into the item body itself.

### Step 1 — Get the draft issue ID

```bash
DRAFT_ID=$(gh api graphql -f query='
query($id: ID!) {
  node(id: $id) {
    ... on ProjectV2Item {
      content {
        ... on DraftIssue { id }
      }
    }
  }
}' -f id="<project-item-id>" --jq '.data.node.content.id')
```

### Step 2 — Rewrite the body

```bash
gh api graphql -f query='
mutation($draftId: ID!, $body: String!) {
  updateProjectV2DraftIssue(input: {
    draftIssueId: $draftId
    body: $body
  }) {
    draftIssue { id }
  }
}' -f draftId="$DRAFT_ID" -f body="$(cat <<'EOF'
<full refined body from assets/refined-story-template.md>

---

## Refinement Session — <date>

**Functional Requirements identified**: FR-1, FR-2, ...
**Non-Functional Requirements**: <description, or "None story-specific">

**Decisions**: <key decisions>
**Open questions**: <unresolved questions, or "None">
EOF
)"
```

The refinement session block is **appended inside the body** (after a `---` separator) because
draft issues do not support comments.

---

## Searching for the DoD and DoR project items

```bash
gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '.items[] | select(.title == "Definition of Done")'

gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '.items[] | select(.title == "Definition of Ready")'
```
