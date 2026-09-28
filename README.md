# sage-freebies
💸 I'm just giving this stuff away! 

## Install a plugin in Claude Code

Add this marketplace once, then install a plugin from it:

```sh
claude plugin marketplace add sageadvicellc/sage-freebies
claude plugin install sage-crew@sage-freebies
```

Add the marketplace by its repository name, as above. The sage-crew plugin lives in this repository, and Claude Code cannot find it if you add only the `marketplace.json` file's URL.

| Plugin | What it does |
|---|---|
| [trellis-crew](https://github.com/sageadvicellc/trellis-crew) | Sets up a small team of agent sessions that split work, hand off tasks, and report status. |
| [sage-crew](plugins/sage-crew) | Runs a trellis-crew team the Sage way: decision comments with defaults, one status table per report, and a preset roles file. Installing it also installs trellis-crew. |

## sage-crew

sage-crew adds five skills to trellis-crew:

| Skill | What it does |
|---|---|
| `sage-crew:start` | Starts a trellis-crew team with the sage-crew roles file |
| `sage-crew:eject` | Copies the roles file to `./sagespec.yml`, so you can edit it and run `trellis-crew start` yourself |
| `sage-crew:lead-decisions` | Poses each decision as its own comment, with a default that applies after eight hours |
| `sage-crew:reporting-table` | Writes every report to the operator as one status table |
| `sage-crew:researcher` | Runs a worker that answers one research question at a time from cited, dated sources |

The start skill needs the `trellis-crew` command line tool. Its install steps are in the [trellis-crew README](https://github.com/sageadvicellc/trellis-crew#readme).

If you already write your own roles file, you do not need the start skill. Pass your file to `trellis-crew start --roles <file>`.
