# Design Verification Scripts

Programmatic validation for agents to verify design principles through code inspection.

## Spacing Validation (4px Grid)

```bash
# Find non-grid spacing values in CSS/Tailwind
grep -rE "(padding|margin|gap):\s*[0-9]+(px|rem)" --include="*.css" --include="*.tsx" | \
  grep -vE "(4|8|12|16|20|24|28|32|36|40|48|64)px"

# Tailwind: Check for arbitrary values not on grid
grep -rE "\[(padding|margin|gap|space)-\[" --include="*.tsx" | grep -vE "\[[0-9]+(px)?\]"
```

## Symmetrical Padding Check

```bash
# Find asymmetric padding patterns
grep -rE "padding:\s*[0-9]+px\s+[0-9]+px\s+[0-9]+px\s+[0-9]+px" --include="*.css" --include="*.tsx"
```

## Border Radius Consistency

```bash
# List all border-radius values to check for consistency
grep -rhoE "border-radius:\s*[0-9]+px" --include="*.css" | sort | uniq -c | sort -rn

# Tailwind: Check rounded-* usage
grep -rhoE "rounded-[a-z0-9]+" --include="*.tsx" | sort | uniq -c | sort -rn
```

## Shadow/Depth Strategy Validation

```bash
# List all shadow values to verify single strategy
grep -rhoE "box-shadow:[^;]+" --include="*.css" | sort | uniq -c

# Tailwind: Check shadow-* usage
grep -rhoE "shadow-[a-z0-9]+" --include="*.tsx" | sort | uniq -c | sort -rn
```

## Typography Hierarchy Check

```bash
# List font sizes to verify scale adherence
grep -rhoE "font-size:\s*[0-9]+px" --include="*.css" | sort | uniq -c | sort -rn

# Tailwind: Check text-* usage
grep -rhoE "text-(xs|sm|base|lg|xl|[0-9]xl)" --include="*.tsx" | sort | uniq -c | sort -rn
```

## Anti-Pattern Detection

```bash
# Large shadows (anti-pattern)
grep -rE "box-shadow:.*25px" --include="*.css" --include="*.tsx"

# Large border-radius on small elements
grep -rE "border-radius:\s*(16|20|24|32)px" --include="*.css"

# Multiple accent colors
grep -rhoE "(bg|text|border)-(blue|green|red|orange|purple|pink)-[0-9]+" --include="*.tsx" | \
  sed 's/-[0-9]*//' | sort -u | wc -l  # Should be 1-2
```

## Design Tokens Validation

```bash
# Verify CSS variables are defined and used consistently
grep -rhE "--[a-z-]+:" --include="*.css" | sort | uniq  # List all tokens
grep -rhE "var\(--" --include="*.tsx" --include="*.css" | sort | uniq -c  # Usage counts
```

## Full Audit Script

```bash
# Run all checks and report violations
echo "=== Design Validation ==="
echo "Non-grid spacing:" && grep -rE "(padding|margin|gap):\s*[0-9]+(px)" --include="*.css" -c 2>/dev/null || echo "0"
echo "Shadow variations:" && grep -rhoE "box-shadow:[^;]+" --include="*.css" | sort -u | wc -l
echo "Border-radius variations:" && grep -rhoE "border-radius:\s*[0-9]+px" --include="*.css" | sort -u | wc -l
```

**Note:** These checks validate implementation consistency. The initial design direction choice (warm vs cool, dense vs generous) requires understanding product context - use AskUserQuestion to clarify with the user before implementing.
