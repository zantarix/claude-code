# Preserve observable multi-phase contracts over atomic shortcuts

When a single-call API would collapse an existing multi-phase contract, default to preserving the contract's observable phasing rather than taking the atomic shortcut. Materialise side effects at the phase the existing contract expects them, and surface the trade-off to the user rather than silently collapsing.

**Why:** Collapsing phases changes observable behaviour — intermediate states stop being reachable, and failures that should land between phases instead either fully succeed or fully fail. The user values keeping documented phase boundaries intact so multi-step workflows and partial-failure handling behave as designed.

**How to apply:** Before replacing a multi-phase implementation with a single atomic API call, ask whether any caller or workflow depends on the intermediate phase being observable (e.g. a record/stage step distinct from a publish/commit step). If so, keep the phases separate and raise the option as an explicit trade-off instead of silently picking the shortcut.
