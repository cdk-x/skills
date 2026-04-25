---
name: conventional-commits
description: Guide for making atomic commits using Conventional Commits. Scopes are recommended but optional, and can be configured per-repo via .conventional-commits.json. Use this skill whenever the user wants to commit changes, prepare commits, review staged/unstaged changes before committing, plan a commit strategy, set up scope configuration, or asks about commit message format. Triggers on phrases like "commit", "make a commit", "commit changes", "commit scope X", "prepare commits", "commit strategy", "set up scopes", "configure commits", or any intent to record changes in git history. Also use when the user mentions specific scopes to commit (e.g., "commit auth", "commit api and ui"). ALWAYS use this skill even for simple single-file commits — proper format matters every time.
---

# Conventional Commits

Guide for making atomic commits using Conventional Commits. Every commit must be atomic (one logical change) and follow the Conventional Commits format. Scopes are highly recommended but optional — see the Scopes section for details.

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Subject Line

- **Maximum 72 characters** (type + scope + colon + space + subject combined)
- **Lowercase** — no capitalized first letter, no trailing period
- **Imperative mood** — "add", "fix", "update" (not "added", "fixes", "updating")
- Be specific but concise

### Body (Optional)

Use the body when the subject alone doesn't explain **why** the change was made or **what** the broader context is. Wrap lines at 72 characters. Separate from subject with a blank line.

```
fix(api): resolve race condition on concurrent requests

The mutex was released before the transaction committed,
allowing a second request to read stale data. Hold the lock
until the transaction is confirmed.
```

### Footer (Optional)

Use footers for metadata. The Conventional Commits spec defines a `key: value` or `key #value` format.

#### Breaking Changes

| Footer | Purpose | Example |
|---|---|---|
| `BREAKING CHANGE:` | Signals a breaking API change | `BREAKING CHANGE: remove deprecated auth() options` |

#### Issue References

Link commits to the issue they implement or fix. The exact syntax depends on your issue tracker — see the `issueTracker` config in `.conventional-commits.json` and `references/issue-tracking.md` for full details.

**GitHub Issues (default):**
```
feat(auth): add OAuth2 PKCE flow

Implement the PKCE authorization code flow as specified
in the security review.

Refs: #142
```

**Jira:**
```
feat(auth): add OAuth2 PKCE flow

Implement the PKCE authorization code flow as specified
in the security review.

Refs: PROJ-142
```

`Refs:` and `Closes:` / `Fixes:` serve different purposes:

| Footer | Behavior | When to use |
|---|---|---|
| `Refs: #123` | Links to the issue, no automation | The commit relates to the issue but doesn't complete it |
| `Closes: #123` | Links AND auto-closes the issue on merge (GitHub only) | The commit fully resolves the issue |
| `Fixes: #123` | Same as `Closes:` (GitHub alias) | Alternative wording for `Closes:` |

In practice, prefer `Refs:` in individual commits and let the **PR description** handle auto-closing. This avoids premature closure when a feature needs multiple commits across branches.

#### Issue Detection During Commit

When preparing commits, the skill will try to detect the relevant issue:

1. **Check the current branch name** — branches like `feature/PROJ-142-oauth-pkce` or `bugfix/123-null-pointer` contain issue references
2. **Check `.conventional-commits.json`** for `issueTracker` config
3. **Ask the user** if no issue is detected and one might be relevant

For GitHub repos with `gh` CLI available, you can look up issues:
```bash
gh issue list --state open --limit 10     # recent open issues
gh issue view 142                          # specific issue details
```

For details on Jira integration and PR description templates, read `references/issue-tracking.md`.

### Breaking Changes

Breaking changes can be signaled two ways (use both together for clarity):

1. **Footer**: `BREAKING CHANGE: description of what breaks`
2. **Exclamation mark** after the scope: `feat(auth)!: remove deprecated login options`

```
feat(auth)!: remove deprecated login options

The `legacyMode` and `implicitGrant` options have been removed
from the authenticate() API. Use `grantType: 'pkce'` instead.

BREAKING CHANGE: authenticate() no longer accepts `legacyMode`
or `implicitGrant` options. Migrate to `grantType: 'pkce'`.
```

## Types

