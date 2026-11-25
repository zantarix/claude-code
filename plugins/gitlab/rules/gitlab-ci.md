# GitLab CI

GitLab CI has no native toggle to enforce SHA pinning, so treat it as a project convention. Pin every external pipeline `include:` to a commit SHA. This covers `project`, `remote`, `component`, and `template` includes, and any `component` reference. When the upstream publishes immutable `vX.Y.Z` tags, record that tag in a comment next to the SHA. The comment keeps the intended version clear.

Pin every Docker image in `image:` and `services:` to an immutable `sha256:` digest, for example `image: alpine@sha256:...`. This includes `default:` and any `image:` set in `services` entries. Keep the human-readable tag in a comment so the intended version stays clear. Never use `latest` or any other moving tag.
