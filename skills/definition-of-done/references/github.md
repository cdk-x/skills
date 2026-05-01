# GitHub — Definition of Done docs issue

## Resolving the GitHub Project

Follow the same resolution order as `user-story`:
1. Check `AGENTS.md` and `CLAUDE.md` for a configured project name or number.
2. If not found, list projects and ask:
   ```bash
   gh project list --owner <org-or-user>
   ```

---

## Resolving project field IDs

Fetch the project's field metadata to get the `Type` field ID and the option ID for `docs`:

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

> If the project belongs to a user (not an org), replace `organization` with `user`.

Record:
- Project ID (`projectV2.id`)
- Type field ID + option ID for `docs`

---

## Creating the docs issue

```bash
ISSUE_URL=$(gh issue create \
  --title "Definition of Done" \
  --body "$(cat <<'EOF'
<checklist content approved by user>
EOF
)")
echo $ISSUE_URL
```

Extract the issue number from the URL: `${ISSUE_URL##*/}`

---

## Adding the issue to the project and setting Type = docs

### Step 1 — Get the issue node ID

```bash
gh issue view <number> --json id --jq '.id'
```

### Step 2 — Add to project

```bash
ITEM_ID=$(gh api graphql -f query='
mutation($project: ID!, $content: ID!) {
  addProjectV2ItemById(input: { projectId: $project, contentId: $content }) {
    item { id }
  }
}' -f project="<project-id>" -f content="<issue-node-id>" --jq '.data.addProjectV2ItemById.item.id')
```

### Step 3 — Set Type = docs

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

## Updating an existing issue

```bash
gh issue edit <number> --body "<updated checklist>"
gh issue comment <number> --body "DoD updated on <date>. Changes: <summary>."
```

---

## Searching for an existing DoD issue

```bash
gh issue list --search "Definition of Done in:title" --json number,title,url,state
```
