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

| Repository | Purpose |
| --- | --- |
| `charts` | HDCharts core library |
| `charts-docs` | Documentation site |
| `charts-playground` | Playground app |
| `charts-gif-recorder` | GIF recorder |
