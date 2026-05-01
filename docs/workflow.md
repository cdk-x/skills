# Development Workflow

This document describes the end-to-end lifecycle of a user story or task, from initial idea to production. Work flows through two GitHub Project boards: the **Discovery Board**, where items are analyzed and refined until they are ready to be implemented, and the **Development Board**, where items are executed during a sprint. The [Definition of Ready](definition-of-ready.md) governs entry into the Development Board; the [Definition of Done](definition-of-done.md) governs the terminal state of every item.

## Item Types

### User Story

A user story captures end-user-visible value in the form: _"As a [actor], I want [feature], so that [benefit]."_ Acceptance criteria are written in Given/When/Then format. See [requirements.md](requirements.md) for the INVEST mnemonic, DEEP properties, and Gherkin syntax.

### Task

A task is a unit of technical work that supports one or more user stories but does not map directly to a user-facing feature — infrastructure changes, refactors, and spikes belong here. Acceptance criteria take the form of a plain checklist. Tasks must still satisfy the "Small" criterion of the Definition of Ready: they must be completable within one sprint.

Both item types are valid on either board.

## Roles

| Role | Abbrev | Board involvement |
|---|---|---|
| Product Owner | PO | Discovery — owns backlog ordering and item acceptance |
| Developer | Dev | Development — executes sprint work, opens PRs |
| Reviewer | — | Development — reviews PRs and applies quality labels |
| QA / Tester | QA | Development — validates items in the Testing column |
| Scrum Master | SM | Both — facilitates ceremonies and removes blockers |
| Stakeholder | — | Discovery — provides input during Analysis and Refinement |

## GitHub Labels

Labels are applied to issues and pull requests to communicate state, signal column transitions, and classify work.

### State & Transition

These labels trigger or signal movement between columns.

| Label | Meaning | Column effect |
|---|---|---|
| `work in progress` | PR is open but not ready for review | Item stays in In Progress; signals a draft PR |
| `needs review` | PR is ready for peer review | In Progress → Code Review |
| `reviewed` | PR has been reviewed and approved | Code Review → Ready to Build |
| `paused` | Work is temporarily suspended | Item stays in current column; flags a blocker |
| `preview` | Ephemeral environment deployed (beta, RC, etc.) | Ready to Build → In Testing |
| `release` | Item is part of a planned release | Informational; no automatic column move |

### Quality & Blocker

These labels signal issues that prevent progress.

| Label | Meaning |
|---|---|
| `broken test` | CI tests are failing; PR is blocked |
| `conflicts` | PR has merge conflicts that must be resolved before review can continue |
| `breaking changes` | PR introduces breaking changes; requires extra review rigor and release notes |
| `need discuss` | Team discussion is required before work can proceed |

### Classification

These labels describe the nature of the work.

| Label | Meaning |
|---|---|
| `feature-request` | Item originates from a feature request |
| `auto-approve` | PR meets criteria for automatic approval (e.g., dependency bumps, bot PRs) |

### Effort

These labels communicate estimated size and are applied during refinement on the Discovery Board.

| Label | Meaning |
|---|---|
| `effort/small` | Small estimated effort |
| `effort/medium` | Medium estimated effort |
| `effort/large` | Large estimated effort |

Removing a state or transition label does not automatically revert the column — the team decides the recovery path.

## Discovery Board

All new work begins on the Discovery Board. Items pass through four columns, accumulating the clarity and acceptance criteria needed to meet the Definition of Ready before they are eligible for a sprint.

### 1. Analysis

**Purpose:** the landing zone for any new idea or requirement. An item only needs a title and a rough description to exist here.

**Who acts:** Product Owner creates the item. Stakeholders and Scrum Master may contribute context.

**Entry:** any idea worth recording.

**Exit:** the item has enough context — a draft description, a tentative type (user story or task), and at least one stakeholder identified — for the team to discuss it in a refinement session. The PO decides when this bar is met.

**Actions:** PO writes the draft, links related epics or requirements if they exist, and moves the card to Ready for Refinement.

### 2. Ready for Refinement

**Purpose:** a PO-curated queue of items that are ready to discuss with the Scrum Team.

**Who acts:** Product Owner orders the queue according to the criteria in [product-backlog-ordering.md](product-backlog-ordering.md) — business value, risk, size, and dependency.

**Entry:** PO has reviewed the item; a draft description and at least one acceptance criterion placeholder exist.

