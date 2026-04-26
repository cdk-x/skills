# cdk-x/skills

Shared collection of agent skills for the cdk-x organization. Each skill is a self-contained package under `skills/` following the [agentskills.io](https://agentskills.io) spec.

## Repository Structure

```
skills/
├── conventional-commits/   → Atomic commits with Conventional Commits format
├── plan/                   → Technical plan generation from specs
├── prd/                    → Product Requirements Document generation and publishing
└── (future skills)
```

Skills are symlinked into consuming repos via `.agents/skills/` or `.claude/skills/`.

## Commit Scopes

| Scope | Path | Description |
|-------|------|-------------|
| `conventional-commits` | `skills/conventional-commits/` | The conventional commits skill |
| `plan` | `skills/plan/` | The technical plan skill |
| `prd` | `skills/prd/` | The PRD skill |
| `repo` | root-level files | Repository config, CI, docs |

As new skills are added, register them here as scopes.

## Conventions

- **Language:** English for all code, docs, and commit messages
- **Commits:** Follow the `conventional-commits` skill in this repo
- **Skills format:** SKILL.md + optional `scripts/`, `references/`, `assets/`
- **No config files for skills** — scopes and settings belong in this file, not in separate JSON
