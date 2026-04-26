---
name: prd
description: Convert a feature idea or description into a Product Requirements Document (PRD) and publish it to GitHub Issues or Confluence. Use whenever the user wants to write a PRD, spec, or specification, formalize a feature, define requirements, create user stories, or document what to build. Always use this skill when the user mentions "prd", "spec", "specification", "requirements", "user stories", "acceptance criteria", or wants to turn any feature idea into a structured document.
---

# /prd — Product Requirements Document

Turns a feature description into a structured PRD and publishes it to the destination of your choice. Always show the full draft to the user for review before publishing.

## Step 0 — Determine the publishing destination

Check the context for a clear signal:
- User mentioned "GitHub", "issue", or a repo → use GitHub
- User mentioned "Confluence", "page", "space", or a team wiki → use Confluence

If there is no clear signal, ask: *"Where should I publish this PRD — GitHub Issues or Confluence?"*

Read the corresponding reference file now so you have the publishing details ready:
- GitHub → `references/github.md`
- Confluence → `references/confluence.md`

For Confluence, also collect the space and parent page at this point (see `references/confluence.md`) — it is better to ask once upfront than to interrupt the user after the PRD is written.

---

## Step 1 — Gather context

Scan the conversation history first. Prior discussion often already answers most of these. Only ask for what is genuinely missing or unclear — and batch all questions into a single message, never one at a time.

Collect:
- **Business motivation** — why is this being built? what problem does it solve and why now?
- **Audience** — who will read this PRD? (business stakeholders, engineers, or both — it affects tone and level of detail)
- **Priority** — how urgent is this? is it blocking anything? is there a deadline?
- **Related work** — is this related to an existing feature, PRD, or in-flight work?

---

## Step 2 — Research

Before drafting, gather relevant context from existing sources:
- Search for related issues or pages on the chosen destination (GitHub issues or Confluence) to avoid duplication and spot dependencies
- Explore the codebase if the feature touches something already implemented — understanding the current state makes requirements more precise
- Note any findings; they will inform the PRD content and the linking step at publish time

---

## Step 3 — Extract key concepts from the feature description

- Actors (who uses this?)
- Actions (what do they do?)
- Data (what entities are involved?)
- Constraints (what limits or rules apply?)

## Step 4 — Fill the PRD template

Use the template in `assets/prd-template.md`. Rules:
- All requirements must be testable — avoid vague verbs like "support", "handle", "manage"
- All success criteria must be measurable and tech-agnostic
- Mark genuine unknowns as `[NEEDS CLARIFICATION: <specific question>]` — max 3 total
- Remove optional sections that do not apply

## Step 5 — Resolve clarifications

If `[NEEDS CLARIFICATION]` markers remain, extract them and ask the user before showing the draft. At most 3 questions, prioritised by impact. The final draft must have zero unresolved markers.

## Step 6 — Show the draft for review

Show the full PRD to the user. Do NOT publish yet.

## Step 7 — Iterate

Incorporate feedback and go back to step 4 until the user approves.

## Step 8 — Publish and link

Follow the instructions in the reference file for the chosen destination.

If related issues or pages were found in Step 2, link them after publishing:
- GitHub: add cross-references in the issue body or as linked issues
- Confluence: add a "Related pages" section or use Confluence page links

## Step 9 — Report

Tell the user the issue number / page URL so they can share or reference it.

---

## Rules

- Focus on **what** and **why**, never **how** — no languages, frameworks, file paths, or implementation details
- Tone and level of detail must match the audience identified in Step 1
- Written so any team member can understand it, not just engineers
- Keep it concise — every line must earn its place
- If the codebase needs exploring to validate assumptions, do it in Step 2 before drafting
