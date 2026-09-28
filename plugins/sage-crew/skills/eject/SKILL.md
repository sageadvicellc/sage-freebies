---
name: eject
description: Copies the sage-crew roles file into the current folder as sagespec.yml, so the operator can edit it and run trellis-crew directly. Use when the operator asks to eject sage-crew or to own the team layout.
---

## Eject the preset

The sage-crew roles file is at this path:

`${CLAUDE_PLUGIN_ROOT}/sagespec.yml`

This skill never deletes, moves, or overwrites a file.

1. Run this check:

   ```sh
   [ -e ./sagespec.yml ] || [ -L ./sagespec.yml ]
   ```

   If it exits 0, a file, folder, or link named `sagespec.yml` is
   already here. Stop, and tell the operator in one line.
2. Copy the roles file:

   ```sh
   cp -n '${CLAUDE_PLUGIN_ROOT}/sagespec.yml' ./sagespec.yml
   ```

   If the copy exits with any status other than 0, stop and give the
   operator the error line. Never run the copy again, and never run it
   without `-n`.
3. Check that the copy matches:

   ```sh
   cmp '${CLAUDE_PLUGIN_ROOT}/sagespec.yml' ./sagespec.yml
   ```

   If it exits with any status other than 0, stop and tell the operator
   that the copy does not match. Do not change or remove the file.
4. Tell the operator three things in three lines:
   - The file is theirs now, so they can edit it freely.
   - `trellis-crew start` reads `./sagespec.yml`, shows it, and asks
     before it starts.
   - The kickoffs in the file name sage-crew skills. Keep sage-crew
     installed to keep those rules, or edit the kickoffs to drop them.

Trigger: the operator asks to eject sage-crew.

Writes: `./sagespec.yml`, only when nothing by that name exists.
