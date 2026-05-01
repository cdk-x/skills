# GitHub — Definition of Ready issue

Items created by this skill are **real GitHub Issues** in a private backing repository,
added to the GitHub Project. This keeps them invisible in any public repository while
giving full issue functionality (open/closed state, comments, sub-issues).

The commands here follow the same pattern as `definition-of-done/references/github.md` —
only the issue title and content differ.

---

## Resolving the GitHub Project and backing repository

Resolve both before any operation:

1. Check `AGENTS.md` and `CLAUDE.md` for:
   - Project number/name and owner
   - Private backing repository (keys like `GitHub Repository`, `backing repo`, `project repo`)
2. If not found, list available projects and ask:
   ```bash
   gh project list --owner <org-or-user> --format json | jq '.projects[] | select(.number==<project_id>)'
   ```

Record the **project number**, **owner**, and **backing repository** (`<owner/repo>`).

---

## Resolving project field IDs

```bash
gh api graphql -f query='
query($owner: String!, $number: Int!) {
  organization(login: $owner) {
    projectV2(number: $number) {
      id
      fields(first: 30) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options { id name }
          }
        }
      }
    }
  }
}' -f owner="<org-or-user>" -F number=<project-number>
```

Record:
- Project ID
- Type field ID + option ID for `docs`

---

## Searching for an existing DoR issue

```bash
gh issue list \
  --repo <owner/repo> \
  --search "Definition of Ready in:title" \
  --json number,title,url,state
```

---

## Creating the issue and adding it to the project

```bash
# Step 1 — Create the issue in the private backing repository
ISSUE_URL=$(gh issue create \
  --repo <owner/repo> \
  --title "Definition of Ready" \
  --body "$(cat <<'EOF'
<checklist content approved by user>
EOF
)")
ISSUE_NUMBER="${ISSUE_URL##*/}"

# Step 2 — Add to the project
ITEM_ID=$(gh project item-add <project-number> \
  --owner <org-or-user> \
  --url "$ISSUE_URL" \
  --format json | jq -r '.id')
```

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
  --body "DoR updated on <date>. Changes: <brief summary>."
```
