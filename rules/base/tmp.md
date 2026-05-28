When writing scratch artefacts (coverage outputs, intermediate JSON, temporary reports), prefer a local `.tmp/` folder inside the project repo over `/tmp` paths.

**Why:** Repo-local scratch files survive across shell sessions, are visible alongside the work they support, and don't clash with other repos' artefacts in `/tmp`. They're easy to clean up with `rm -rf .tmp`.

**How to apply:** When piping commands, build logs, or similar long outputs to a file for later inspection, write to `./.tmp/<name>.txt` (creating the dir with `mkdir -p .tmp` if needed). Do not write to `/tmp/...`.
