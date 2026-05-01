---
name: user-story
description: >
  Create GitHub Issues for each user story extracted from a PRD, setting the
  correct issue type and project fields (Type, Size, Risk, Estimate) on the
  GitHub Project. Creates Epic issues as parents for large stories, with child
  user stories attached as native sub-issues. Use this skill whenever the user
  wants to create user stories from a PRD, generate Discovery Board items from
  a spec, break a product document into GitHub issues, populate the product
  backlog, or create user story issues on GitHub Projects. Trigger on "create
  user stories", "user stories from PRD", "user story", "generate backlog
  items", "populate discovery board", "create issues from PRD", or any
  variation of turning a product requirements document into structured user
  story issues.
---

# User Story

Reads a PRD and creates one GitHub Issue per user story with the correct
**issue type** and **project fields** set (Type, Size, Risk, Estimate). Stories
that are too large to complete in one sprint become Epics — parent issues with
child user stories attached as native GitHub sub-issues.

Issue types used by this skill: `Epic` and `User Story`.
Available types in the project: `Epic`, `User Story`, `Feature`, `Bug`, `Task`.

New issues land on the **Discovery Board** in the **Analysis** column.

## Step 0 — Find the PRD

Check the context for a clear signal:

- GitHub issue number or URL → `gh issue view <number> --json title,body`
- Confluence URL or page title → see `references/github.md` for the Confluence fetch approach
- PRD content already in the conversation → use it directly

If the source is unclear, ask once: *"Where is the PRD — a GitHub issue number, a Confluence page, or is it already in our conversation?"*

Also resolve which **GitHub Project** to use:
1. Check `AGENTS.md` and `CLAUDE.md` in the current repo for a configured project name or number (look for keys like `GitHub Project`, `project`, or similar)
2. If found, use it directly
3. If not found, ask the user once: *"Which GitHub Project should these issues go into?"*

Read `references/github.md` to resolve the project number and its field IDs before creating any issues.

## Step 1 — Extract user stories

Read the PRD carefully and pull out:

- **User stories** — items in "As a / I want / so that" format, or anything describing user-facing value
- **Context and motivation** — the problem each story solves (usually in the Problem Statement or Solution sections)
- **Acceptance criteria** — per-story test conditions, if present
- **Success criteria** — measurable outcomes that apply across multiple stories

If the PRD has functional requirements but no explicit user stories, derive the stories from the requirements — each functional requirement maps to one or more user-facing outcomes.

## Step 2 — Assess size (INVEST Small criterion)

For each story, ask: *can one developer complete this within a single sprint?*

- **Yes** → standalone `User Story`; propose a Size for the project field:
  - `Small` — a few hours to 2 days
  - `Medium` — 2–5 days
  - `Large` — close to a full sprint (flag for potential splitting during refinement)
- **No** → **Epic**: decompose into 2–5 smaller, independently deliverable child stories, each sprint-sized

When in doubt, lean toward creating an Epic — it is easy to collapse in refinement.

## Step 3 — Compose issue titles and show the proposed breakdown for review

The **issue title** is not the user story sentence. It must be short, identifiable, and
scannable on a board — a noun phrase that names the feature or capability being delivered.
The "As a / I want / so that" sentence goes in the **issue body**, not the title.

Good title examples:
- `Provider lifecycle hooks (preSynthesize / postSynthesize)`
- `Synthesis error reporting via Annotations`
- `Generate Ansible YAML files during synthesis`

Bad title (too long, wrong place):
- `As an infrastructure engineer, I want cdkx synth to generate Ansible-ready YAML files...`

Before creating anything, present the full proposed structure using the short titles:

```
Epic: <short descriptive title>
  US-1: <short title>  [Size: Medium]
  US-2: <short title>  [Size: Small]

Standalone stories:
  US-3: <short title>  [Size: Small]
  US-4: <short title>  [Size: Large — consider splitting in refinement]
```

Ask the user:
- Does the granularity feel right?
- Are any stories missing or should be merged?
- Should any `Large` stories be split now or left for refinement?

Iterate until the user approves.

## Step 4 — Create the GitHub Issues and set project fields

Read `references/github.md` for the exact commands. Follow this order:

1. **Resolve project field IDs** — fetch the project's field metadata once to get the IDs for `Type` and `Size` fields and their option IDs (e.g. the option ID for "Epic", "User Story", "Small", "Medium", "Large")
2. **Create Epics first** — use the short title as the issue title; create the issue, add it to the project, set `Type = Epic`, set `Size` if applicable
3. **Create each User Story** — use the short title as the issue title; create the issue, add it to the project, set `Type = User Story`, set `Size`
4. **Attach child stories to their Epic** as native GitHub sub-issues
5. **Link each story to the source PRD** via a comment reference — no manual text in the body

Do NOT modify the source PRD issue.

## Step 5 — Report

List everything created:
- Epic issue numbers and URLs (if any), with Type and project fields set
- User story issue numbers and URLs, with Type, Size, and parent Epic

Remind the user that the new issues are in the Discovery Board's **Analysis** column and will move through **Ready for Refinement → In Refinement → Ready for Implementation** before a sprint.
