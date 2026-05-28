When the user writes a GitLab reference like `api#14` vs `api!14`, the sigil matters: `#N` is an **issue / work item**, `!N` is a **merge request**, `&N` is an **epic**. They are distinct objects with the same number.

**Why:** I read "api#14 with feedback from GitHub" and fetched MR `!14` instead of issue `#14`. The user corrected: "You've confused api!14 (the MR) and api#14 (the work item)."

**How to apply:** Honour the exact sigil. `#` → `get_issue` / work-item-notes for that iid. `!` → `get_merge_request`. Don't substitute one for the other even if numbers coincide. Note: `get_workitem_notes` with a given iid resolves the *issue* work item, not the MR.
