# Preserve observable multi-phase contracts over atomic shortcuts

A single-call API can collapse an existing multi-phase contract. In that case, preserve the observable phases of the contract. Do not take the atomic shortcut.

Before you replace a multi-phase implementation with one atomic call, check the callers and workflows. Find any that depend on an observable intermediate phase. An example is a record or stage step that is separate from a publish or commit step. If a caller depends on one, keep the phases separate. Run each side effect at the phase that the contract expects. Tell the user about the trade-off. Do not collapse the phases silently.
