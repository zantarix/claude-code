---
paths: "**/*.rs"
---

# Non-functional Requirements

All new changes should meet the coverage thresholds:

- 90% for lines, regions, and functions
- 80% for branches

All functions which are made public from a module should be documented.

All significant changes as described by that agents description should be checked with the `code-reviewer` subagent. This check is separate from any plan approvals by the user as it is intended to validate the implementation of the plan. You should automatically fix all critical or major issues before providing the user a summary of the review.

When summarising changes made where the `code-reviewer` subagent was involved, you must include a list of fixes which were applied, as well as a list of any fixes not applied. Any other feedback should be included in it's own section. A summary of each of the points raised by the reviewer should end up in one of these three sections.