| Type       | When to use                                                        |
|------------|--------------------------------------------------------------------|
| `feat`     | New functionality visible to users or consumers of the package     |
| `fix`      | Bug fixes                                                          |
| `docs`     | Documentation-only changes (README, JSDoc, inline docs)            |
| `style`    | Formatting changes (prettier, whitespace) that don't affect logic  |
| `refactor` | Code restructuring that neither adds features nor fixes bugs       |
| `perf`     | Performance improvements without changing behavior                 |
| `test`     | Adding or modifying tests (specs, snapshots, test utilities)       |
| `build`    | Changes to build system or external dependencies                   |
| `chore`    | Maintenance tasks, configs, tooling, dependency bumps              |
| `ci`       | CI/CD pipeline changes (GitHub Actions, workflows, CI configs)     |
| `revert`   | Reverts a previous commit (reference the reverted SHA in the body) |
| `wip`      | Work in progress — temporary, not intended for release             |

## Scopes

Scopes add context about **what area** of the codebase a commit affects. They are **highly recommended** but **optional** — a commit like `fix: resolve null pointer on startup` is valid. However, scopes become essential as a project grows because they make history searchable, changelogs readable, and reverts targeted.

When using scopes: never mix more than one scope in the same commit — if changes touch multiple packages or modules, create one commit per scope.

### Scope Configuration

Scopes can be defined explicitly or discovered automatically. The skill checks for configuration in this order:

#### 1. Explicit Configuration (`.conventional-commits.json`)

If a `.conventional-commits.json` file exists at the repo root, use it as the source of truth for scopes:

```json
{
  "scopes": {
    "auth": { "paths": ["src/auth/**", "packages/auth/**"] },
    "api": { "paths": ["src/api/**", "packages/api/**"] },
    "ui": { "paths": ["src/ui/**", "packages/ui/**"] },
    "repo": { "paths": [".github/**", "*.json", "*.yml", "Dockerfile"] }
  },
  "requireScope": true,
  "issueTracker": {
    "type": "github"
  }
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `scopes` | `object` | — | Map of scope name → `{ paths: string[] }`. Paths use glob patterns relative to repo root. |
| `requireScope` | `boolean` | `false` | If `true`, every commit must include a scope. If `false`, scopes are recommended but optional. |
| `issueTracker` | `object` | `{ "type": "github" }` | Issue tracker configuration. See `references/issue-tracking.md` for all options. |
| `issueTracker.type` | `string` | `"github"` | `"github"`, `"jira"`, or `"none"`. |
| `issueTracker.jiraProjectKey` | `string` | — | Required when type is `"jira"`. The project key (e.g., `"PROJ"`). |
| `issueTracker.jiraBaseUrl` | `string` | — | Optional Jira instance URL for generating links (e.g., `"https://mycompany.atlassian.net"`). |

When this file exists, only the defined scopes are valid. If a modified file doesn't match any scope pattern, ask the user whether to add a new scope to the config or commit without scope.

#### 2. Automatic Discovery (No Config File)

When no config file exists, infer scopes from the repository structure:

| Repository layout | Scope strategy |
|---|---|
| Monorepo with `packages/` | Each package directory → scope (e.g., `packages/auth/` → `auth`) |
| Monorepo with `apps/` and `libs/` | Each app/lib directory → scope (e.g., `apps/web/` → `web`) |
| Single-package with `src/` modules | Top-level feature directories → scope (e.g., `src/auth/` → `auth`) |
| Simple/flat repo | Scope is optional; use module or file area if meaningful |
| Root-level files | Use `repo`, `root`, or the project name |

### Suggesting Scope Setup

When committing for the first time in a repo without `.conventional-commits.json`, analyze the project structure and **offer to generate the config file**:

1. Inspect the repo layout (`ls`, `find`, `package.json` workspaces field)
2. Propose a scope map based on what you find
3. Ask the user to confirm or adjust
4. Write `.conventional-commits.json` if the user agrees

This creates a shared convention for the team. For detailed scope strategy guidance by repo type, read `references/scope-strategy.md`.

### File-to-Scope Resolution

Determine the scope from the file path. When a config file exists, match against the glob patterns. Otherwise, match the most specific directory:

**Monorepo:**
```
packages/auth/src/login.ts        → auth
packages/api/src/routes/users.ts  → api
libs/shared/src/utils.ts          → shared
apps/web/src/App.tsx              → web
```

**Single-package:**
```
src/auth/login.ts                 → auth
src/database/models/user.ts       → database
```

**Root-level:**
```
package.json                      → repo
.github/workflows/ci.yml          → ci (or repo)
Dockerfile                        → repo
```

**No clear scope:**
```
README.md                         → (no scope) docs: update README
utils.ts                          → (ask user or omit scope)
```

When the scope is ambiguous, ask the user. When no scope makes sense (e.g., a tiny repo with one module), omit it — that's fine.

## Scope Selection Modes

The skill supports three modes based on user input:

### Mode 1: All Scopes (Default)

When no specific scope is mentioned, analyze ALL modified files and propose commits for every scope with changes. Process scopes in a logical dependency order (lower-level / shared packages first, then higher-level / application packages).

### Mode 2: Single Scope

When the user specifies one scope (e.g., "commit auth"), filter to ONLY that scope and ignore all other changes.

### Mode 3: Multiple Scopes

When the user specifies multiple scopes (e.g., "commit auth and api"), filter to those scopes only and process them in dependency order.

### Scope Parsing

Extract scope names from user input. Support natural language separators: "and", "y", "e", ",", "&".

**Examples:**
- "auth" → `[auth]`
- "auth and api" → `[auth, api]`
- "core, utils and api" → `[core, utils, api]`
- "core & shared" → `[core, shared]`
- No scopes detected → Mode 1 (All Scopes)

## Atomic Commits

Each commit represents **one logical change**. This is the most important principle — it makes history readable, reverts safe, and reviews focused.

**Splitting heuristic:** If you need "and" in the subject, it's probably two commits.

### Related Changes Across Types

When a feature includes its tests and docs, split into separate commits ordered by dependency:

```bash
# 1. The feature itself
git commit -m "feat(auth): add OAuth2 PKCE flow support"

