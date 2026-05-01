# GitHub — Fetch PRD and Create User Story Issues

## Fetching the PRD

### From a GitHub issue

```bash
gh issue view <number> --json title,body,labels,comments
```

The issue body is the PRD. Read comments too — they may contain clarifications that affect scope.

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

Issues must be added to a GitHub Project so that custom fields (Type, Size, Risk, Estimate) can be set.

Resolve the project in this order:
1. Read `AGENTS.md` and `CLAUDE.md` in the current repo — look for a configured project name or number (keys like `GitHub Project`, `project`, `project number`, etc.)
2. If not found, list available projects and ask the user:

```bash
gh project list --owner <org-or-user>
```

---

## Resolving project field IDs

Before creating any issues, fetch the project's field metadata. You need the IDs of the `Type` and `Size` fields, and the option IDs for each value (e.g. "Epic", "User Story", "Small", "Medium", "Large").

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

> If the project belongs to a user (not an org), replace `organization` with `user` in the query.

Record these IDs — you will reuse them for every issue created in this session:
- Project ID (`projectV2.id`)
- Type field ID + option IDs for "Epic" and "User Story"
- Size field ID + option IDs for "Small", "Medium", "Large"

---

## Creating an issue

The `--title` must be a **short, descriptive noun phrase** — never the "As a..." sentence.
The full user story sentence goes in the body (see `assets/user-story-template.md`).

```bash
ISSUE_URL=$(gh issue create \
  --title "<short descriptive title>" \
  --body "$(cat <<'EOF'
<template content, filled in>
EOF
)")
echo $ISSUE_URL
```

Extract the issue number from the URL (`${ISSUE_URL##*/}`).

---

## Adding the issue to the project and setting fields

### Step 1 — Add the issue to the project

```bash
ITEM_ID=$(gh api graphql -f query='
mutation($project: ID!, $content: ID!) {
  addProjectV2ItemById(input: { projectId: $project, contentId: $content }) {
    item { id }
  }
}' -f project="<project-id>" -f content="<issue-node-id>" --jq '.data.addProjectV2ItemById.item.id')
```

To get the issue node ID:
```bash
gh issue view <number> --json id --jq '.id'
```

### Step 2 — Set the Type field

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

### Step 3 — Set the Size field

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

> Risk and Estimate are intentionally left unset at creation time — they are determined during the refinement sessions on the Discovery Board.

---

## Attaching user stories as sub-issues to an Epic

Use the GraphQL `addSubIssue` mutation — the REST endpoint is not reliable. You need the node IDs of both issues (fetch them with `gh issue view <number> --repo <owner/repo> --json id --jq '.id'`).

```bash
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

Add a comment to each story referencing the PRD issue. GitHub will create a "mentioned in" back-link on the PRD automatically — no manual text needed in the story body.

```bash
gh issue comment <story_number> --body "Derived from PRD #<prd_number>."
```

---

## Reporting format

```
Epics:
  #12 — <Epic title>  [Type: Epic]  →  <url>

User stories:
  #13 — As a <actor>, I want <feature>  [Type: User Story | Size: Medium]  →  <url>  (sub-issue of #12)
  #14 — As a <actor>, I want <feature>  [Type: User Story | Size: Small]   →  <url>  (sub-issue of #12)
  #15 — As a <actor>, I want <feature>  [Type: User Story | Size: Small]   →  <url>  (standalone)
```
