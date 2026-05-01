# cdk-x/skills

Shared collection of agent skills for the cdk-x organization. Each skill is a self-contained package under `skills/` following the [agentskills.io](https://agentskills.io) spec.

## Repository Structure

```
skills/
├── analyze/                → Consistency analysis across spec and plan artifacts
├── conventional-commits/   → Atomic commits with Conventional Commits format
├── definition-of-done/     → Create/update Definition of Done as a docs issue
├── definition-of-ready/    → Create/update Definition of Ready as a docs issue
├── plan/                   → Technical plan generation from specs
├── prd/                    → Product Requirements Document generation and publishing
├── prd-to-issues/          → Break a PRD into GitHub Issues or Jira Stories+Tasks
├── refine-story/           → Full refinement session for a Discovery Board user story
├── user-story/             → Create GitHub user story issues from a PRD
└── (future skills)
```

Skills are symlinked into consuming repos via `.agents/skills/` or `.claude/skills/`.

## Commit Scopes

| Scope | Path | Description |
|-------|------|-------------|
| `analyze` | `skills/analyze/` | The consistency analysis skill |
| `conventional-commits` | `skills/conventional-commits/` | The conventional commits skill |
| `definition-of-done` | `skills/definition-of-done/` | The Definition of Done docs skill |
| `definition-of-ready` | `skills/definition-of-ready/` | The Definition of Ready docs skill |
| `plan` | `skills/plan/` | The technical plan skill |
| `prd` | `skills/prd/` | The PRD skill |
| `prd-to-issues` | `skills/prd-to-issues/` | The PRD-to-issues skill |
| `refine-story` | `skills/refine-story/` | The story refinement skill |
| `user-story` | `skills/user-story/` | The user story skill |
| `repo` | root-level files | Repository config, CI, docs |

As new skills are added, register them here as scopes.

## Conventions

- **Language:** English for all code, docs, and commit messages
- **Commits:** Follow the `conventional-commits` skill in this repo
- **Skills format:** SKILL.md + optional `scripts/`, `references/`, `assets/`
- **No config files for skills** — scopes and settings belong in this file, not in separate JSON
