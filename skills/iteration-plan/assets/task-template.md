# Sub-task Description Template

Use this template for every sub-task created in Step 7.
The description must be **self-contained**: a developer or AFK agent reads only this
sub-task to implement it — no additional context required.

Fill every section. Remove sections only if they genuinely do not apply
(e.g., no external interfaces for a pure internal utility).

---

## Context

_Why this sub-task exists. Which story it belongs to. Which FRs and ACs it covers.
How it fits into the overall story implementation (e.g., "this is the data loading
layer; the DAG construction sub-task builds on top of it")._

Story: <STORY-KEY> — <story title>
FRs covered: FR-N, FR-M
ACs covered: AC-N, AC-M

---

## What to implement

_Precise technical description of what needs to be done. Be specific enough that
there is no ambiguity about the expected behavior or output._

---

## Files to touch

_List every file that will be created or modified. For each, describe what changes._

- `path/to/file.go` — create; implements `<InterfaceName>`
- `path/to/other.go` — modify; add `<FunctionName>` function
- `path/to/file_test.go` — create; tests for the above

---

## Pattern to follow

_Reference to existing code in this repo that follows the same pattern.
Include file path and line range so the implementer can read it directly._

See `path/to/existing_example.go:45-80` for how similar functionality is structured.
Specifically: <what aspect of the pattern to follow>.

---

## Interface / expected signature

_If this sub-task defines or implements an interface, show the exact signature.
This prevents the implementer from inventing a contract that conflicts with dependents._

```go
// Example (adapt to the project's language)
type Planner interface {
    BuildDAG(manifest *Manifest) (*DAG, error)
    AssignWaves(dag *DAG) ([]Wave, error)
}
```

_Remove this section if no interface is involved._

---

## Tests required

_Describe what must be tested. For TDD: write the test first, then make it pass.
For non-TDD: tests are written after implementation._

- Given <precondition>, when <action>, then <expected result> → maps to AC-N
- Given <edge case>, when <action>, then <expected result>
- Given <error condition>, when <action>, then <expected behavior>

Test file: `path/to/file_test.go`
Test framework: <framework used in this repo>
Fixtures / helpers: `path/to/testutil/` — <what helpers are available>

---

## Acceptance criteria covered

_Copy the exact AC text from the story so the implementer has it without switching contexts._

- AC-N: Given …, when …, then …
- AC-M: Given …, when …, then …

---

## Mode: AFK | HITL

_State the mode. If HITL, explain what human decision or review is required and at what point._

**AFK** — implementation can proceed autonomously given this description.

_— or —_

**HITL** — human review required: <what decision or approval is needed before/during/after>.

---

## Estimate: Xh

_Ideal hours. Target: 4–8h. If outside this range, note why._
