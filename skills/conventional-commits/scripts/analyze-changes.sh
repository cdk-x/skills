#!/usr/bin/env bash
# analyze-changes.sh — Analyze git changes and group by scope
#
# Reads .conventional-commits.json (if present) for scope definitions,
# otherwise auto-discovers scopes from the repository structure.
# Outputs a JSON object with changes grouped by scope, issue references
# extracted from the branch name, and staging status.
#
# Usage:
#   bash analyze-changes.sh [--scope scope1,scope2]
#
# Options:
#   --scope scope1,scope2   Filter to specific scopes (comma-separated)
#
# Output (JSON):
#   {
#     "branch": "feature/142-oauth-pkce",
#     "issueRef": "#142",
#     "issueTracker": "github",
#     "configFound": true,
#     "requireScope": true,
#     "stagedFiles": [...],
#     "scopeGroups": [
#       { "scope": "auth", "files": [...] },
#       { "scope": "api", "files": [...] },
#       { "scope": null, "files": [...] }
#     ]
#   }

set -euo pipefail

# --- Parse arguments ---
FILTER_SCOPES=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      FILTER_SCOPES="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# --- Ensure we're in a git repo ---
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo '{"error": "Not inside a git repository"}' 
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
CONFIG_FILE="$REPO_ROOT/.conventional-commits.json"

# --- Get branch name and extract issue reference ---
BRANCH="$(git branch --show-current 2>/dev/null || echo "")"

ISSUE_REF=""
ISSUE_TRACKER="github"
JIRA_PROJECT_KEY=""
JIRA_BASE_URL=""

# Read issue tracker config if available
if [[ -f "$CONFIG_FILE" ]]; then
  CONFIG_FOUND=true
  REQUIRE_SCOPE=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    print(str(c.get('requireScope', False)).lower())
except: print('false')
" 2>/dev/null || echo "false")

  ISSUE_TRACKER=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    print(c.get('issueTracker', {}).get('type', 'github'))
except: print('github')
" 2>/dev/null || echo "github")

  JIRA_PROJECT_KEY=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    print(c.get('issueTracker', {}).get('jiraProjectKey', ''))
except: print('')
" 2>/dev/null || echo "")

  JIRA_BASE_URL=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    print(c.get('issueTracker', {}).get('jiraBaseUrl', ''))
except: print('')
" 2>/dev/null || echo "")
else
  CONFIG_FOUND=false
  REQUIRE_SCOPE="false"
fi

# Extract issue reference from branch name
if [[ -n "$BRANCH" ]]; then
  if [[ "$ISSUE_TRACKER" == "jira" ]]; then
    ISSUE_REF=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1 || echo "")
  else
    # GitHub: extract number after prefix (feature/142-xxx → 142)
    ISSUE_REF=$(echo "$BRANCH" | sed 's|^[^/]*/||' | grep -oE '^[0-9]+' | head -1 || echo "")
    if [[ -n "$ISSUE_REF" ]]; then
      ISSUE_REF="#$ISSUE_REF"
    fi
  fi
fi

# --- Get changed files ---
# Staged files
STAGED_FILES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && STAGED_FILES+=("$line")
done < <(git diff --cached --name-only 2>/dev/null)

# Unstaged tracked files (modified, deleted)
UNSTAGED_FILES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && UNSTAGED_FILES+=("$line")
done < <(git diff --name-only 2>/dev/null)

# Untracked files
UNTRACKED_FILES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && UNTRACKED_FILES+=("$line")
done < <(git ls-files --others --exclude-standard 2>/dev/null)

# Combine all changed files (deduplicated)
ALL_FILES=()
declare -A SEEN_FILES
declare -A FILE_STATUS

for f in "${STAGED_FILES[@]}"; do
  if [[ -z "${SEEN_FILES[$f]:-}" ]]; then
    ALL_FILES+=("$f")
    SEEN_FILES[$f]=1
    FILE_STATUS[$f]="staged"
  fi
done
for f in "${UNSTAGED_FILES[@]}"; do
  if [[ -z "${SEEN_FILES[$f]:-}" ]]; then
    ALL_FILES+=("$f")
    SEEN_FILES[$f]=1
    FILE_STATUS[$f]="modified"
  fi
done
for f in "${UNTRACKED_FILES[@]}"; do
  if [[ -z "${SEEN_FILES[$f]:-}" ]]; then
    ALL_FILES+=("$f")
    SEEN_FILES[$f]=1
    FILE_STATUS[$f]="untracked"
  fi
done

