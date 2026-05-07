---
name: analyse-mutations
description: Analyse mutation test results to increase test coverage.
disable-model-invocation: true
---

Mutation tests are run manually by the user with `cargo mutants`. The results appear in `mutants.out/missed.txt`. If no report exists, then first ask the user to generate one and pause.

Once the report has been generated, analyse the report. This file lists every mutation test that failed and clearly indicates a code path that is currently insufficiently tested. Each line of this file is of the following format:

```
<filename>:<line number>:<column number>: <description of how the file was changed>
```

If you wish to see the precise way that the file was changed, you can access a diff in the `mutants.out/diff/<filename>_line_<line number>_col_<column number>.diff` file.

Partition the results by file or directory structure and delegate fixes to a relevant number of subagents, each running in an isolated git worktree (use `isolation: "worktree"` on the Agent tool call). Each subagent receives the following prompt:

```
Your job is to fix as many of the following mutation test result findings as possible:

<list of issues being delegated from the mutation report>

<Instructions on how to find diffs describing the above issues>

There are two valid ways to address a missed mutant — adding tests is not always the right answer:

1. **Add a test** that exercises the mutated code path and would fail if the mutation were applied.
2. **Simplify the code** if the mutation is equivalent (i.e. the condition behaves identically either way). For example, a redundant guard condition can simply be removed, or a manual `if x < y { v = x }` pattern can be replaced with `v = v.min(x)`. Prefer this when the code genuinely has no meaningful distinction between the original and the mutant.

When you have fixed as many issues as possible, leave your work uncommitted in the worktree and write out a summary detailing which issues you fixed and which issues are still open.
```

When all the subagents have completed their work, apply each worktree's uncommitted changes to the main checkout using `git diff` and `git apply`. There should be no overlapping work that needs merging due to the work partitioning.

Retest the combined results using the `/rust:verify-code` skill, fixing any compilation errors or test failures introduced by the combined patches.

Then present a report back to the user about how many issues were fixed and in which areas of the codebase.
