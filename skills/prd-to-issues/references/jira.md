# Jira — Create Stories and Tasks

## Prerequisites

Before creating any issues, collect three things:

**1. Project key** — ask the user if not already in context. You can list available projects:
```
mcp__atlassian__getVisibleJiraProjects {}
```

**2. Available issue types** — verify the project has Story and Task types:
```
mcp__atlassian__getJiraProjectIssueTypesMetadata { projectKey: "<key>" }
```

If Story or Task are not available, ask the user which types to use as substitutes.

**3. Epic context** — see the "Resolving the Epic" section below before creating any Stories.

---

## Resolving the Epic

User stories belong to a feature. Before creating Stories, find out which Epic covers this feature — or whether a new Epic is needed.

### Step 1 — Search for existing Epics

```
mcp__atlassian__searchJiraIssuesUsingJql {
  jql: "project = \"<key>\" AND issuetype = Epic ORDER BY created DESC",
  fields: ["summary", "status", "key"]
}
```

### Step 2 — Present findings and ask

- If relevant Epics are found, list them and ask: *"Do any of these Epics cover this feature, or should I create a new one?"*
- If no Epics are found, ask: *"No Epics exist yet in this project. Should I create one for this feature before adding the Stories, or skip it?"*
- If the user already mentioned an Epic key or name in the conversation, use that directly.

### Step 3 — Create a new Epic if needed

If the user wants a new Epic:
```
mcp__atlassian__createJiraIssue {
  projectKey: "<key>",
  issueType: "Epic",
  summary: "<feature name>",
  description: {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "PRD: <source PRD URL or issue reference>" }
        ]
      }
    ]
  }
}
```

Record the Epic key (e.g., `PROJ-5`) — you will set it as the parent when creating Stories.

### Step 4 — Discover the Epic link field

Jira's field for linking a Story to an Epic varies by project type. Fetch the Story creation metadata to find the correct field:
```
mcp__atlassian__getJiraIssueTypeMetaWithFields {
  projectKey: "<key>",
  issueTypeName: "Story"
}
```

Look for a field whose name contains "Epic" (commonly `customfield_10014` in classic projects, or `parent` in team-managed projects). Record the field key — you'll use it when creating Stories.

---

## Creation order

Always create in this order so you can reference real keys when setting up links:
1. Epic (resolved or created in the previous section)
2. Stories (one per PRD user story), linked to the Epic
3. Tasks (one per implementation slice), in dependency order (blockers first)
4. Links between issues

---

## Creating User Stories

For each PRD user story, create a Jira Story. The summary should preserve the "As a / I want / so that" format from the PRD — it communicates intent clearly to both product and engineering.

Include the Epic field discovered in the "Resolving the Epic" step. Use `parent` for team-managed projects or the custom field key (e.g., `customfield_10014`) for classic projects:

```
mcp__atlassian__createJiraIssue {
  projectKey: "<key>",
  issueType: "Story",
  summary: "As a <user>, I want <action> so that <value>",
  description: {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "PRD: <source PRD URL or issue reference>\n\n" },
          { "type": "text", "text": "Acceptance criteria:\n" },
          { "type": "text", "text": "- <criterion 1>\n- <criterion 2>" }
        ]
      }
    ]
  },
  "<epic-field-key>": "<epic-key>"
}
```

If the field is `parent`, the value should be the Epic key string (e.g., `"PROJ-5"`). If it's a custom field like `customfield_10014`, the value is also the Epic key string.

Record the returned issue key (e.g., `PROJ-10`) — you'll need it to link Tasks.

---

## Creating Tasks (implementation slices)

For each vertical slice, create a Jira Task. Include a reference to which Stories it advances so developers understand the user value they're delivering.

```
mcp__atlassian__createJiraIssue {
  projectKey: "<key>",
  issueType: "Task",
  summary: "<slice title>",
  description: {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "PRD: <source PRD URL or issue reference>\n\n" },
          { "type": "text", "text": "What to build\n<end-to-end behavior description>\n\n" },
          { "type": "text", "text": "Acceptance criteria\n- <criterion 1>\n- <criterion 2>\n\n" },
          { "type": "text", "text": "User stories addressed: <PROJ-10>, <PROJ-11>\n\n" },
          { "type": "text", "text": "Type: AFK | HITL" }
        ]
      }
    ]
  }
}
```

---

## Linking issues

### Step 1 — Get available link types

Different Jira instances have different link type names. Always fetch first:
```
mcp__atlassian__getIssueLinkTypes {}
```

Look for equivalents of:
- `Blocks` / `is blocked by` — strict ordering dependency
- `Relates` — soft relationship, no ordering constraint

### Step 2 — Link Tasks to their parent Stories

Use "Relates" to connect each Task to the Story (or Stories) it advances:
```
mcp__atlassian__createIssueLink {
  linkType: "Relates",
  inwardIssueKey: "<story-key>",
  outwardIssueKey: "<task-key>"
}
```

### Step 3 — Set blocking dependencies between Tasks

For each pair where Task A must complete before Task B can start:
```
mcp__atlassian__createIssueLink {
  linkType: "Blocks",
  inwardIssueKey: "<blocker-task-key>",
  outwardIssueKey: "<blocked-task-key>"
}
```

This creates the relationship: `<blocker> blocks <blocked>` / `<blocked> is blocked by <blocker>`.

---

## Linking to the source PRD

Always include the source PRD reference in every issue description (see templates above). This lets any developer trace back to the full requirements without hunting through Slack or email.

- If the PRD is a **Confluence page**: include the full page URL
- If the PRD is a **GitHub issue**: include the issue URL (e.g., `https://github.com/org/repo/issues/42`)

---

## Reporting

After all issues are created and linked, report a summary:

```
Epic:
  PROJ-5  — <Epic title> → <url>   (existing | created)

Stories created (under PROJ-5):
  PROJ-10 — As a user, I want X ... → <url>
  PROJ-11 — As a user, I want Y ... → <url>

Tasks created:
  PROJ-12 — Slice: <title> (relates to PROJ-10) → <url>
  PROJ-13 — Slice: <title> (relates to PROJ-10, PROJ-11; blocked by PROJ-12) → <url>

Links established:
  PROJ-10 → Epic PROJ-5
  PROJ-11 → Epic PROJ-5
  PROJ-12 relates to PROJ-10
  PROJ-13 relates to PROJ-10, PROJ-11
  PROJ-12 blocks PROJ-13
```