# 2. Tests for that feature
git commit -m "test(auth): add PKCE flow integration tests"

# 3. Documentation for that feature
git commit -m "docs(auth): document OAuth2 PKCE configuration"
```

This ordering matters because each commit should be independently valid — tests shouldn't reference code that doesn't exist yet in the history.

## Commit Workflow

### Step 1: Detect Mode and Scopes

Parse the user's request to determine the mode and target scopes.

### Step 2: Analyze Changes

Run the analysis script to get all changed files grouped by scope, with issue detection from the branch name:

```bash
bash <skill-path>/scripts/analyze-changes.sh
# Or filter to specific scopes:
bash <skill-path>/scripts/analyze-changes.sh --scope auth,api
```

The script outputs JSON with:
- `branch` — current branch name
- `issueRef` — issue reference extracted from branch (e.g., `#142` or `PROJ-142`)
- `issueTracker` — tracker type from config (`github`, `jira`, `none`)
- `configFound` — whether `.conventional-commits.json` exists
- `requireScope` — whether scopes are mandatory
- `stagedFiles` — files already in the staging area
- `scopeGroups` — files grouped by scope, each with `path` and `status` (staged/modified/untracked)
- `totalFiles` — total number of changed files

If files are already staged (`stagedFiles` is non-empty), acknowledge them and ask the user whether to include them in the plan or reset them first.

Then inspect the actual diffs to understand what changed (needed for type assignment and splitting):

```bash
git diff --stat
git diff
```

### Step 3: Group by Scope and Type

For each target scope, group changes by commit type. Within a scope, further split if there are multiple logical changes of the same type (e.g., two independent bug fixes in the same package → two `fix` commits).

### Step 4: Propose the Plan

Present a clear commit plan before executing anything. For each proposed commit, show:

1. The full commit message (including body if warranted)
2. The exact files to be staged
3. Whether `git add -p` is needed (when a file contains changes for different commits)

**Example plan format:**

```
Commit Plan (3 commits):

1. feat(auth): add token refresh middleware
   Files:
     git add src/auth/refresh.ts
     git add src/auth/index.ts

2. test(auth): add unit tests for token refresh
   Files:
     git add src/auth/refresh.spec.ts

3. fix(api): handle undefined user references in handler
   Files:
     git add -p src/api/users/handler.ts  ← only the bug fix hunks
```