**Exit:** the item appears on the agenda for the next refinement session.

**Actions:** PO orders the queue before each session; Scrum Master schedules the session.

### 3. In Refinement

**Purpose:** the Scrum Team actively refines the item — writing acceptance criteria, discussing the technical approach, and sizing the effort.

**Who acts:** Product Owner clarifies intent and acceptance criteria; Developers ask technical questions and estimate size; Scrum Master facilitates.

**Entry:** the item is on the active refinement session agenda.

**Exit:** the item meets all four Definition of Ready criteria: Small, Sized, Just Enough Detail, and Understood by the team. Items that cannot meet these criteria in one session return to Ready for Refinement with notes.

**Actions:** the team writes acceptance criteria (Given/When/Then for user stories; a checklist for tasks), assigns a story point estimate using the Fibonacci sequence, and confirms the item is small enough to complete within one sprint. The PO moves the card to Ready for Implementation.

### 4. Ready for Implementation

**Purpose:** a prioritized pool of Definition-of-Ready-compliant items that are eligible for Sprint Planning.

**Who acts:** Product Owner maintains ordering; Scrum Master monitors queue health.

**Entry:** the item satisfies every criterion in [definition-of-ready.md](definition-of-ready.md).

**Exit:** the item is pulled into the Development Board's Todo column during Sprint Planning.

**Actions:** no further refinement should happen here, though minor clarifications are allowed. The PO re-orders the queue before each Sprint Planning session.

## Development Board

Items enter this board only after being selected in Sprint Planning. The board tracks execution from Todo through Done.

### 1. Todo

**Purpose:** items committed to the current sprint but not yet started.

**Who acts:** Developer (self-assigns an item when ready to begin).

**Entry:** item was pulled from the Discovery Board's Ready for Implementation column during Sprint Planning.

**Exit:** a Developer picks up the item and starts work.

**Actions:** during Sprint Planning, the team pulls items from Discovery's Ready for Implementation, agrees on the sprint goal, and places the items in Todo. Each item retains its acceptance criteria and story point estimate.

### 2. In Progress

**Purpose:** a Developer is actively building the feature or task.

**Who acts:** Developer (primary); Product Owner available for clarification.

**Entry:** Developer self-assigns the item and creates a branch.

**Exit:** the PR is open and the Developer applies `needs review`. The `work in progress` label can be applied to a draft PR to signal the item is not yet ready for review.

**Actions:** Developer creates a branch, implements the feature or fix, writes tests, and opens a PR (possibly as a draft). When the work is ready for review, the Developer applies `needs review`.

### 3. Code Review

**Purpose:** a peer Reviewer examines the PR for correctness, style, and adherence to the Definition of Done's code-quality criteria.

**Who acts:** Reviewer (examines the PR); Developer (addresses feedback).

**Entry:** `needs review` label is applied to the PR.

**Exit:** Reviewer applies `reviewed`; no blocking labels (`broken test`, `conflicts`, `need discuss`) remain on the PR.

**Actions:** Reviewer reads the diff, leaves comments, and approves or requests changes. If CI is red, Reviewer applies `broken test`; if the branch needs rebasing, `conflicts`; if something must be discussed before proceeding, `need discuss`. On approval, Reviewer applies `reviewed` and the item moves to Ready to Build. If changes are requested, the item stays in Code Review or returns to In Progress — the team decides.

### 4. Ready to Build

**Purpose:** the PR is approved and the preview environment can be deployed.

**Who acts:** Developer or CI automation.

**Entry:** PR has at least one approval and all automated checks pass.

**Exit:** `preview` label is applied and the ephemeral environment is live.

**Actions:** Developer (or automation) applies the `preview` label, triggering the preview deployment pipeline. The label works for any versioning scheme in use: beta, release candidate, or otherwise.

### 5. In Testing

**Purpose:** QA validates the item in the preview environment against its acceptance criteria.

**Who acts:** QA runs acceptance tests; Product Owner may optionally provide final sign-off.

**Entry:** `preview` label is applied; preview environment is accessible.

**Exit:** all acceptance criteria pass — item moves to Done. Any failure — item moves to Resolve.

**Actions:** QA executes the acceptance criteria (Given/When/Then scenarios for user stories; checklist items for tasks). Failures are documented with steps to reproduce. QA moves the item to Resolve or Done accordingly.

