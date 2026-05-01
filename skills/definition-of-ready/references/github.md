# GitHub — Definition of Ready project item

Items created by this skill are **GitHub Project items** (draft issues). They live exclusively
in the GitHub Project — there is no backing repository issue. Never use `gh issue create`,
`gh issue edit`, `gh issue list`, or `gh issue comment` for these items.

The commands here are identical in structure to `definition-of-done/references/github.md` —
only the item title and content differ. Refer to that file for full GraphQL query details.

---

## Resolving the GitHub Project

Resolve before any operation:

1. Check `AGENTS.md` and `CLAUDE.md` for a configured project name/number and owner.
2. If not found, list available projects and ask:
   ```bash
   gh project list --owner <org-or-user>
   ```

Record the **project number** and **owner**.

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

## Searching for an existing DoR item

```bash
gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '.items[] | select(.title == "Definition of Ready")'
```

---

## Creating the project item

```bash
ITEM_DATA=$(gh project item-create <project-number> \
  --owner <org-or-user> \
  --title "Definition of Ready" \
  --body "$(cat <<'EOF'
<checklist content approved by user>
EOF
)" --format json)

ITEM_ID=$(echo "$ITEM_DATA" | jq -r '.id')
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

## Updating an existing item's body

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
}' -f id="$ITEM_ID" --jq '.data.node.content.id')
```

### Step 2 — Update body

```bash
gh api graphql -f query='
mutation($draftId: ID!, $body: String!) {
  updateProjectV2DraftIssue(input: {
    draftIssueId: $draftId
    body: $body
  }) {
    draftIssue { id }
  }
}' -f draftId="$DRAFT_ID" -f body="<updated checklist>"
```
