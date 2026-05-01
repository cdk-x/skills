---
name: refine-story
description: >
  Run a full refinement session on a user story from the Discovery Board. Moves
  the story to "In Refinement", performs a hybrid analysis of Functional and
  Non-Functional Requirements (auto-extraction then targeted questions for gaps),
  enriches existing acceptance criteria (Given/When/Then), sets Risk and Estimate
  project fields, checks Definition of Ready compliance, and transitions to "Ready
  for Implementation" when all criteria are met. Trigger when the user says
  "/refine-story", "/refine-story <issue-number>", "refine story #N", "run
  refinement", "let's refine", "refine this story", "start refinement session",
  or any variation of refining a user story on the Discovery Board. When an issue
  number is provided directly (e.g. "/refine-story 42"), use it immediately as
  the target story — skip the listing step in Step 0.
---

# /refine-story — Story Refinement

Lead a full refinement session for a user story on the Discovery Board. Analyzes Functional and Non-Functional Requirements, enriches existing acceptance criteria, sets Risk and Estimate fields, and transitions the story through the refinement workflow.

> **GitHub model:** Stories on the Discovery Board are **real GitHub Issues** in a private backing
> repository, tracked via the GitHub Project. The backing repository is private so stories are never
> visible in any public repo. Use `gh issue view/edit/comment` (with `--repo`) for content operations,
> and GraphQL for project field mutations. Resolve the backing repository from `AGENTS.md` / `CLAUDE.md`
> alongside the project number.

**Board transitions handled by this skill:**

```
[Analysis | Ready for Refinement]
        ↓  (skill starts)
    In Refinement
        ↓  (DoR ✅ + user approves)
Ready for Implementation
```

> "Analysis → Ready for Refinement" is a PO decision (manual). This skill picks up from there.

---

## Step 0 — Find the story to refine

If an issue number was passed directly (e.g. `/refine-story 42` or `/refine-story #42`), use it immediately — skip listing and go straight to the status check below.

If no issue was specified, list stories awaiting refinement via the GitHub Project (see `references/github.md` for the `gh project item-list` command and the GraphQL filter by `Status = Ready for Refinement`). Show the list to the user and ask which story to refine.

Resolve the GitHub Project before continuing (check `AGENTS.md` / `CLAUDE.md`, or ask once). Read `references/github.md` for all commands used in this skill.

**Status gate — check before proceeding:**

Fetch the current `Status` field value for the story from the GitHub Project. If the status is `Analysis`, stop and inform the user:

> _"Story #N is still in **Analysis**. Moving a story from Analysis to Ready for Refinement is a manual step — the Product Owner must review and promote it before the refinement session can begin. No changes have been made."_

Only continue if the status is `Ready for Refinement` (or if the user explicitly overrides by confirming they want to proceed anyway despite the status).

---

## Step 1 — Move to "In Refinement"

Resolve the `Status` field and its option IDs for the project. Set:

```
Status = In Refinement
```

Confirm to the user: _"Story #N is now In Refinement."_

---

## Step 2 — Fetch the story and its full context

Fetch the project item content via GraphQL (see `references/github.md` for the `node(id:)` query).

From the response:
1. **Read the full body** — it may contain prior refinement session notes (appended after a `---` separator), team decisions, or open questions from earlier sessions. Extract any relevant context before analysing.
2. **Find the PRD link** — search the body for `"Derived from PRD:"`. If found, fetch that PRD project item for additional context.
3. **Find the parent Epic** — check the body for `"Parent Epic:"`. If present, fetch the Epic item and extract its **Success Criteria** (SC). The ACs written for this story must collectively contribute to satisfying those SCs.

Note: the story already has acceptance criteria from `/user-story` — treat them as a first draft, not final. Do not discard them; enrich them.

---

## Step 3 — Auto-extract Functional Requirements

From the story body, PRD (if available), and relevant comments, extract:

- A numbered list of **Functional Requirements** — what the system must do, from the user's perspective
- The actors involved
- The main flows and sub-flows

For each FR, assess clarity:

```
FR-1: <description>   ✅ clear
FR-2: <description>   ⚠️  ambiguous — missing error condition
FR-3: <description>   ❓ gap — no existing AC covers this
```

---

## Step 4 — Auto-extract Non-Functional Requirements

Identify NFRs applicable to this story from the story body, PRD, and comments. Use the categories from `docs/requirements.md`:

> Performance · Security · Usability · Scalability · Accessibility · Maintainability · Legal/Compliance · Cost · Cultural

For each NFR:
- Does it have a **measurable threshold** (e.g., "< 200ms", "> 99.9% uptime")? → ✅ can generate AC
- No threshold → ⚠️ ask the team

**Check the DoD issue** (search for it, see `references/github.md`). NFRs already covered globally in the Definition of Done do **not** need individual ACs on this story — mark them as `→ Covered by DoD ✅`.

If no DoD issue exists, note it: _"No Definition of Done found. Run `/definition-of-done` to set one up."_

---

## Step 5 — Targeted questions (gaps only)

Ask the user only about:

- FRs marked ⚠️ ambiguous or ❓ gap
- NFRs without a measurable threshold
- Edge cases or error scenarios identified but not yet covered by any AC
- NFRs that seem to apply to every story in the project → suggest adding them to the DoD: _"This NFR appears omnipresent — consider adding it to the Definition of Done via `/definition-of-done` rather than repeating it here."_

Limit to **5 questions per round**. If more gaps remain, address them in a second pass after the user responds.

---

## Step 6 — Enrich the Acceptance Criteria

Do not discard existing ACs from `/user-story`. Review each one and:

