# Publishing to Confluence

## What to collect before publishing

You need three things — resolve each from context before asking:

### 1. Space
Check if the user mentioned a space key or name. If not, list available spaces so they can pick:
```
mcp__atlassian__getConfluenceSpaces
```
Ask: *"Which Confluence space should I publish this to?"* — show the list as options.

### 2. Parent page (optional but almost always needed)
A PRD floating at the root of a space is hard to find. Ask the user if there is a parent page it should live under (e.g. "Product PRDs", "Q2 Features").

If they say yes but don't know the exact name, search within the space:
```
mcp__atlassian__getPagesInConfluenceSpace  { spaceKey: "<key>" }
```
Show the top-level pages as options. If the target is nested deeper, ask the user to confirm the exact path (e.g. "Engineering > Backend > PRDs") and traverse accordingly.

If they say no, publish at the space root.

### 3. Title
Use the feature title from the PRD. Confirm with the user before publishing if it might clash with an existing page name.

## Create the page

Once space, parent (if any), and title are confirmed:
```
mcp__atlassian__createConfluencePage {
  spaceKey: "<key>",
  title: "<feature title>",
  content: "<prd content as HTML or wiki markup>",
  parentId: "<parent page ID>"   ← omit if publishing at root
}
```

### Formatting note
Confluence expects HTML or wiki markup for the `content` field. Convert the Markdown PRD to basic HTML:
- `##` → `<h2>`, `###` → `<h3>`
- `- [ ] item` → `<ul><li>item</li></ul>` (checkboxes render as tasks if wrapped in `<ac:task-list>` tags, but plain lists are fine)
- `**bold**` → `<strong>bold</strong>`

## Report

Tell the user the page title and URL so they can navigate to it or share it.
