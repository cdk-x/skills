---
name: definition-of-done
description: >
  Create or update the team's Definition of Done (DoD) as a Confluence page.
  This page is consulted by /refine-story during NFR analysis to identify which
  non-functional requirements are already covered globally. Trigger when the user
  says "/definition-of-done", "create definition of done", "set up DoD", "update
  our definition of done", "what is our DoD", or any variation of managing the
  team's Definition of Done checklist.
---

# /definition-of-done — Definition of Done

Create or update the team's **Definition of Done** as a **Confluence page**.
This page serves as the team's shared reference — consulted during refinement to determine
which non-functional requirements are already covered globally and do not need individual
acceptance criteria on every story.

Read `references/confluence.md` for the exact MCP calls used in each step.

---

## Step 0 — Resolve Confluence configuration

Before any operation, resolve the Confluence space and parent page:

1. Check `AGENTS.md` and `CLAUDE.md` for these keys:
   - `Confluence Space` or `Confluence Space Key` → space key (e.g. `TEAM`)
   - `Confluence Parent Page` or `Confluence Docs Page` → title of the parent page
2. If either is missing, call `mcp__atlassian__getConfluenceSpaces` to list available spaces
   and ask the user:
   - _"Which Confluence space should I use for the Definition of Done?"_ (show list)
   - _"Is there a parent page it should live under? (e.g. 'Team Processes', 'Engineering Wiki')"_

Record the **space key** and **parent page title** (or `null` if publishing at root) — both
are used in every operation in this skill.

---

## Step 1 — Check for an existing DoD page

Search for an existing Definition of Done page in the resolved space:

```
mcp__atlassian__searchConfluenceUsingCql {
  cql: "title = \"Definition of Done\" AND space = \"<KEY>\" AND type = page"
}
```

- If one exists: show the page URL to the user and ask:
  - _"A Definition of Done page already exists. Do you want to update it, view it, or create a new one?"_
  - **Update** → call `mcp__atlassian__getConfluencePage` to load the current content; jump to
    Step 2 with it pre-loaded
  - **View** → print the page URL and stop
  - **Create new** → continue to Step 2 (the old page remains; inform the user)
- If none exists: continue to Step 2.

---

## Step 2 — Compose the DoD checklist

Start from the base content in `docs/definition-of-done.md`. Present the full proposed checklist
to the user:

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
- _"Does this checklist reflect your team's Definition of Done? Add, remove, or modify any items before we publish the page."_

Iterate until the user approves the checklist.

---

## Step 3 — Create or update the Confluence page

Read `references/confluence.md` for the exact MCP calls.

Convert the approved checklist from Markdown to HTML before publishing:
- `- [ ] item` → `<ul><li>item</li></ul>`
- `**bold**` → `<strong>bold</strong>`
- `###` → `<h3>`, `##` → `<h2>`

**If creating a new page:**
1. Resolve the parent page ID (if configured) by searching in the space.
2. Call `mcp__atlassian__createConfluencePage` with `spaceKey`, `title = "Definition of Done"`,
   `content` (HTML), and `parentId` (if applicable).

**If updating an existing page:**
1. Read the current `version.number` from the page fetched in Step 1.
2. Call `mcp__atlassian__updateConfluencePage` with `pageId`, `title`, `content` (HTML),
   and `version: current + 1`.

---

## Step 4 — Report

Tell the user:
- The URL of the created/updated Confluence page.
- That `/refine-story` will consult this page during NFR analysis to avoid writing acceptance
  criteria for requirements already covered globally.
- Suggest running `/definition-of-ready` next if the team's DoR has not been set up yet.

---

## Rules

- Do not publish the page until the user approves the checklist in Step 2.
- The page title must be exactly `Definition of Done` — no suffixes.
- If the user asks to view the current DoD only, print the page URL and stop — do not propose changes.
- Non-functional requirements that appear in the DoD (e.g., "Unit test coverage > 80%") are
  considered globally covered — `/refine-story` will not generate individual ACs for them on
  each story.
