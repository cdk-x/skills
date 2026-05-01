# GitHub — Refine Story

Stories on the Discovery Board are **real GitHub Issues** in a private backing repository,
tracked via the GitHub Project. Use standard `gh issue` commands (with `--repo`) for all
content operations, and GraphQL for project field mutations.

---

## Resolving the GitHub Project and backing repository

Check `AGENTS.md` / `CLAUDE.md` for:
- Project number/name and owner
- Private backing repository (keys like `GitHub Repository`, `backing repo`, `project repo`)

If not found, list and ask:

```bash
gh project list --owner <org-or-user> --format json | jq '.projects[] | select(.number==<project_id>)'
```

Record the **project number**, **owner**, **project node ID**, and **backing repository** —
reused in every command.

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

Filter by `Status = Ready for Refinement` via GraphQL:

```bash
gh api graphql -f query='
query($owner: String!, $number: Int!) {
  organization(login: $owner) {
    projectV2(number: $number) {
      items(first: 50) {
        nodes {
          id
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

## Fetching a story's full content

```bash
gh issue view <number> \
  --repo <owner/repo> \
  --json number,title,body,comments,url,parent
```

Read all comments — they may contain prior refinement decisions or open questions.

---

## Getting the project item ID for an issue

Needed for field mutations. Add the issue to the project (idempotent — returns existing item if already there):

```bash
ITEM_ID=$(gh api graphql -f query='
mutation($project: ID!, $content: ID!) {
  addProjectV2ItemById(input: { projectId: $project, contentId: $content }) {
    item { id }
  }
}' -f project="<project-id>" \
   -f content="$(gh issue view <number> --repo <owner/repo> --json id --jq '.id')" \
   --jq '.data.addProjectV2ItemById.item.id')
```

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

Replace with `<ready-for-implementation-option-id>` for the final transition.

---

## Setting the Size field

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
  -f option="<S|M|L-option-id>"
```

---

## Setting the Risk field (text: L / M / H)

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
  -f value="M"
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
  -f item="<item-id>" \
  -f field="<field-id>" \
  -F value=<number>
```

---

## Updating the story body after refinement

```bash
gh issue edit <number> \
  --repo <owner/repo> \
  --body "$(cat <<'EOF'
<full refined body from assets/refined-story-template.md>
EOF
)"
```

---

## Adding the refinement session comment

```bash
gh issue comment <number> \
  --repo <owner/repo> \
  --body "$(cat <<'EOF'
## Refinement Session — <date>

**Functional Requirements identified**: FR-1, FR-2, ...
**Non-Functional Requirements**: <description, or "None story-specific">

**Decisions**: <key decisions made during the session>
**Open questions**: <unresolved questions, or "None">
EOF
)"
```

---

## Searching for the DoD and DoR issues

```bash
gh issue list --repo <owner/repo> \
  --search "Definition of Done in:title" \
  --json number,title,url,state --limit 1

gh issue list --repo <owner/repo> \
  --search "Definition of Ready in:title" \
  --json number,title,url,state --limit 1
```
