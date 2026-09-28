---
name: reporting-table
description: Writes every report to the operator as one status table with red, yellow, and green rows, and keeps messages between roles to one line per change. Use when a trellis-crew reporting chain reports to the operator, or takes a report from another role.
---

## The status table

Every report to the operator is one table, with at most one line of
prose above it:

| # | Status | Item | Link | Their action |
|---|---|---|---|---|

- 🔴 needs the operator now. 🟡 needs the operator, not urgently. 🟢
  needs nothing from them. Rows sort red, then yellow, then green.
- The link is the exact item: a comment URL for a decision, the pull
  request or issue URL otherwise. Use short link text and the full URL
  as the target.
- "Their action" is one imperative line, or "Nothing".

## Light communication

- Accept one line per change from each role: worker, task, URL, state.
- Send detail and evidence to the item's comments, never into a
  message.
- Never post a comment that is only a letter token, such as "1A".

Trigger: a report goes to the operator, or a role reports a change.

Writes: one status table per report.
