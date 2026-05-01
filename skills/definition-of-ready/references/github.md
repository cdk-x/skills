# GitHub — Definition of Ready docs issue

The commands here are identical to those in `definition-of-done/references/github.md` — only the issue title and content differ. Refer to that file for full GraphQL query details.

## Resolving the GitHub Project

```bash
gh project list --owner <org-or-user>
```

Check `AGENTS.md` / `CLAUDE.md` first for a configured project name or number.

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

Record:
- Project ID
- Type field ID + option ID for `docs`

---

## Creating the docs issue

```bash
ISSUE_URL=$(gh issue create \
  --title "Definition of Ready" \
  --body "$(cat <<'EOF'
<checklist content approved by user>
EOF
)")
echo $ISSUE_URL
```

---

## Adding to project and setting Type = docs

```bash
# Get node ID
gh issue view <number> --json id --jq '.id'

# Add to project
ITEM_ID=$(gh api graphql -f query='
mutation($project: ID!, $content: ID!) {
  addProjectV2ItemById(input: { projectId: $project, contentId: $content }) {
    item { id }
  }
}' -f project="<project-id>" -f content="<issue-node-id>" --jq '.data.addProjectV2ItemById.item.id')

# Set Type = docs
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

## Updating an existing issue

```bash
gh issue edit <number> --body "<updated checklist>"
gh issue comment <number> --body "DoR updated on <date>. Changes: <summary>."
```

---

## Searching for an existing DoR issue

```bash
gh issue list --search "Definition of Ready in:title" --json number,title,url,state
```
