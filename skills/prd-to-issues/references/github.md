# GitHub — Fetch PRD and Create Issues

## Fetching the PRD

```bash
gh issue view <number> --json title,body,labels,comments
```

The issue body is the PRD. Read it carefully — it contains user stories, functional requirements, and constraints. Comments may contain prior discussion or clarifications that affect scope.

---

## Creating Issues

Create each issue using `gh issue create`. Use this template for the body:

```
gh issue create \
  --title "<slice title>" \
  --body "$(cat <<'EOF'
## Parent PRD

#<prd-issue-number>

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent PRD rather than duplicating content.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- Blocked by #<issue-number>

Or "None — can start immediately" if no blockers.

## User stories addressed

Reference by number from the parent PRD:
- User story 1
- User story 3

EOF
)"
```

Create issues in **dependency order** (blockers first) so you can reference real issue numbers in the "Blocked by" field.

Do NOT close or modify the parent PRD issue.

---

## Reporting

After all issues are created, report the full list:
- Issue numbers and titles
- URLs (returned by `gh issue create`)
- Any blockers or dependencies noted
