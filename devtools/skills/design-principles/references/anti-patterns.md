# Design Anti-Patterns

## Never Do

- Dramatic drop shadows (`box-shadow: 0 25px 50px...`)
- Large border radius (16px+) on small elements
- Asymmetric padding without clear reason
- Pure white cards on colored backgrounds
- Thick borders (2px+) for decoration
- Excessive spacing (margins > 48px between sections)
- Spring/bouncy animations
- Gradients for decoration
- Multiple accent colors in one interface

## Always Question

- "Did I think about what this product needs, or did I default?"
- "Does this direction fit the context and users?"
- "Does this element feel crafted?"
- "Is my depth strategy consistent and intentional?"
- "Are all elements on the grid?"

## Common Mistakes

**Mixing depth strategies** — Using flat borders on some cards and heavy shadows on others creates visual inconsistency.

**Decorative color** — Adding color that doesn't communicate status, action, or meaning. Gray builds structure; color should earn its place.

**Native form elements** — Using `<select>`, `<input type="date">` that render OS-native controls which cannot be styled.

**Over-animating** — Spring/bouncy effects feel playful but undermine professional interfaces.

**Inconsistent radii** — Mixing sharp (4px) and soft (12px) corners in the same interface without reason.
