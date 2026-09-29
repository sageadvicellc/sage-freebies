---
name: report-templates
description: Templates for PR bodies and review comments that stay inside what GitHub renders, with an optional link to a sage-crew:render report for full design control. Use when writing a PR body or a review comment in a trellis-crew team.
---

## What GitHub allows

Tested live against GitHub's own renderer: `style`, `class`, and any
`<style>` block are stripped from a PR body or a comment, and the
`<style>` block's text shows through as plain text. Inline `<svg>` is
stripped too. A PR body or a review comment must never rely on any of
the three for its design. It must also never embed an image hosted
only in a private repository: GitHub's camo proxy cannot fetch it, and
the image will not load for anyone who opens the item.

For anything needing custom design control, use the `sage-crew:render`
skill to write a separate, self-contained HTML report, and link it.

For a decision comment, use the `sage-crew:lead-decisions` skill
instead. It owns that template in full, and this skill does not
repeat it.

## PR body template

```
1. <what changed, one line>
2. <what changed, one line>

> [!NOTE]
> <context the operator needs, if any>

> [!IMPORTANT]
> <something only the operator can act on, if any>

Verified: <what was checked, and how>

Report: <link to the sage-crew:render output, only when one exists>
```

- Open with a short numbered list of what changed, one line per
  change.
- Add a `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, or `> [!CAUTION]`
  block for anything that needs the operator's attention. Match the
  word to the weight of the point: `NOTE` or `TIP` for context,
  `IMPORTANT` for an action only the operator can take, `CAUTION` for
  a risk.
- State what was verified, in one line.
- Add the report line only when a `sage-crew:render` report exists for
  this change. Link it as further detail, never as a replacement for
  the list or the alert blocks above.

## Review comment template

```
> [!<alert word>]
> <one line naming the finding>

Severity: <critical | high | medium | low>
Fix: <one line>

Report: <link to the sage-crew:render output, only when one exists>
```

- One finding per comment.
- Match the alert word to the finding: `CAUTION` for a security or
  correctness risk, `IMPORTANT` for something that blocks the change,
  `NOTE` or `TIP` for a suggestion.
- Name the severity word plainly, and give the fix in one line.
- Add the report line only when the supporting evidence is too long
  for the comment itself.

Trigger: writing a PR body or a review comment in a trellis-crew team.

Writes: nothing on its own. The session posting the body or the
comment fills these templates in and writes them.
