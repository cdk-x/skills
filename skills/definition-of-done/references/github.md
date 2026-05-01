# GitHub — Definition of Done project item

Items created by this skill are **GitHub Project items** (draft issues). They live exclusively
in the GitHub Project — there is no backing repository issue. Never use `gh issue create`,
`gh issue edit`, `gh issue list`, or `gh issue comment` for these items.

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

## Searching for an existing DoD item

```bash
gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '.items[] | select(.title == "Definition of Done")'
```

Returns the project item's `id` (used for field mutations) if found.

---

## Creating the project item

```bash
ITEM_DATA=$(gh project item-create <project-number> \
  --owner <org-or-user> \
  --title "Definition of Done" \
  --body "$(cat <<'EOF'
<checklist content approved by user>
EOF
)" --format json)

ITEM_ID=$(echo "$ITEM_DATA" | jq -r '.id')
echo "Item ID: $ITEM_ID"
```

`ITEM_ID` is the project item node ID — use it for all field mutations below.

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

Draft issues require a different ID (the draft issue content ID, distinct from the project item ID).
First resolve it, then update.

### Step 1 — Get the draft issue ID from the project item

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

### Step 2 — Update title and/or body

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

> To update the title as well, add `-f title="<new title>"` to the mutation input.