Wait for user confirmation before executing. If the user wants changes, adjust the plan.

### Step 5: Execute Commits

Stage files **individually** — never use `git add .` or `git add -A` when there are multiple scopes or logical changes. This prevents accidentally including unrelated changes.

```bash
git add src/auth/refresh.ts
git add src/auth/index.ts
git commit -m "feat(auth): add token refresh middleware"
```

**Using `git add -p` (patch mode):** When a single file contains changes that belong to different commits, use interactive patch mode to stage only the relevant hunks:

```bash
git add -p src/api/users/handler.ts
```

Patch mode presents each hunk and asks what to do. Key commands:

| Key | Action |
|-----|--------|
| `y` | Stage this hunk |
| `n` | Skip this hunk |
| `s` | **Split** the hunk into smaller hunks (when git groups too many changes together) |
| `e` | **Edit** the hunk manually — opens an editor where you can delete `-` lines to keep them unchanged, or delete `+` lines to exclude them from staging. This is the line-level control for when `s` isn't granular enough |
| `q` | Quit (stop staging) |

**Line-level staging with `e` (edit mode):** When changes within a hunk are interleaved and `s` can't split them further, `e` lets you pick individual lines:

1. Git opens the hunk in your editor
2. Lines starting with `-` are deletions — remove the line entirely to **keep** the original code unstaged
3. Lines starting with `+` are additions — remove the line to **exclude** it from staging
4. Lines starting with ` ` (space) are context — don't touch them
5. Save and close — only the remaining changes get staged

This is the answer when a file has two logically different changes touching nearby lines. Walk the user through which hunks to accept or edit.

### Step 6: Verify After Each Commit

After every commit, verify it contains exactly what was intended:

```bash
git log -1 --stat    # verify the commit content
git status           # see remaining uncommitted changes
```

If something looks wrong, offer to amend (`git commit --amend`) or reset (`git reset HEAD~1`) before proceeding to the next commit.

### Step 7: Final Summary

After all commits are done, show a summary:

```bash
git log --oneline -<N>   # show the N commits just created
```

## Dry-Run Mode

When the user asks to "review", "check", "analyze", or "plan" commits without actually making them, operate in dry-run mode:

- Perform Steps 1–4 (analyze and propose the plan)
- Skip Steps 5–7 (don't execute anything)
- Clearly state that no commits were made

This lets the user review the strategy before committing.

## Edge Cases

### Untracked Files

New files show up in `git status` but not in `git diff`. Use `git diff --no-index /dev/null <file>` or just `cat` to inspect their content for proper scope and type assignment.

### Renamed/Moved Files

Git may detect renames. These typically belong to `refactor` type unless the rename is part of a larger feature.

### Merge Conflicts in Staging

If the working tree has conflicts, resolve them before attempting to commit. Do not commit files with conflict markers.

### Empty Commits

Never create empty commits. If `git add` results in nothing staged, skip that commit and inform the user.

### Mixed Changes in One File

When a single file has changes that belong to different logical commits:

1. **Separate hunks** → use `git add -p` and stage with `y`/`n`
2. **One hunk, but splittable** → use `s` in patch mode to split into smaller hunks
3. **Interleaved lines in the same hunk** → use `e` in patch mode to edit the hunk and pick individual lines
4. **Truly inseparable** → commit together with the most appropriate type and explain in the body why the changes are combined

## Common Mistakes

These are the patterns that most often lead to messy history:

1. **Mixing scopes** — one commit touching `packages/core/` and `packages/cli/` should always be split
2. **Using "and" in the subject** — "add feature and fix bug" is two commits
3. **Blind `git add .`** — always review what's being staged
4. **Wrong type** — `feat` for a bug fix, `chore` for a new feature, `refactor` that changes behavior
5. **Non-imperative mood** — "added support" instead of "add support"
6. **Subject over 72 chars** — truncate or rephrase
7. **Adding AI co-author trailers** — NEVER add `Co-Authored-By: Claude` or any AI assistant attribution to commits or PR descriptions
8. **Staging already-committed changes** — always check `git status` before starting
