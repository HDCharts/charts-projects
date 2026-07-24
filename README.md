# charts-projects

Shared local workspace for the HDCharts projects.

This repository is the workspace entrypoint. Clone it first, then use the setup
script to clone the projects you want to work on.

## Clone Repositories

From this repository:

```bash
scripts/clone-repos.sh
```

The script asks which projects to clone and puts them in:

```text
projects/
```

That folder is ignored by this repository, so each project keeps its own Git
status and changes do not show up as changes in `charts-projects`.

To clone everything without a prompt:

```bash
scripts/clone-repos.sh --all
```

To use SSH clone URLs:

```bash
scripts/clone-repos.sh --ssh
```

To clone into a custom directory:

```bash
scripts/clone-repos.sh --dest ../HDCharts-workspace
```

To preview what would be cloned:

```bash
scripts/clone-repos.sh --dry-run
```

## Repositories

The setup script currently knows about:

| Repository | Purpose | Link |
| --- | --- | --- |
| `charts` | HDCharts core library | [Maven Central](https://central.sonatype.com/artifact/io.github.dautovicharis/charts/overview), [Demo](https://charts.harisdautovic.com/demo) |
| `charts-docs` | Documentation site | [Documentation](https://charts.harisdautovic.com/) |
| `charts-playground` | Playground app | [Playground](https://charts.harisdautovic.com/playground) |
| `charts-gif-recorder` | GIF recorder | [Repository](https://github.com/hdcodedev/compose-gif-recorder) |
| `charts-github-profile` | GitHub organization profile and defaults | [Repository](https://github.com/HDCharts/.github) |

## Agent Skills

Cross-repository HDCharts workflows live in `.agents/skills/` using the open
Agent Skills `SKILL.md` format:

- `hdc-pr` routes PRs for changed workspace repositories and
  coordinates library changesets or companion PRs only when needed.
- `hdc-rc` runs API compatibility checks and updates
  snapshot migration notes.

Open this workspace root when using these skills so the agent can access the
sibling repositories under `projects/`.

Agents that use `.agents/skills/` discover the canonical skills directly.
Compatibility symlinks are included for Claude Code, Kilo Code, and Roo Code.

To confirm that a skills.sh-compatible client can discover the skills:

```bash
npx skills add . --list
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local setup and pull request guidelines.
