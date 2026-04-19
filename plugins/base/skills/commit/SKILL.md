---
name: commit
description: Use to verify and commit staged or unstaged changes with a well-crafted commit message.
---

Commit the current changes following this project's standards. Perform the steps below in order, stopping and reporting any failures.

1. **Verify** the code quality using the `/verify-code` skill, if any relevant source code or test files have changed. Fix any failures before proceeding.

2. **Accept** the ADR that triggered this change using the `/accept-adr` skill, if the change was an implementation for an ADR.

3. Create a **changeset** using the `/changeset` skill if the commit contains releasable changes.

4. **Stage** changes: prefer adding specific files by name rather than `git add -A`. Never stage secrets, credentials, or large binaries.

5. **Draft** a commit message:
   - Follow Conventional Commit style for the message formatting. You can find a copy of this style guide in `commits.md`.
   - Run `git log --oneline -10` to match the existing commit message style.
   - Summarise the *why*, not the *what*.
   - Use the imperative mood in the subject line (e.g. "Add", "Fix", "Refactor").
   - Keep the subject line under 72 characters.
   - If the change is non-trivial, add a blank line followed by a short body.

6. **Commit** using a HEREDOC to preserve formatting:

   ```bash
   git commit -m "$(cat <<'EOF'
   <subject line>

   <optional body>

   Co-Authored-By: <description of current model>
   EOF
   )"
   ```

7. **Confirm** success with `git status` and report the commit hash and subject to the user.

**Safety rules (never violate):**

- Never amend an existing commit unless the user explicitly asks.
- Never force-push.
- Never skip hooks (`--no-verify`).
- Never push to the remote unless the user explicitly asks.
