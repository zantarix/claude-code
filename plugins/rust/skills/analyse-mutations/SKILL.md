---
name: analyse-mutations
description: Analyse mutation test results to increase test coverage.
disable-model-invocation: true
---

Mutation tests are run manually by the user with `cargo mutants`. The results appear in `mutants.out/missed.txt`. If no report exists, then first ask the user to generate one and pause.

Once the report has been generated, analyse and fix as many issues as possible. This file lists every mutation test that failed and indicates a code path that is currently insufficiently tested. Each line of this file is of the following format:

```
<filename>:<line number>:<column number>: <description of how the file was changed>
```

If you wish to see the precise way that the file was changed, you can access a diff in the `mutants.out/diff/<filename>_line_<line number>_col_<column number>.diff` file.

There are two valid ways to address a missed mutant — adding tests is not always the right answer:

1. **Add a test** that exercises the mutated code path and would fail if the mutation were applied.
2. **Simplify the code** if the mutation is equivalent (i.e. the condition behaves identically either way). For example, a redundant guard condition can simply be removed, or a manual `if x < y { v = x }` pattern can be replaced with `v = v.min(x)`. Prefer this when the code genuinely has no meaningful distinction between the original and the mutant.
