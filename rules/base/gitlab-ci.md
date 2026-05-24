# GitLab CI

GitLab CI does not offer a native toggle to enforce SHA pinning, so treat it as a project convention. Any `include:` of an external pipeline (`project`, `remote`, `component`, `template`) or `component` reference must be pinned to a commit SHA. Where the upstream publishes immutable `vX.Y.Z` tags, record that tag alongside the SHA in a comment so the intended version stays legible.

Docker images used in `image:` and `services:` (including `default:` and any `image:` set in `services` entries) must be pinned to an immutable `sha256:` digest, e.g. `image: alpine@sha256:...`. Keep the human-readable tag in a comment so the intended version stays legible. Never rely on `latest` or any other moving tag.
