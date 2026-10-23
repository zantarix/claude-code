---
name: feedback-recheck-working-tree-before-build-status
description: Re-check git status and the working tree immediately before writing any "built / not built" claim into an overview, because the delegating session may be implementing concurrently.
metadata:
  type: feedback
---

Run `git status` and inspect the implementation paths right before writing an overview's build-status sentence, not only during orientation.

**Why:** the session that delegates ADR work often implements the same decision in parallel in the shared working tree, so an early "nothing is built" reading can be false minutes later and the overview would then narrate a fiction.

**How to apply:** treat orientation-time code checks as stale once any time has passed; re-verify paths named in the brief (new directories, moved files, manifests) before the overview edit, and write the spec from the code actually present.
