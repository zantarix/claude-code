# TailwindCSS

Tailwind class names must be included in full and never constructed from parts. This rule applies only to individual class names, not the full `className` attribute. The code scanner requires being able to see the full class names in the raw source to know which classes to include in the final CSS bundle.

**Inline `style` exception:** when a CSS value is dynamic at runtime and cannot be expressed as a static Tailwind class visible to the scanner (the canonical case is a per-language hex colour sourced from `LinguistLanguages`), set it via a React `style` object rather than a Tailwind utility. This exception is narrow: all other styling — spacing, radius, border, typography, token-backed colours — must remain Tailwind classes. The exception must be noted with an inline comment at the call site.

**Two-step colour token indirection:** All colour tokens in `src/index.css` use a two-step CSS variable form for runtime dark-mode switching (ADR-024):

```css
/* @theme generates the Tailwind utility and references an intermediate var */
@theme { --color-surface: var(--surface); }
/* :root holds the light value */
:root { --surface: #ffffff; }
/* [data-theme="dark"] overrides it at runtime */
[data-theme="dark"] { --surface: #15140f; }
```

Every new **colour** token must follow this form — `@theme` references `var(--slug)`, not a literal hex. Radius, shadow, motion, and typography tokens are theme-agnostic and remain single-step `@theme` declarations (literal values only).
