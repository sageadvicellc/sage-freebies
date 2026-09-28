---
name: eject
description: Copies the sage-crew roles file into the current folder as sagespec.yml, so the operator can edit it and run trellis-crew directly. Use when the operator asks to eject sage-crew or to own the team layout.
---

## Eject the preset

The sage-crew roles file is at this path:

`${CLAUDE_PLUGIN_ROOT}/sagespec.yml`

1. If `sagespec.yml` already exists in the current folder, stop. Tell
   the operator in one line, and never overwrite it.
2. Copy the roles file to `./sagespec.yml`:

   ```sh
   cp -n "${CLAUDE_PLUGIN_ROOT}/sagespec.yml" ./sagespec.yml
   ```

3. Tell the operator three things in three lines:
   - The file is theirs now, so they can edit it freely.
   - `trellis-crew start` reads `./sagespec.yml` with no flag.
   - The kickoffs in the file name the `sage-crew:lead-decisions` and
     `sage-crew:reporting-table` skills. Keep sage-crew installed to
     keep those rules, or edit the kickoffs to drop them.

Trigger: the operator asks to eject sage-crew.

Writes: `./sagespec.yml`, only when it does not exist.
