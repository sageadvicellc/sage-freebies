# sage-freebies
💸 I'm just giving this stuff away! 

## Install a plugin in Claude Code

Add this marketplace once, then install a plugin from it:

```sh
claude plugin marketplace add sageadvicellc/sage-freebies
claude plugin install sage-crew@sage-freebies
```

| Plugin | What it does |
|---|---|
| [sage-crew](https://github.com/sageadvicellc/trellis-crew) | Sets up a small team of agent sessions that split work, hand off tasks, and report status. |

The sage-crew skills keep their source name as a prefix. Call them as `trellis-crew:<skill>`, for example `trellis-crew:department-lead`.

If you installed `trellis-crew@sage-freebies` before, Claude Code v2.1.193 or later moves your settings to sage-crew. Then run `claude plugin install sage-crew@sage-freebies` once.
