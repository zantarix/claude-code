---
paths:
  - "**/*.res"
  - "**/*.resi"
  - "**/*.css"
---

# TailwindCSS

Write Tailwind class names in full. Never construct them from parts. This rule applies only to individual class names, not to the full `className` attribute. The code scanner must see the full class names in the raw source to know which classes to include in the final CSS bundle.

**Inline `style` exception:** Use a React `style` object when a CSS value is dynamic at runtime. Use it only when no static Tailwind class that the scanner can see can express the value. The canonical case is a per-language hex colour from `LinguistLanguages`. This exception is narrow. Keep all other styling as Tailwind classes: spacing, radius, border, typography, and token-backed colours. Add an inline comment at the call site to note the exception.

**Two-step colour token indirection:** All colour tokens in `src/index.css` use a two-step CSS variable form, so that dark mode switches at runtime (ADR-024):

```css
/* @theme generates the Tailwind utility and references an intermediate var */
@theme { --color-surface: var(--surface); }
/* :root holds the light value */
:root { --surface: #ffffff; }
/* [data-theme="dark"] overrides it at runtime */
[data-theme="dark"] { --surface: #15140f; }
```

Every new **colour** token must follow this form. `@theme` references `var(--slug)`, not a literal hex. Radius, shadow, motion, and typography tokens are theme-agnostic. Keep them as single-step `@theme` declarations with literal values only.
