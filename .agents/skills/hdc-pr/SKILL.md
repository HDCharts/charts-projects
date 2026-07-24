---
name: hdc-pr
description: Create or update pull requests for changed repositories in the HDCharts multi-repository workspace, routing standalone repository PRs and coordinated charts, docs, or playground PRs. Apply the changeset gate only to user-facing projects/charts changes. Use only when the user explicitly asks to create, open, publish, or ship a PR, or explicitly asks for a standalone HDCharts PR changeset.
---

# Ship HDCharts workspace PRs

Detect the repositories in scope and create standalone or coordinated pull
requests without touching unrelated work.

## Guardrails

- Preserve unrelated changes and stop when they cannot be safely isolated.
- Never push directly to `main`, force-push, or rewrite history.
- Reuse an existing pull request instead of creating a duplicate.

## Repository routing

Work from the `charts-projects` workspace root.

| Repository | Path | PR mode | Changeset |
| --- | --- | --- | --- |
| Workspace | `.` | Standalone | Never |
| Library | `projects/charts` | Primary or standalone | User-impact gate |
| Documentation | `projects/charts-docs` | Standalone or charts companion | Never for docs-only work |
| Playground | `projects/charts-playground` | Standalone or charts companion | Never |
| GIF recorder | `projects/charts-gif-recorder` | Standalone | Never |
| GitHub profile | `projects/charts-github-profile` | Standalone | Never |

Skip repositories that are not cloned unless the user explicitly selected one.

## Detect scope

1. Honor repositories explicitly named by the user.
2. For every repository being evaluated, resolve its base remote (`upstream`
   when present, otherwise `origin`) and fetch the base remote's `main`.
3. Otherwise inspect each existing repository's worktree, current branch,
   commits relative to `<base-remote>/main`, and current-branch pull request.
4. Treat a repository as active when it has scoped worktree changes, unmerged
   branch commits, or an existing PR that needs updating.
5. When exactly one repository is active, create or update only its PR.
6. When several are active:
   - process all when the user explicitly asks for all changed repositories;
   - coordinate `charts` with related docs or playground changes;
   - ask for scope before external writes when the changes are unrelated or
     their relationship remains unclear.
7. When none are active, report that there is nothing to ship.

## Common PR workflow

For each selected repository:

1. Use `upstream` as the base remote when present, otherwise `origin`. Use
   `origin` as the head remote when present, otherwise the base remote.
2. Fetch the base remote's `main`.
3. Keep an existing feature branch. When on `main`:
   - stop if `HEAD` contains commits that are not in `<base-remote>/main`;
   - with only uncommitted intended work, create `<type>/<short-kebab>` from
     `<base-remote>/main` while preserving the scoped worktree changes, and stop
     if they cannot be carried over safely.
4. Review the scoped diff and run relevant repository formatting and checks.
5. Stage only scoped files and commit when needed with a concise Conventional
   Commit header.
6. Push the feature branch to the head remote with upstream tracking.
7. Resolve the GitHub repositories and owners from the base and head remote
   URLs. Create, find, and update the PR explicitly in the base remote's
   repository, targeting `main`. When the head remote is a different repository,
   use `<head-owner>:<branch>` as the PR head; otherwise use `<branch>`.
8. Create or update the PR body with
   [assets/pr-body.md](assets/pr-body.md):
   - use `Not applicable (non-charts repository)` for standalone PRs outside
     `projects/charts`;
   - leave the status `Pending` for a `charts` PR until the changeset gate runs.
9. Capture and report the PR URL.

## Link related PRs

When several selected repositories belong to the same request:

1. Use the `charts` PR as primary when present; otherwise use the first
   repository named or selected.
2. After capturing every PR URL, add a `Related PRs` section to the primary PR
   listing each other repository and PR URL.
3. Omit the section for a standalone PR.

## Coordinated charts workflow

Use this workflow only when `projects/charts` is selected.

1. Complete the common workflow for `charts` first and capture its PR number.
2. Read [references/changeset.md](references/changeset.md) and apply the
   user-impact gate.
3. When related docs changes exist or a changeset is required:
   - keep an existing related feature branch and update its pull request when
     one exists; otherwise create or reuse `docs/charts-pr-<pr-number>` from
     the docs base remote's `main`;
   - add the changeset when required;
   - commit only uncommitted related docs files, push, and create or update the
     docs PR.
4. When related playground changes exist:
   - keep an existing related feature branch and update its pull request when
     one exists; otherwise create or reuse
     `playground/charts-pr-<pr-number>` from the playground base remote's
     `main`;
   - commit only uncommitted related files, push, and create or update the
     playground PR.
5. Update the charts PR body with:
   - `Not required (technical/internal-only)` when the gate skips;
   - otherwise the changeset path;
   - all companion PRs under `Related PRs`.
6. Report all PR URLs and the exact changeset skip reason when applicable.

## Standalone changeset

When the user asks only for a changeset, follow
[references/changeset.md](references/changeset.md). Require a charts PR number
or infer it from the current charts PR. Do not commit, push, or open a companion
PR unless requested.
