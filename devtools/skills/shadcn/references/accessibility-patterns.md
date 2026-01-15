# Accessibility Patterns

## Focus States

```typescript
// Focus rings
className =
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2";

// Invalid state
className = "aria-invalid:border-destructive aria-invalid:ring-destructive/20";

// Disabled state
className = "disabled:pointer-events-none disabled:opacity-50";

// Screen reader only
className = "sr-only";

// Focus within group
className = "group-focus-within:ring-2";
```

## ARIA Attributes

```typescript
// Input with error
<Input aria-invalid={!!errors} aria-describedby={`${id}-error`} />
<div role="alert" id={`${id}-error`}>{error}</div>

// Required field
<Label>
  Email <span className="text-destructive">*</span>
</Label>
<Input aria-required="true" />

// Expanded state (for dropdowns, accordions)
<Button aria-expanded={isOpen} aria-controls="menu-content">
  Toggle
</Button>
<div id="menu-content" aria-hidden={!isOpen}>
  Content
</div>
```

## Keyboard Navigation

```typescript
// Escape key handling (built into Radix)
<Dialog onOpenChange={(open) => !open && handleClose()}>

// Arrow key navigation (built into Command/Combobox)
<Command>
  <CommandInput />
  <CommandList>
    {/* Arrow keys work automatically */}
  </CommandList>
</Command>

// Tab trapping in modals (built into Dialog/Sheet)
<DialogContent>
  {/* Focus trapped within */}
</DialogContent>
```

## Icons with Screen Readers

```typescript
// Decorative icons (hidden from SR)
<ChevronDown className="h-4 w-4" aria-hidden="true" />

// Meaningful icons (need label)
<Button aria-label="Close">
  <X className="h-4 w-4" />
</Button>

// Icon with visible text (redundant, hide icon)
<Button>
  <Settings className="mr-2 h-4 w-4" aria-hidden="true" />
  Settings
</Button>
```

## Loading States

```typescript
<Button disabled aria-busy="true">
  <Loader2 className="mr-2 h-4 w-4 animate-spin" aria-hidden="true" />
  Loading...
</Button>
```
