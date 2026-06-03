---
paths:
  - "**/*.rs"
---

# Non-functional Requirements

All new changes should meet the coverage thresholds:

- 90% for lines, regions, and functions
- 80% for branches

Use `#[cfg_attr(coverage_nightly, coverage(off))]` to exclude genuinely-untestable bootstrap code from coverage reporting; see `coverage.md` for the full mechanism and when it applies.
