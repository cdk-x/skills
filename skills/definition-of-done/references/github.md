# GitHub — Definition of Done issue

Items created by this skill are **real GitHub Issues** in a private backing repository,
added to the GitHub Project. This keeps them invisible in any public repository while
giving full issue functionality (open/closed state, comments, sub-issues).

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
        }
      }
    }
  }
}' -f owner="<org-or-user>" -F number=<project-number>
```

> If the project belongs to a user (not an org), replace `organization` with `user`.

Record:
- Project ID (`projectV2.id`)
- Type field ID + option ID for `docs`

---

## Searching for an existing DoD issue

```bash
gh issue list \
  --repo <owner/repo> \
  --search "Definition of Done in:title" \
  --json number,title,url,state
```

---

## Creating the issue and adding it to the project

Two steps — create the issue in the private backing repository, then add it to the project:

```bash
# Step 1 — Create the issue in the private backing repository
ISSUE_URL=$(gh issue create \
  --repo <owner/repo> \
  --title "Definition of Done" \
  --body "$(cat <<'EOF'
<checklist content approved by user>
EOF
)")
ISSUE_NUMBER="${ISSUE_URL##*/}"

# Step 2 — Add to the project and capture the item ID
ITEM_ID=$(gh project item-add <project-number> \
  --owner <org-or-user> \
  --url "$ISSUE_URL" \
  --format json | jq -r '.id')
echo "Issue: $ISSUE_URL  |  Item ID: $ITEM_ID"
```

`ITEM_ID` is the project item node ID — use it for field mutations.
`ISSUE_NUMBER` is the issue number — use it for `gh issue edit` and `gh issue comment`.

---

## Setting Type = docs

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
  -f option="<docs-option-id>"
```

---

## Updating an existing issue's body

```bash
gh issue edit <number> \
  --repo <owner/repo> \
  --body "<updated checklist>"
```

To record the update, add a comment:

```bash
gh issue comment <number> \
  --repo <owner/repo> \
  --body "DoD updated on <date>. Changes: <brief summary>."
```
