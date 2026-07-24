# HDCharts changeset workflow

Use this workflow after obtaining the primary `HDCharts/charts` PR number or
when the user explicitly requests a standalone changeset.

## User-impact gate

Create a changeset when users need to know about an observable feature, fix,
behavior change, API change, or documentation change.

Skip it for technical or internal-only changes, including CI configuration,
dependency-only updates with no behavior change, internal refactors, build
cleanup, formatting, linting, and repository maintenance.

When skipped, output exactly:

```text
No changeset needed (technical/internal-only PR).
```

## Required values

Infer values from the primary PR, branch, commits, and touched modules. An
explicit user value overrides an inferred value.

- `pr_number`: required
- `short_kebab`: concise lowercase kebab-case summary
- `type`: one of `feature`, `fix`, `refactor`, `docs`, or `chore`
- `module`: the most relevant published module
- `release_note`: one plain-language, user-facing sentence of at most 20 words,
  without internal implementation jargon

## Create the file

1. Use `projects/charts-docs` from the workspace root.
2. Ensure `projects/charts-docs/content/snapshot/changes/` exists.
3. Copy [../assets/pr-changeset.md](../assets/pr-changeset.md) to:

   ```text
   projects/charts-docs/content/snapshot/changes/<pr-number>-<short-kebab>.md
   ```

4. Populate the PR URL as:

   ```text
   https://github.com/HDCharts/charts/pull/<pr-number>
   ```

5. Validate the allowed type, published module name, PR URL, release-note word
   count, and absence of template placeholders.
6. Report the created path.
