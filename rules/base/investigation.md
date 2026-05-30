# Investigating failures

When a tool or test fails unexpectedly, do not claim it is a "known issue" or "toolchain bug" without a source (link, issue number, or reproduction steps). Before attributing blame to an external tool, check whether the failure reproduces without your changes — if it only fails after your changes, it is a regression you introduced.

**Why:** In one incident, an llvm-cov SIGSEGV was incorrectly attributed to "a known nightly issue" when it was actually introduced by changes in the same session. The user caught this; an explicit bisect step would have caught it first.

**How to apply:** When encountering unexpected tool failures: (1) test without your changes to establish a baseline, (2) only say "known issue" if you have a concrete source. Never use vague attribution as a way to move on from a failure.
