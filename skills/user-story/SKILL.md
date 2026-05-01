---
name: user-story
description: >
  Create GitHub Project items for each user story extracted from a PRD, setting
  the correct item type and project fields (Type, Size, Risk, Estimate) on the
  GitHub Project. Creates Epic items as parents for large stories, with child
  user stories referenced via body links. Use this skill whenever the user wants
  to create user stories from a PRD, generate Discovery Board items from a spec,
  break a product document into project items, populate the product backlog, or
  create user story items on a GitHub Project. Trigger on "create user stories",
  "user stories from PRD", "user story", "generate backlog items", "populate
  discovery board", "create issues from PRD", or any variation of turning a
  product requirements document into structured user story project items.
---

# User Story

Reads a PRD and creates one **GitHub Project item**  per user story with the
correct **item type** and **project fields** set (Type, Size, Risk, Estimate). Stories that
are too large to complete in one sprint become Epics — parent items with child user stories
referenced in their body.

Item types used by this skill: `Epic` and `User Story`.
Available types in the project: `Epic`, `User Story`, `Feature`, `Bug`, `Task`.

New items land on the **Discovery Board** in the **Analysis** column.

> **GitHub model:** Items created by this skill are **real GitHub Issues** in a private backing
> repository, added to the GitHub Project with `gh project item-add`. The backing repository is
> private so Epics, User Stories, DoD, and DoR are never visible in any public repo — keeping all
> project management logic internal even when the codebase is open source. Only implementation
> Tasks are eventually created as issues in the public repository when a story is split for sprint
> work. Resolve the backing repository from `AGENTS.md` / `CLAUDE.md` alongside the project number.

## Step 0 — Find the PRD and resolve the GitHub Project

Check the context for a clear signal for the PRD:

- GitHub project item ID → fetch via GraphQL `node(id:)` query (see `references/github.md`)
- Confluence URL or page title → see `references/github.md` for the Confluence fetch approach
- PRD content already in the conversation → use it directly

If the source is unclear, ask once: *"Where is the PRD — a GitHub Project item ID, a Confluence page, or is it already in our conversation?"*

Also resolve the **GitHub Project** before creating any items:
1. Check `AGENTS.md` and `CLAUDE.md` for a configured project name/number and owner
2. If found, use it directly
3. If not found, ask the user once: *"Which GitHub Project should these items go into?"*

Read `references/github.md` to resolve the project number and field IDs before creating any items.

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

## Step 3 — Compose item titles and show the proposed breakdown for review

The **item title** is not the user story sentence. It must be short, identifiable, and
scannable on a board — a noun phrase that names the feature or capability being delivered.
The "As a / I want / so that" sentence goes in the **item body**, not the title.

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

## Step 4 — Create the project items and set fields

Read `references/github.md` for the exact commands. Follow this order:

1. **Resolve project field IDs** — fetch the project's field metadata once to get the IDs for `Type` and `Size` fields and their option IDs (e.g. the option ID for "Epic", "User Story", "Small", "Medium", "Large")
2. **Create Epics first** — use `gh project item-create` with the short title; set `Type = Epic` and `Size` via `updateProjectV2ItemFieldValue`
3. **Create each User Story** — use `gh project item-create` with the short title; set `Type = User Story` and `Size`
4. **Link child stories to their Epic** — include the Epic item ID in each child story's body, and the list of children in the Epic's body (see `references/github.md`)
5. **Link each story to the source PRD** — include the PRD item ID in each story's body

Do NOT modify the source PRD item.

## Step 5 — Report

List everything created:
- Epic item IDs (if any), with Type and project fields set
- User story item IDs, with Type, Size, and parent Epic reference

Remind the user that the new items are in the Discovery Board's **Analysis** column and will move through **Ready for Refinement → In Refinement → Ready for Implementation** before a sprint.
