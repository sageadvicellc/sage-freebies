---
name: render
description: Turns a small structured input into a responsive, self-contained HTML report with light and dark themes, and prints the result as a local file link. Use when the operator asks for a report to back a PR body, a review comment, or any change that needs more room than GitHub renders.
---

## Render a report

The render script is at this path:

`${CLAUDE_PLUGIN_ROOT}/scripts/render-report.sh`

This skill runs POSIX shell commands on a POSIX path. Run it on macOS,
Linux, or WSL. On native Windows, the path check below stops it.

Before any step, check the path above. It must start with `/`, and it
must not hold the text `${` or a single quote. If it fails a check,
stop, and tell the operator in one line.

The default output is a local file only, printed as a `file://` link.
This plugin has no opinion on where a report should be hosted so that
someone else can open it, especially one built from private-repository
content: that is an open, operator-level decision. This skill never
uploads, pushes, publishes, or hosts the file anywhere on its own. Give
the operator the printed link and stop there.

## Input format

Build a small plain-text input, one line at a time:

- A line starting with `## ` is a section heading.
- A line starting with `- ` is a list item. Consecutive `- ` lines
  group into one list.
- A blank line ends the current list, if one is open.
- Any other non-blank line is a paragraph.

## Steps

1. Write the input as a here-document, a temp file, or hold it ready to
   pipe. Every piece of text in it is HTML-escaped by the script before
   it reaches the report, so an issue title or a commit message is safe
   to pass through as written.
2. Run the script with a required title, piping the input in:

   ```sh
   '${CLAUDE_PLUGIN_ROOT}/scripts/render-report.sh' --title "<title>" < input.txt
   ```

   Pass the script path as one single-quoted argument. Add `--out
   <path>` only when the operator names a path. With no `--out`, the
   script writes under `./.sage-crew/reports/` and names the file from
   the title and the current UTC time.
3. The script's only line of stdout, on success, is `file://<absolute
   path>`. Give the operator that line as written.
4. If the script exits with any status other than 0, give the operator
   its one line of stderr as written. Do not retry with different
   flags or quoting.
5. Never rewrite the printed path, guess at one, or turn it into
   another kind of URL. Moving, hosting, or sharing the file beyond the
   operator is a separate decision, and not one this skill makes.

Trigger: the operator asks for a report to back a PR body, a review
comment, or a change that needs more room than GitHub renders.

Writes: one HTML file, at the path `--out` names or the default under
`./.sage-crew/reports/`.
