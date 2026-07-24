---
name: hdc-rc
description: Run the configured HDCharts binary API compatibility check and generate concise end-user migration notes in charts-docs. Use when the user asks to inspect breaking API changes, check snapshot or release compatibility, or update snapshot breaking-changes documentation.
---

# Check HDCharts release compatibility

Generate migration guidance from the library's configured API compatibility
baseline and reports.

## Guardrails

- Do not commit, push, or open pull requests unless the user explicitly asks.
- Stop before writing if
  `projects/charts-docs/content/snapshot/breaking-changes.md` has uncommitted
  changes.
- Inspect generated reports even when the compatibility command exits nonzero;
  distinguish reported incompatibilities from infrastructure failures.

## Workspace

Work from the `charts-projects` workspace root. Require:

- `projects/charts`
- `projects/charts-docs`

## Workflow

1. Read the configured baseline ref from
   `projects/charts/.github/api-compatibility-baseline.txt` for reporting.
2. Remove the generated
   `projects/charts/build/reports/api-compatibility/` directory so only reports
   from the current run can be considered.
3. Run from `projects/charts`:

   ```text
   ./gradlew apiCompatibilityCheck --no-daemon --continue
   ```

4. Capture the command's exit status and output. When it exits nonzero,
   distinguish API incompatibilities from build, dependency, tool, and other
   infrastructure failures. If any infrastructure failure occurred, report it
   and stop without changing documentation, even when some reports exist.
5. Read every Markdown report generated under
   `build/reports/api-compatibility/`. Verify that every configured library
   module expected to run produced a current report or was explicitly skipped
   because its baseline artifact does not exist. If the report set is missing,
   stale, or incomplete, report the failure and stop without changing
   documentation.
6. For each module with a breaking change, determine:
   - whether source call sites require edits;
   - the user-visible API change;
   - a minimal Kotlin before/after migration when edits are required.
7. Write `projects/charts-docs/content/snapshot/breaking-changes.md` using
   [assets/migration-guide.md](assets/migration-guide.md):
   - when no breaking modules exist, write the heading followed by
     `No call-site updates required.`;
   - otherwise add one section per breaking module and omit inapplicable
     migration content.
8. Validate that no placeholders remain and that examples match the reports.
9. Report the baseline ref, command result, breaking modules, and documentation
   path.
