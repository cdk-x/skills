---
name: definition-of-done
description: >
  Create or update a GitHub Project item of type 'docs' as the team's living
  Definition of Done (DoD) reference checklist. This project item is consulted
  by /refine-story during NFR analysis to identify which non-functional
  requirements are already covered globally. Trigger when the user says
  "/definition-of-done", "create definition of done", "set up DoD", "update
  our definition of done", "what is our DoD", or any variation of managing the
  team's Definition of Done checklist.
---

# /definition-of-done — Definition of Done

Create or update the team's **Definition of Done** as a **GitHub Project item** (draft issue)
of type `docs`. This item serves as the team's shared reference — consulted during refinement
to determine which non-functional requirements are already covered globally and do not need
individual acceptance criteria on every story.

> **GitHub model:** Items created by this skill are **GitHub Project items** (draft issues).
> They live exclusively in the GitHub Project — there is no backing repository issue.
> Use `gh project item-create` to create them and GraphQL to update them.
> Never use `gh issue create`, `gh issue list`, `gh issue edit`, or `gh issue comment`.

## Step 0 — Resolve the GitHub Project

Resolve before any operation:

1. Check `AGENTS.md` and `CLAUDE.md` for a configured project name/number and owner.
2. If not found, list available projects and ask:
   ```bash
   gh project list --owner <org-or-user>
   ```

Read `references/github.md` for the exact commands.

---

## Step 1 — Check for an existing DoD item

Search for an existing DoD project item:

```bash
gh project item-list <project-number> --owner <org-or-user> --format json \
  | jq '.items[] | select(.title == "Definition of Done")'
```

- If one exists: show it to the user and ask:
  - _"A Definition of Done item already exists. Do you want to update it, view it, or create a new one?"_
  - **Update** → jump to Step 2 with the existing content pre-loaded; use `updateProjectV2DraftIssue`
  - **View** → print the item ID and stop
  - **Create new** → continue to Step 2 (the old item will remain; inform the user)
- If none exists: continue to Step 2.

---

## Step 2 — Compose the DoD checklist

Start from the base content in `docs/definition-of-done.md`. Present the full proposed checklist to the user:

```markdown
## Definition of Done

### Product Level
- [ ] All tests pass
  - [ ] Acceptance
  - [ ] Regression
  - [ ] Performance
  - [ ] Integration
- [ ] Code complete
  - [ ] Matches style guide
  - [ ] API documentation updated
  - [ ] Checked into dev branch
  - [ ] Unit tested
  - [ ] No known defects
- [ ] Documented
  - [ ] Release notes
  - [ ] User guide
  - [ ] Support guide
  - [ ] Compliance
- [ ] Integrated — merged in main with other teams
- [ ] Approved by Product Owner

### Team Level
- [ ] Unit test coverage > 80%
- [ ] No warnings
- [ ] Test-first approach followed
- [ ] Methods < 12 lines
- [ ] Lines < 80 characters
- [ ] Tool/board updated
- [ ] Reviewed with team
```

Ask the user:
- _"Does this checklist reflect your team's Definition of Done? Add, remove, or modify any items before we create the project item."_

Iterate until the user approves the checklist.

---

## Step 3 — Create or update the project item

Read `references/github.md` for the exact commands.

**If creating a new item:**
1. Create the project item with `gh project item-create`.
2. Set `Type = docs` on the item via `updateProjectV2ItemFieldValue`.

**If updating an existing item:**
1. Get the draft issue ID from the project item.
2. Update the body via `updateProjectV2DraftIssue`.

---

## Step 4 — Report

Tell the user:
- The project item ID of the created/updated item.
- That `/refine-story` will consult this item during NFR analysis to avoid writing acceptance criteria for requirements already covered globally.
- Suggest running `/definition-of-ready` next if the team's DoR has not been set up yet.

---

## Rules

- Do not create the item until the user approves the checklist in Step 2.
- The item title must be exactly `Definition of Done` — no suffixes.
- If the user asks to view the current DoD only, print the item ID and stop — do not propose changes.
- Non-functional requirements that appear in the DoD (e.g., "Unit test coverage > 80%") are considered globally covered — `/refine-story` will not generate individual ACs for them on each story.
