---
paths:
  - ".github/workflows/**"
---
# GitHub Actions

Pin all workflow action `uses:` entries to a full commit SHA. Add the version tag as a comment for readability:

```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
```

If a `vX.Y.Z` tag exists, use that tag format in the comment.
