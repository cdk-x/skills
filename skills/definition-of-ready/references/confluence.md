# Confluence — Definition of Ready page

The Definition of Ready is stored as a Confluence page. This file documents the exact MCP
calls used by the skill.

---

## Resolving space and parent page

### 1. Check configuration first

Look in `AGENTS.md` and `CLAUDE.md` for:
- `Confluence Space` or `Confluence Space Key` → space key (e.g. `TEAM`)
- `Confluence Parent Page` or `Confluence Docs Page` → title of the parent page

### 2. If space is not configured — list available spaces

```
mcp__atlassian__getConfluenceSpaces {}
```

Show the list to the user and ask which space to use.

### 3. If parent page is configured — resolve its ID

Search by title within the resolved space:

```
mcp__atlassian__searchConfluenceUsingCql {
  cql: "title = \"<parent page title>\" AND space = \"<KEY>\" AND type = page"
}
```

Record the parent page `id` from the result. If nothing is found, ask the user to confirm
the exact title.

---

## Searching for an existing DoR page

```
mcp__atlassian__searchConfluenceUsingCql {
  cql: "title = \"Definition of Ready\" AND space = \"<KEY>\" AND type = page"
}
```

If a result is found, record the page `id` and `_links.webui` URL.

---

## Reading the current page content (for updates)

```
mcp__atlassian__getConfluencePage {
  pageId: "<page-id>"
}
```

Read `version.number` — you must increment it by 1 when calling `updateConfluencePage`.

---

## Creating a new page

```
mcp__atlassian__createConfluencePage {
  spaceKey: "<KEY>",
  title: "Definition of Ready",
  content: "<checklist as HTML>",
  parentId: "<parent-page-id>"   ← omit if publishing at space root
}
```

---

## Updating an existing page

```
mcp__atlassian__updateConfluencePage {
  pageId: "<page-id>",
  title: "Definition of Ready",
  content: "<updated checklist as HTML>",
  version: <current version.number + 1>
}
```

---

## Markdown → HTML conversion for the checklist

| Markdown | HTML |
|----------|------|
| `## Heading` | `<h2>Heading</h2>` |
| `### Heading` | `<h3>Heading</h3>` |
| `- [ ] item` | `<ul><li>item</li></ul>` |
| `  - [ ] sub-item` | nested `<ul><li>` inside parent `<li>` |
| `**bold**` | `<strong>bold</strong>` |

Wrap the full checklist in a `<div>` for clean rendering.
