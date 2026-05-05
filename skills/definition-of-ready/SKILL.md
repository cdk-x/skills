---
name: definition-of-ready
description: >
  Create or update the team's Definition of Ready (DoR) as a Confluence page.
  This page defines the minimum criteria a user story must meet before entering
  a sprint, and is consulted by /refine-story during the DoR compliance check at
  the end of every refinement session. Trigger when the user says
  "/definition-of-ready", "create definition of ready", "set up DoR", "update
  our definition of ready", "what is our DoR", or any variation of managing the
  team's Definition of Ready checklist.
---

# /definition-of-ready — Definition of Ready

Create or update the team's **Definition of Ready** as a **Confluence page**.
This page defines the minimum criteria a user story must meet before it can be committed to a
sprint. It is consulted by `/refine-story` at the end of every refinement session to verify the
story qualifies for "Ready for Implementation".

Read `references/confluence.md` for the exact MCP calls used in each step.

---

## Step 0 — Resolve Confluence configuration

Before any operation, resolve the Confluence space and parent page:

1. Check `AGENTS.md` and `CLAUDE.md` for these keys:
   - `Confluence Space` or `Confluence Space Key` → space key (e.g. `TEAM`)
   - `Confluence Parent Page` or `Confluence Docs Page` → title of the parent page
2. If either is missing, call `mcp__atlassian__getConfluenceSpaces` to list available spaces
   and ask the user:
   - _"Which Confluence space should I use for the Definition of Ready?"_ (show list)
   - _"Is there a parent page it should live under? (e.g. 'Team Processes', 'Engineering Wiki')"_

Record the **space key** and **parent page title** (or `null` if publishing at root) — both
are used in every operation in this skill.

---

## Step 1 — Check for an existing DoR page

Search for an existing Definition of Ready page in the resolved space:

```
mcp__atlassian__searchConfluenceUsingCql {
  cql: "title = \"Definition of Ready\" AND space = \"<KEY>\" AND type = page"
}
```

- If one exists: show the page URL to the user and ask:
  - _"A Definition of Ready page already exists. Do you want to update it, view it, or create a new one?"_
  - **Update** → call `mcp__atlassian__getConfluencePage` to load the current content; jump to
    Step 2 with it pre-loaded
  - **View** → print the page URL and stop
  - **Create new** → continue to Step 2 (the old page remains; inform the user)
- If none exists: continue to Step 2.

---

## Step 2 — Compose the DoR checklist

Start from the base content in `docs/definition-of-ready.md`. Present the four minimum criteria
plus any team-specific additions:

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
- _"Do these criteria reflect your team's Definition of Ready? You can add team-specific criteria (e.g., 'has a technical spike completed', 'dependencies identified', 'designs approved') before we publish the page."_

Iterate until the user approves.

---

## Step 3 — Create or update the Confluence page

Read `references/confluence.md` for the exact MCP calls.

Convert the approved checklist from Markdown to HTML before publishing:
- `- [ ] item` → `<ul><li>item</li></ul>`
- `**bold**` → `<strong>bold</strong>`
- `###` → `<h3>`, `##` → `<h2>`

**If creating a new page:**
1. Resolve the parent page ID (if configured) by searching in the space.
2. Call `mcp__atlassian__createConfluencePage` with `spaceKey`, `title = "Definition of Ready"`,
   `content` (HTML), and `parentId` (if applicable).

**If updating an existing page:**
1. Read the current `version.number` from the page fetched in Step 1.
2. Call `mcp__atlassian__updateConfluencePage` with `pageId`, `title`, `content` (HTML),
   and `version: current + 1`.

---

## Step 4 — Report

Tell the user:
- The URL of the created/updated Confluence page.
- That `/refine-story` will check this page at the end of every refinement session before
  moving a story to "Ready for Implementation".
- Suggest running `/definition-of-done` next if the team's DoD has not been set up yet.

---

## Rules

- Do not publish the page until the user approves the checklist in Step 2.
- The page title must be exactly `Definition of Ready` — no suffixes.
- The four minimum criteria (Small, Sized, Just Enough Detail, Understood) are always included
  and cannot be removed — they are the non-negotiable baseline from Scrum.
- Team-specific criteria are additive only — they extend the minimum, never replace it.
- If the user asks to view the current DoR only, print the page URL and stop.