- Keep complete, unambiguous ACs as-is
- Rewrite ambiguous ACs with clearer Given/When/Then conditions
- Add new ACs for:
  - FRs with no current coverage (❓ gap)
  - NFRs without DoD coverage and with a confirmed threshold
  - Error scenarios, edge cases, and boundary conditions surfaced in Step 5
- Skip ACs for NFRs covered by the DoD — reference the DoD instead

Format: `- [ ] Given [precondition], when [action], then [expected result].`

If the story has a parent Epic, verify that the ACs collectively satisfy the Epic's **Success Criteria**. Note any SC not yet covered by any story's ACs.

---

## Step 7 — Set all project fields

All four project fields must be defined before the story can be considered ready. Propose each with a brief justification; the user may adjust any of them.

**Value** (business value of this story):
- Check if already set from `/user-story`. If not, ask the PO to assign it.
- Value represents revenue, cost saving, customer retention, or strategic opportunity.
- Use the same scale configured in the GitHub Project (numeric or select).

**Risk**: `L` / `M` / `H` based on:
- External dependencies or integrations
- Technical uncertainty or unknowns
- Business impact if it fails or ships late
- Technical debt or legacy code involved

**Estimate** (Fibonacci: 1, 2, 3, 5, 8, 13):
- 1–2: well-understood, minimal complexity
- 3: straightforward with some unknowns
- 5: moderate complexity, some risk
- 8: significant complexity or uncertainty
- 13: very large — consider splitting before moving to implementation

If the estimate is 13, flag: _"This story may be too large for one sprint. Consider splitting."_

**Size**: Small / Medium / Large — set by `/user-story` at creation. Confirm it still reflects the current understanding after refinement, or update if scope has changed:
- Small: a few hours to 2 days
- Medium: 2–5 days
- Large: close to a full sprint (flag for potential further splitting)

---

## Step 8 — DoR compliance check

Look for the DoR docs issue (see `references/github.md`). Use its criteria if found; otherwise apply the four Scrum minimums.

Check each criterion and mark ✅ or ❌:

1. **Small** — completable by one developer in one sprint? (estimate ≤ 8 pts; flag if 13)
2. **Sized** — has a Fibonacci estimate set?
3. **Just Enough Detail** — every FR has at least one AC?
4. **Understood** — ask the user explicitly: _"Does the team have enough shared understanding to start implementation?"_
5. **All project fields set** — Value, Risk, Estimate, and Size must all have a value. A story with any blank field is not ready.
6. Any additional team-specific criteria from the DoR issue

---

## Step 9 — Show the full refinement proposal for review

Present the complete summary and wait for the user's approval:

```markdown
## Refinement Summary — Story #N: <title>

### Functional Requirements
- FR-1: <description> ✅
- FR-2: <description> ✅

### Non-Functional Requirements
- NFR-1: [Performance] Response < 200ms → AC added
- NFR-2: [Security] Passwords encrypted at rest → Covered by DoD ✅

### Acceptance Criteria
- [x] Given <existing AC> (unchanged)
- [ ] Given <enriched/new AC>
- [ ] Given <error scenario AC>

### Epic Success Criteria
- SC-1: "<SC text>" → covered by AC-2, AC-3 ✅

### Risk: M | Estimate: 5 pts

### DoR Check
✅ Small  ✅ Sized  ✅ Detail  ✅ Understood  ✅ All fields set
→ Ready for Implementation ✅
```

Iterate based on user feedback. Return to any earlier step if changes are needed.

---

## Step 10 — Update the project item

Once the user approves, update the story via `updateProjectV2DraftIssue` (see `references/github.md`):

1. **Rewrite the item body** using `assets/refined-story-template.md` — fill in User Story sentence (original), FRs, NFRs, enriched ACs, and Epic SC coverage.

2. **Add a refinement session comment** — decisions and context only. Do NOT include Risk, Estimate, Value, or Size — those are project fields, not comment content:

   ```
   ## Refinement Session — <date>

   **Functional Requirements identified**: FR-1, FR-2, ...
   **Non-Functional Requirements**: <description, or "None story-specific">

   **Decisions**: <key decisions made during the session>
   **Open questions**: <unresolved questions, or "None">
   ```

3. **Ask the user**: _"Do you want to add any notes from the team's discussion to this comment before closing the session?"_ — incorporate their input.

---

## Step 11 — Set project fields and transition

Set all four project fields on the GitHub Project item (see `references/github.md`): **Value**, **Risk**, **Estimate**, and **Size** (update Size only if it changed during refinement).

**If DoR ✅ (all criteria met):**
- Set `Status = Ready for Implementation`
- Tell the user: _"Story #N is Ready for Implementation and will be available for Sprint Planning."_

**If DoR ❌ (one or more criteria unmet):**
- Leave `Status = In Refinement`
- Add a comment listing the unmet criteria and what is needed to resolve them
- Tell the user: _"Story #N remains In Refinement. Unmet criteria: [list]. Address these before moving to Ready for Implementation."_

---

## Rules

- Never delete existing acceptance criteria — enrich or rewrite, but preserve intent.
- Do not transition to "Ready for Implementation" without explicit user approval in Step 9.
- NFRs already in the DoD issue never get individual ACs — only a DoD reference.
- If Estimate = 13, always flag the risk of splitting before proceeding.
- "Ready for Refinement → In Refinement" is triggered by running this skill. "Analysis → Ready for Refinement" is a manual PO action — this skill does not touch that transition.
- If the DoD or DoR issues do not exist, note their absence and suggest the corresponding skills, but do not block the refinement session.
- Keep the session focused: ask a maximum of 5 questions per round in Step 5.
