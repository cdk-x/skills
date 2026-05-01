---
name: definition-of-done
description: >
  Create or update a GitHub Issue of type 'docs' in the project as the team's
  living Definition of Done (DoD) reference checklist. This docs issue is
  consulted by /refine-story during NFR analysis to identify which non-functional
  requirements are already covered globally. Trigger when the user says
  "/definition-of-done", "create definition of done", "set up DoD", "update
  our definition of done", "what is our DoD", or any variation of managing the
  team's Definition of Done checklist.
---

# /definition-of-done — Definition of Done

Create or update the team's **Definition of Done** as a GitHub Issue of type `docs` in the project. This issue serves as the team's shared reference — consulted during refinement to determine which non-functional requirements are already covered globally and do not need individual acceptance criteria on every story.

## Step 0 — Check for an existing DoD issue

Search the repo for an existing DoD docs issue:

```bash
gh issue list --search "Definition of Done in:title" --json number,title,url,state
```

- If one exists (open or closed): show it to the user and ask:
  - _"A Definition of Done issue already exists (#N). Do you want to update it, view it, or create a new one?"_
  - **Update** → jump to Step 1 with the existing content pre-loaded
  - **View** → print the URL and stop
  - **Create new** → continue to Step 1 (the old issue will remain open; inform the user)
- If none exists: continue to Step 1.

---

## Step 1 — Compose the DoD checklist

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
- _"Does this checklist reflect your team's Definition of Done? Add, remove, or modify any items before we create the issue."_

Iterate until the user approves the checklist.

---

## Step 2 — Create or update the GitHub Issue

Resolve which GitHub Project to use following the same approach as `user-story` (check `AGENTS.md` / `CLAUDE.md`, or ask once).

Read `references/github.md` for the exact commands.

**If creating a new issue:**
1. Create the issue with title `Definition of Done` and the approved checklist as the body.
2. Add the issue to the GitHub Project.
3. Set `Type = docs`.

**If updating an existing issue:**
1. Edit the issue body with the updated checklist:
   ```bash
   gh issue edit <number> --body "<updated content>"
   ```
2. Add a comment noting the update:
   ```
   DoD updated on <date>. Changes: <brief summary of what changed>.
   ```

---

## Step 3 — Report

Tell the user:
- The URL of the created/updated issue.
- That `/refine-story` will consult this issue during NFR analysis to avoid writing acceptance criteria for requirements already covered globally.
- Suggest running `/definition-of-ready` next if the team's DoR has not been set up yet.

---

## Rules

- Do not create the issue until the user approves the checklist in Step 1.
- The issue title must be exactly `Definition of Done` — no suffixes.
- If the user asks to view the current DoD only, print the issue URL and stop — do not propose changes.
- Non-functional requirements that appear in the DoD (e.g., "Unit test coverage > 80%") are considered globally covered — `/refine-story` will not generate individual ACs for them on each story.
