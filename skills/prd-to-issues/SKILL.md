---
name: prd-to-issues
description: Break a PRD into independently-grabbable issues using tracer-bullet vertical slices and publish them to GitHub Issues or Jira. Creates GitHub issues or Jira Stories+Tasks with dependencies, blockers, and links to related artifacts. Use whenever the user wants to convert a PRD to issues, create implementation tickets, break down a spec into work items, or create Jira stories and tasks from a PRD. Trigger on "prd-to-issues", "break PRD into issues", "create issues from PRD", "create Jira tickets from PRD", "create GitHub issues from PRD", "create tasks from spec", or any variation of converting a product spec into implementation tasks.
---

# PRD to Issues

Break a PRD into independently-grabbable issues — either GitHub Issues or Jira Stories+Tasks — using vertical slices (tracer bullets). Issues are created with dependencies, blockers, and links back to the source PRD.

## Step 0 — Determine the PRD source

Check the context for a clear signal:
- User mentioned "issue", "GitHub", or a bare number → PRD is a GitHub issue
- User mentioned "Confluence", "page", "PRD page", or a URL → PRD is a Confluence page

If there is no clear signal, ask: *"Where is the PRD — a GitHub issue number or a Confluence page?"*

Read the corresponding reference file for fetching:
- GitHub PRD → `references/github.md` (Fetching the PRD section)
- Confluence PRD → `references/confluence.md`

## Step 0b — Determine the target issue tracker

Check the context for a clear signal:
- User mentioned "Jira", "project key", or "stories" → use Jira
- User mentioned "GitHub issues" or "GH" explicitly → use GitHub Issues

If there is no clear signal, ask: *"Should I create the issues in GitHub Issues or Jira?"*

Read the corresponding reference file for issue creation:
- GitHub → `references/github.md` (Creating Issues section)
- Jira → `references/jira.md`

## Step 1 — Fetch the PRD

Follow the fetch instructions in the reference file for the chosen PRD source. If the PRD is empty or has no actionable content, tell the user and stop.

Extract from the PRD:
- **User stories** — numbered list of user-facing outcomes ("As a X, I want Y so that Z")
- **Functional requirements** — constraints and rules the implementation must satisfy
- **Non-functional requirements** — performance, security, scalability constraints

## Step 2 — Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state and the impact area. Look for existing patterns to follow and avoid reimplementing what's already there.

## Step 3 — Draft vertical slices

Break the PRD into **tracer bullet** slices. Each slice is a thin vertical cut through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK':
- **HITL**: requires human interaction (architectural decision, design review, external approval)
- **AFK**: can be implemented and merged without human interaction

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- A slice that is only "set up scaffolding" or "create the database schema" is NOT a tracer bullet — push it to include a real user-facing interaction
</vertical-slice-rules>

**If targeting Jira**: also map each slice to the PRD user stories it addresses — this drives the Story/Task structure created in Step 5.

## Step 4 — Quiz the user

Present the proposed breakdown. For **Jira**, group slices under their parent user stories and show the Epic:

```
Epic: <name> (existing PROJ-5 | to be created | none)

User Stories (will be created as Jira Stories under the Epic):
  US-1: As a <user>, I want to <action> so that <value>
  US-2: ...

Implementation Slices (will be created as Jira Tasks / GitHub Issues):
  1. <Slice title> [AFK]
     Covers: US-1, US-2
     Blocked by: Slice 2
  2. <Slice title> [HITL]
     Covers: US-3
     Blocked by: none
```

For **GitHub**, present a flat numbered list with the same fields (no Epic concept).

Ask the user:
- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL / AFK?
- For Jira: is the Epic assignment correct, or should the Stories go under a different Epic?

Iterate until the user approves the breakdown.

## Step 5 — Create the issues

Follow the creation instructions in the reference file for the chosen target.

**Order matters**: always create blockers before blocked issues so you can reference real issue numbers/keys when setting up links.

For **Jira** (read `references/jira.md` for full details):
1. Resolve the Epic — search for existing Epics, present them, and ask the user which one applies (or create a new one)
2. Create Story issues for each PRD user story, linked to the Epic
3. Create Task issues for each implementation slice
4. Link each Task to its parent Story (relates-to)
5. Add block/dependency links between Tasks that have ordering constraints
6. Include a link to the source PRD (Confluence page URL or GitHub issue URL) in each issue description

For **GitHub** (read `references/github.md` for full details):
1. Create issues in dependency order (blockers first)
2. Reference real issue numbers in the "Blocked by" section
3. Link back to the parent PRD issue

Do NOT close or modify the parent PRD issue or Confluence page.

## Step 6 — Report

Tell the user what was created:
- **Jira**: list all Story keys and Task keys, with their Jira URLs and a summary of links established
- **GitHub**: list all issue numbers and URLs

If the user has not yet run `/analyze` on the spec, suggest it as a quality gate before implementation begins.