### 6. Resolve

**Purpose:** a rework column — failures found in testing are addressed before the item can be marked Done.

**Who acts:** Developer (fixes the issue); QA (re-validates).

**Entry:** QA found one or more failures in the In Testing column.

**Exit:** Developer fixes the issue and pushes to the existing PR; item returns to In Testing for re-validation.

**Actions:** Developer investigates the reported failure, makes code changes, and pushes to the existing branch. The item returns to In Testing. If the fix requires significant new scope, the Product Owner decides whether to split it into a new backlog item.

### 7. Done

**Purpose:** the item is complete and releasable; it meets the Definition of Done.

**Who acts:** Product Owner (final acceptance); Developer (merges the PR).

**Entry:** all acceptance criteria pass in testing AND the item satisfies every criterion in [definition-of-done.md](definition-of-done.md).

**Exit:** terminal state for the sprint.

**Actions:** PR is merged into the main branch. Release notes are updated if applicable. PO marks the item Done on the board. The team counts the item toward sprint velocity.

## Sprint Planning

Sprint Planning occurs at the start of each sprint. The input is the ordered Ready for Implementation column on the Discovery Board. The Scrum Team reviews the top items, confirms each still meets the Definition of Ready, and pulls them into the Development Board's Todo column. The Product Owner presents the sprint goal; Developers self-organize to commit to a realistic volume based on their velocity. Items that fail the final readiness check return to In Refinement on the Discovery Board with a note explaining what is missing.

## End-to-End Flow

```
[New Idea / Stakeholder Input]
         |
         v
    DISCOVERY BOARD
┌─────────────────────────────────────────────────┐
│  Analysis                                        │
│       │                                          │
│       v                                          │
│  Ready for Refinement                            │
│       │                                          │
│       v                                          │
│  In Refinement ──(fails DoR)──> Ready for Ref.  │
│       │                                          │
│       v (meets DoR)                              │
│  Ready for Implementation                        │
└─────────────────────────────────────────────────┘
         |
         | Sprint Planning
         v
    DEVELOPMENT BOARD
┌──────────────────────────────────────────────────────────────────────┐
│  Todo                                                                 │
│   │                                                                   │
│   v                                                                   │
│  In Progress ──[needs review]──────────> Code Review                 │
│                                               │                       │
│                                          [reviewed]                   │
│                                               │                       │
│                                               v                       │
│                                       Ready to Build                  │
│                                               │                       │
│                                          [preview]                    │
│                                               │                       │
│                                               v                       │
│                          Resolve <────── In Testing                   │
│                             │                 │                       │
│                             └──> In Testing   v (all pass)            │
│                                              Done                     │
└──────────────────────────────────────────────────────────────────────┘
```

| Stage | Board | Actor | Key Action | Gate to Next |
|---|---|---|---|---|
| Analysis | Discovery | PO, Stakeholder | Draft item; link context | PO judges enough context to refine |
| Ready for Refinement | Discovery | PO | Order queue by value / risk / size / dependency | Item on refinement agenda |
| In Refinement | Discovery | Scrum Team | Write AC, estimate, confirm size | Item meets all DoR criteria |
| Ready for Implementation | Discovery | PO, SM | Maintain priority order | Item selected in Sprint Planning |
| Todo | Development | Dev | Self-assign item | Dev starts a branch |
| In Progress | Development | Dev | Implement, open PR | `needs review` applied |
| Code Review | Development | Reviewer, Dev | Review diff, apply quality labels | `reviewed` applied; no blockers remain |
| Ready to Build | Development | Dev / CI | Trigger preview deployment | `preview` applied; env live |
| In Testing | Development | QA, PO | Validate against acceptance criteria | All AC pass or failure found |
| Resolve | Development | Dev, QA | Fix issue, push to PR | Back to In Testing for re-validation |
| Done | Development | PO, Dev | Accept; merge PR | Meets Definition of Done |

## Related Documents

- [Definition of Ready](definition-of-ready.md) — criteria an item must meet before entering Ready for Implementation
- [Definition of Done](definition-of-done.md) — criteria an item must meet before being marked Done
- [Product Backlog Ordering](product-backlog-ordering.md) — how the PO orders items using value, risk, size, and dependency
- [Requirements](requirements.md) — item types (user stories, epics, non-functional requirements) and acceptance criteria format
