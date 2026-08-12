---
name: promoting-memory-to-prompts
description: Promoting an agent-memory rule into a distributed prompt strips the implicit scope the memory had from its originating context — re-scope every rule explicitly before it ships
metadata:
  type: feedback
---

A rule written in agent memory carries **implicit scope** from the situation that
produced it. Lifted verbatim into a distributed prompt, that scope is gone and the
rule reads as universal.

**Why:** The memory rule "delete a falsified census claim; do not restate it"
was recorded mid-acceptance of a **Proposed** ADR, so "delete" was safe by
construction. Promoted into the always-loaded curator prompt with no status
qualifier, it became an instruction to edit **Accepted, immutable** ADRs — and it
landed in a prompt whose own `/accept-adr` flow walks the accepted corpus looking
for exactly such claims. `@plugin-reviewer` graded it Critical. Two other findings
had the same shape (a "delete it" with no tier scope, a `stale_after` collision with
a new "no per-document refresh rule" absolute).

**How to apply:**

- For every rule being promoted, ask what the originating situation supplied for
  free — ADR status, bundle mode, who was in the session, which tier of document —
  and write that qualifier in. The memory won't tell you; it never had to.
- A rule shaped as a **test** carries an unstated scope for *what the test gates*.
  Check whether it disqualifies the whole action or only one input to it before
  writing it as a bar: an attribution test that reads "no attribution, no erratum"
  silently voids every erratum whose forward link is a living document rather than
  a decision.
- Sweep the destination prompt for the rule's **inverse guarantee** already stated
  elsewhere (immutability, "never edit the body", a frontmatter key that does the
  same job). A promoted rule that contradicts a standing guarantee is the failure
  mode, not a vague one.
- **Always run `@plugin-reviewer` before committing a fold.** It reads the
  destination as a whole and catches contradiction-at-a-distance that a
  memory-by-memory review cannot. It also caught that two of the three skills I
  planned to add a session guard to already had one — de-dup against the
  destination, not just against recent commits.
- Verification greps in a prompt must **name the tool and the regex dialect**.
  `^#\+` (BRE, `Bash` grep) and `^#+ ?[0-9]` (ERE, the `Grep` tool) silently
  return zero hits in the wrong engine — indistinguishable from clean, which is
  precisely what a verification grep exists to detect.

See [[human-gates-never-auto-chain]] for the related discipline on gate skills.
