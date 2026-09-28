---
name: start
description: Starts a trellis-crew team with the sage-crew roles file, which ships in this plugin. Use when the operator asks to start the sage crew or a team with the sage-crew preset.
---

## Start the team with the preset

The sage-crew roles file is at this path:

`${CLAUDE_PLUGIN_ROOT}/sagespec.yml`

1. Run `trellis-crew --help`. If the command is missing, or the help
   does not list `start` and `--roles`, tell the operator in one line
   that the trellis-crew command line tool is not installed, and point
   to https://github.com/sageadvicellc/trellis-crew#readme. Stop there.
   Never install, download, or build the tool yourself.
2. If a `sagespec.yml` file is in the current folder, the operator
   ejected the preset or wrote their own. Say so in one line, and use
   that file: leave out `--roles` in the steps below.
3. Show the operator the sessions in the roles file: name, role, and
   who each one reports to. Ask the operator to confirm.
4. After the operator's own confirmation, run:

   ```sh
   trellis-crew start --roles "${CLAUDE_PLUGIN_ROOT}/sagespec.yml" --yes
   ```

   Pass the path as one quoted argument. Add `--workers <N>` only when
   the operator gave a number. Add `--yes` only after the operator
   confirmed in step 3, because `--yes` skips the tool's own
   confirmation.
5. Report the command's result in one line. If it exits with an error,
   give the operator its first error line as written.

Trigger: the operator asks to start the sage crew.

Writes: nothing. The trellis-crew tool starts the sessions.
