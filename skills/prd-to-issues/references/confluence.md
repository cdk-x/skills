# Confluence — Fetch PRD

## Resolving the page identifier

You need the page ID. Resolve it from context in this order:

### 1. URL provided
Extract the numeric page ID from the URL (the segment after `/pages/`):
```
https://your-org.atlassian.net/wiki/spaces/SPACE/pages/123456789/Page+Title
                                                              ^^^^^^^^^
```

### 2. Title or search term provided
Search for the page:
```
mcp__atlassian__searchConfluenceUsingCql {
  cql: "title = \"<page title>\" AND type = page"
}
```

### 3. Neither — ask
Ask: *"What's the title or URL of the Confluence PRD page?"*

---

## Reading the PRD content

```
mcp__atlassian__getConfluencePage { pageId: "<id>" }
```

The `body.storage.value` field contains the page HTML. Read it carefully — extract:
- User stories (usually in a table or bulleted list)
- Functional and non-functional requirements
- Acceptance criteria
- Any stated constraints or assumptions

---

## Linking back to the PRD in created issues

When creating Jira issues, include the Confluence page URL in every issue description so developers can trace back to the full PRD context. Format it as:

> **PRD**: [Page Title](https://your-org.atlassian.net/wiki/spaces/.../pages/<id>)

When creating GitHub issues, include the Confluence page URL in the "Parent PRD" section of the issue body.
