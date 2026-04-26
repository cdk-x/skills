# Publishing to GitHub Issues

## What to collect before publishing

No extra input needed beyond the PRD content. The issue title comes from the PRD, the label is always `prd`.

If the `prd` label does not exist in the repo, create it first:
```bash
gh label create prd --color 0075ca --description "Product Requirements Document" 2>/dev/null || true
```

## Create the issue

```bash
gh issue create --title "<feature title>" --label prd --body "$(cat <<'EOF'
<prd content>
EOF
)"
```

## Report

Tell the user the issue number and URL so they can share or reference it.
