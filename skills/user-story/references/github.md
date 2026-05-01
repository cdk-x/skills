# GitHub — Create User Story project items

Items created by this skill are **GitHub Project items** (draft issues). They live exclusively
in the GitHub Project — there is no backing repository issue. Never use `gh issue create`,
`gh issue edit`, or `gh issue list`. All operations go through `gh project` CLI or the GraphQL API.

---

## Fetching the PRD

### From a GitHub project item

If the PRD is itself a project item, fetch it via GraphQL:

```bash
gh api graphql -f query='
query($id: ID!) {
  node(id: $id) {
    ... on ProjectV2Item {
      content {
        ... on DraftIssue { title body }
      }
    }
  }
}' -f id="<prd-item-id>"
```

Or list project items and find it by title:

```bash
gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '.items[] | select(.title | test("<prd title>"; "i"))'
```

### From Confluence

Resolve the page ID from the URL (the numeric segment after `/pages/`):

```
https://your-org.atlassian.net/wiki/spaces/SPACE/pages/123456789/Page+Title
                                                          ^^^^^^^^^
```

If you only have a title, search for it:

```
mcp__atlassian__searchConfluenceUsingCql {
  cql: "title = \"<page title>\" AND type = page"
}
```

Then fetch the page content:

```
mcp__atlassian__getConfluencePage { pageId: "<id>" }
```

---

## Resolving the GitHub Project

Resolve before any operation:

1. Check `AGENTS.md` and `CLAUDE.md` for a configured project name/number and owner.
2. If not found, list available projects and ask:
   ```bash
   gh project list --owner <org-or-user>
   ```

Record the **project number** and **owner** — every command in this skill uses them.

---

## Resolving project field IDs

Fetch once per session. Record all field IDs and option IDs — reuse for every item created.

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

> If the project belongs to a user (not an org), replace `organization` with `user`.

Record these IDs — reuse them for every item created in this session:
- Project ID (`projectV2.id`)
- Type field ID + option IDs for `Epic` and `User Story`
- Size field ID + option IDs for `Small`, `Medium`, `Large`

---

## Creating a project item (Epic or User Story)

```bash
ITEM_DATA=$(gh project item-create <project-number> \
  --owner <org-or-user> \
  --title "<short descriptive title>" \
  --body "$(cat <<'EOF'
<template content, filled in from assets/user-story-template.md>
EOF
)" --format json)

ITEM_ID=$(echo "$ITEM_DATA" | jq -r '.id')
echo "Item ID: $ITEM_ID"
```

`ITEM_ID` is the project item node ID — use it for all field mutations.

---

## Setting the Type field

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
  -f item="$ITEM_ID" \
  -f field="<type-field-id>" \
  -f option="<epic-or-user-story-option-id>"
```

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
  -f item="$ITEM_ID" \
  -f field="<size-field-id>" \
  -f option="<small-medium-large-option-id>"
```

> Risk and Estimate are intentionally left unset at creation time — they are determined during
> the refinement sessions on the Discovery Board.

---

## Linking child stories to their parent Epic

GitHub sub-issues require repository-backed issues and are not applicable to project draft items.
Track the Epic-Story relationship by including a reference in each child story's body:

```markdown
**Parent Epic:** <Epic title> (project item <ITEM_ID>)
```

And include the list of child stories in the Epic's body:

```markdown
**Child Stories:**
- <Story title> (project item <ITEM_ID>)
- <Story title> (project item <ITEM_ID>)
```

---

## Linking stories to the source PRD

Since draft items have no repository backing, cross-references via `#N` are not available.
Include the PRD reference directly in the story body:

```markdown
**Derived from PRD:** <PRD title> (project item <PRD_ITEM_ID>)
```

---

## Reporting format

```
Epics:
  <ITEM_ID> — <Epic title>  [Type: Epic]

User stories:
  <ITEM_ID> — <short title>  [Type: User Story | Size: Medium]  (child of <Epic ITEM_ID>)
  <ITEM_ID> — <short title>  [Type: User Story | Size: Small]   (child of <Epic ITEM_ID>)
  <ITEM_ID> — <short title>  [Type: User Story | Size: Small]   (standalone)
```
