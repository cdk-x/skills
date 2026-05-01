# GitHub — Create User Story issues

Items created by this skill are **real GitHub Issues** in a private backing repository,
added to the GitHub Project. This keeps project management details invisible in any public
repository while giving full issue functionality (open/closed state, comments, sub-issues).

---

## Fetching the PRD

### From a GitHub issue

```bash
gh issue view <number> --repo <owner/repo> --json title,body,comments
```

Read comments too — they may contain clarifications that affect scope.

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

## Resolving the GitHub Project and backing repository

Resolve both before any operation:

1. Check `AGENTS.md` and `CLAUDE.md` for:
   - Project number/name and owner (keys like `GitHub Project`, `project number`)
   - Private backing repository (keys like `GitHub Repository`, `backing repo`, `project repo`)
2. If not found, list available projects and ask:
   ```bash
   gh project list --owner <org-or-user> --format json | jq '.projects[] | select(.number==<project_id>)'
   ```

Record the **project number**, **owner**, and **backing repository** (`<owner/repo>`) —
all three are used in every command in this skill.

---

## Resolving project field IDs

Fetch once per session. Record all field IDs and option IDs — reuse for every issue created.

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

Record:
- Project ID (`projectV2.id`)
- Type field ID + option IDs for `Epic` and `User Story`
- Size field ID + option IDs for `Small`, `Medium`, `Large`

---

## Creating an issue and adding it to the project

```bash
# Step 1 — Create the issue in the private backing repository
ISSUE_URL=$(gh issue create \
  --repo <owner/repo> \
  --title "<short descriptive title>" \
  --body "$(cat <<'EOF'
<template content, filled in from assets/user-story-template.md>
EOF
)")
ISSUE_NUMBER="${ISSUE_URL##*/}"

# Step 2 — Add to the project
ITEM_ID=$(gh project item-add <project-number> \
  --owner <org-or-user> \
  --url "$ISSUE_URL" \
  --format json | jq -r '.id')
echo "Issue #$ISSUE_NUMBER  |  Item ID: $ITEM_ID"
```

`ITEM_ID` — use for field mutations via GraphQL.
`ISSUE_NUMBER` — use for `gh issue edit`, `gh issue comment`, sub-issue attachment.

> Risk and Estimate are intentionally left unset at creation time — they are determined
> during refinement sessions on the Discovery Board.

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

---

## Attaching child stories as sub-issues to an Epic

Use the GraphQL `addSubIssue` mutation. You need the node IDs of both issues:

```bash
# Get node IDs
EPIC_NODE_ID=$(gh issue view <epic-number> --repo <owner/repo> --json id --jq '.id')
STORY_NODE_ID=$(gh issue view <story-number> --repo <owner/repo> --json id --jq '.id')

# Attach
gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "<epic-node-id>"
    subIssueId: "<story-node-id>"
  }) {
    issue { number title }
    subIssue { number title }
  }
}'
```

Repeat for each child story.

---

## Linking stories to the source PRD

Add a comment to each story referencing the PRD issue:

```bash
gh issue comment <story_number> \
  --repo <owner/repo> \
  --body "Derived from PRD #<prd_number>."
```

---

## Reporting format

```
Epics:
  #12 — <Epic title>  [Type: Epic]  →  <url>

User stories:
  #13 — <short title>  [Type: User Story | Size: Medium]  →  <url>  (sub-issue of #12)
  #14 — <short title>  [Type: User Story | Size: Small]   →  <url>  (sub-issue of #12)
  #15 — <short title>  [Type: User Story | Size: Small]   →  <url>  (standalone)
```
