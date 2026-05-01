---
name: definition-of-ready
description: >
  Create or update a GitHub Issue of type 'docs' in the project as the team's
  living Definition of Ready (DoR) reference checklist. This docs issue defines
  the minimum criteria a user story must meet before entering a sprint, and is
  consulted by /refine-story during the DoR compliance check at the end of every
  refinement session. Trigger when the user says "/definition-of-ready", "create
  definition of ready", "set up DoR", "update our definition of ready", "what is
  our DoR", or any variation of managing the team's Definition of Ready checklist.
---

# /definition-of-ready — Definition of Ready

Create or update the team's **Definition of Ready** as a GitHub Issue of type `docs` in the project. This issue defines the minimum criteria a user story must meet before it can be committed to a sprint. It is consulted by `/refine-story` at the end of every refinement session to verify the story qualifies for "Ready for Implementation".

## Step 0 — Check for an existing DoR issue

Search the repo for an existing DoR docs issue:

```bash
gh issue list --search "Definition of Ready in:title" --json number,title,url,state
```

- If one exists: show it to the user and ask:
  - _"A Definition of Ready issue already exists (#N). Do you want to update it, view it, or create a new one?"_
  - **Update** → jump to Step 1 with the existing content pre-loaded
  - **View** → print the URL and stop
  - **Create new** → continue to Step 1 (inform the user the old issue will remain)
- If none exists: continue to Step 1.

---

## Step 1 — Compose the DoR checklist

Start from the base content in `docs/definition-of-ready.md`. Present the four minimum criteria plus any team-specific additions:

```markdown
## Definition of Ready

A Product Backlog item is Ready for a Sprint when it meets all of the following criteria:

### Minimum Criteria (non-negotiable)
- [ ] **Small** — can be completed by one developer within a single sprint
- [ ] **Sized** — has a relative effort estimate (Fibonacci: 1, 2, 3, 5, 8, 13...)
- [ ] **Just Enough Detail** — has acceptance criteria (Given/When/Then) sufficient to confirm the item functions as intended
- [ ] **Understood** — the Development Team has enough shared understanding to make a forecast in Sprint Planning

### Team-specific Criteria (optional additions)
<!-- Add any criteria specific to your team here -->
```

Ask the user:
- _"Do these criteria reflect your team's Definition of Ready? You can add team-specific criteria (e.g., 'has a technical spike completed', 'dependencies identified', 'designs approved') before we create the issue."_

Iterate until the user approves.

---

## Step 2 — Create or update the GitHub Issue

Resolve which GitHub Project to use following the same approach as `user-story` (check `AGENTS.md` / `CLAUDE.md`, or ask once).

Read `references/github.md` for the exact commands.

**If creating a new issue:**
1. Create the issue with title `Definition of Ready` and the approved checklist as the body.
2. Add the issue to the GitHub Project.
3. Set `Type = docs`.

**If updating an existing issue:**
1. Edit the issue body with the updated checklist:
   ```bash
   gh issue edit <number> --body "<updated content>"
   ```
2. Add a comment noting the update:
   ```
   DoR updated on <date>. Changes: <brief summary of what changed>.
   ```

---

## Step 3 — Report

Tell the user:
- The URL of the created/updated issue.
- That `/refine-story` will check this issue at the end of every refinement session before moving a story to "Ready for Implementation".
- Suggest running `/definition-of-done` next if the team's DoD has not been set up yet.

---

## Rules

- Do not create the issue until the user approves the checklist in Step 1.
- The issue title must be exactly `Definition of Ready` — no suffixes.
- The four minimum criteria (Small, Sized, Just Enough Detail, Understood) are always included and cannot be removed — they are the non-negotiable baseline from Scrum.
- Team-specific criteria are additive only — they extend the minimum, never replace it.
- If the user asks to view the current DoR only, print the issue URL and stop.