if [[ ${#ALL_FILES[@]} -eq 0 ]]; then
  # No changes — output minimal JSON
  python3 -c "
import json
print(json.dumps({
    'branch': '$BRANCH',
    'issueRef': '$ISSUE_REF',
    'issueTracker': '$ISSUE_TRACKER',
    'configFound': $CONFIG_FOUND,
    'requireScope': $REQUIRE_SCOPE,
    'stagedFiles': [],
    'scopeGroups': [],
    'totalFiles': 0
}, indent=2))
"
  exit 0
fi

# --- Resolve file-to-scope mapping ---

# Build scope resolution data
if [[ "$CONFIG_FOUND" == "true" ]]; then
  # Use config file for scope resolution
  SCOPE_JSON=$(python3 -c "
import json, sys, fnmatch, os

config = json.load(open('$CONFIG_FILE'))
scopes = config.get('scopes', {})

# Build scope patterns
scope_patterns = {}
for scope_name, scope_def in scopes.items():
    scope_patterns[scope_name] = scope_def.get('paths', [])

print(json.dumps(scope_patterns))
" 2>/dev/null || echo "{}")
else
  # Auto-discover scopes from repo structure
  SCOPE_JSON=$(python3 -c "
import json, os

root = '$REPO_ROOT'
scopes = {}

# Check for monorepo patterns
for parent in ['packages', 'apps', 'libs', 'services']:
    parent_path = os.path.join(root, parent)
    if os.path.isdir(parent_path):
        for entry in sorted(os.listdir(parent_path)):
            full = os.path.join(parent_path, entry)
            if os.path.isdir(full) and not entry.startswith('.'):
                scopes[entry] = [f'{parent}/{entry}/**']

# Check for nested providers/tools pattern
for parent in ['packages/providers', 'packages/tools']:
    parent_path = os.path.join(root, parent)
    if os.path.isdir(parent_path):
        for entry in sorted(os.listdir(parent_path)):
            full = os.path.join(parent_path, entry)
            if os.path.isdir(full) and not entry.startswith('.'):
                scopes[entry] = [f'{parent}/{entry}/**']

# If no packages found, check src/ for feature directories
if not scopes:
    src_path = os.path.join(root, 'src')
    if os.path.isdir(src_path):
        for entry in sorted(os.listdir(src_path)):
            full = os.path.join(src_path, entry)
            if os.path.isdir(full) and not entry.startswith('.'):
                scopes[entry] = [f'src/{entry}/**']

print(json.dumps(scopes))
" 2>/dev/null || echo "{}")
fi

# --- Match files to scopes and output JSON ---

# Write file list to temp file for python to read
TMPFILE=$(mktemp)
for f in "${ALL_FILES[@]}"; do
  echo "${FILE_STATUS[$f]}	$f" >> "$TMPFILE"
done

python3 -c "
import json, fnmatch, sys

scope_patterns = json.loads('$SCOPE_JSON')
filter_scopes_raw = '$FILTER_SCOPES'
filter_scopes = [s.strip() for s in filter_scopes_raw.split(',') if s.strip()] if filter_scopes_raw else []

# Read files
files = []
with open('$TMPFILE') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        status, filepath = line.split('\t', 1)
        files.append({'path': filepath, 'status': status})

# Match each file to a scope
def match_scope(filepath):
    best_scope = None
    best_length = 0
    for scope_name, patterns in scope_patterns.items():
        for pattern in patterns:
            if fnmatch.fnmatch(filepath, pattern):
                # Prefer the most specific match (longest pattern)
                if len(pattern) > best_length:
                    best_scope = scope_name
                    best_length = len(pattern)
    return best_scope

scope_groups = {}
for file_info in files:
    scope = match_scope(file_info['path'])
    
    # Apply scope filter if specified
    if filter_scopes:
        if scope not in filter_scopes:
            continue
    
    scope_key = scope if scope else '__unscoped__'
    if scope_key not in scope_groups:
        scope_groups[scope_key] = []
    scope_groups[scope_key].append(file_info)

# Build output
groups_list = []
for scope_key in sorted(scope_groups.keys()):
    groups_list.append({
        'scope': None if scope_key == '__unscoped__' else scope_key,
        'files': sorted(scope_groups[scope_key], key=lambda x: x['path'])
    })

# Staged files list
staged = [f['path'] for f in files if f['status'] == 'staged']

output = {
    'branch': '$BRANCH',
    'issueRef': '$ISSUE_REF',
    'issueTracker': '$ISSUE_TRACKER',
    'configFound': True if '$CONFIG_FOUND' == 'true' else False,
    'requireScope': True if '$REQUIRE_SCOPE' == 'true' else False,
    'stagedFiles': staged,
    'scopeGroups': groups_list,
    'totalFiles': sum(len(g['files']) for g in groups_list)
}

print(json.dumps(output, indent=2))
" 

rm -f "$TMPFILE"
