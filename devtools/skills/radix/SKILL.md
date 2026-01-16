---
name: radix
description: Use when creating modals, adding dropdown menus, or building accessible dialogs. Covers Radix UI primitives for dialogs, dropdowns, popovers, and form controls.
license: MIT
triggers:
  # Intent triggers
  - "create modal"
  - "add dropdown menu"
  - "build accessible dialog"
  - "create popover"
  - "add tooltip"
  - "accessible component"
  - "headless component"

  # Artifact triggers
  - "radix"
  - "@radix-ui"
  - "Dialog\\.Root"
  - "DropdownMenu"
  - "Popover"
  - "Tooltip"
  - "asChild"
  - "onOpenChange"
  - "focus trap"
---

<objective>
Build accessible UI components using Radix UI primitives. Radix provides unstyled, accessible components that you style with Tailwind/CSS.
</objective>

<mcp_first>
**CRITICAL: Fetch Radix UI documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Radix primitives
mcp__context7__query_docs({
  libraryId: "/radix-ui/primitives",
  query: "How do I use Dialog with Trigger and Content?",
});

// Form controls
mcp__context7__query_docs({
  libraryId: "/radix-ui/primitives",
  query: "How do I use Select, Checkbox, and RadioGroup?",
});

// Accessibility
mcp__context7__query_docs({
  libraryId: "/radix-ui/primitives",
  query: "How do I handle accessibility, aria, and keyboard navigation?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Workflow:**
1. Import component from `@radix-ui/react-*`
2. Structure with Root → Trigger → Portal → Content
3. Use `asChild` for custom trigger elements
4. Style with Tailwind classes
5. Test keyboard navigation

**Dialog:**

```tsx
import * as Dialog from "@radix-ui/react-dialog";

function MyDialog() {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <button>Open Dialog</button>
      </Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/50" />
        <Dialog.Content className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-lg">
          <Dialog.Title>Dialog Title</Dialog.Title>
          <Dialog.Description>Dialog description.</Dialog.Description>
          <Dialog.Close asChild>
            <button>Close</button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

**Dropdown Menu:**

```tsx
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";

function MyDropdown() {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger asChild>
        <button>Options</button>
      </DropdownMenu.Trigger>
      <DropdownMenu.Portal>
        <DropdownMenu.Content className="bg-white rounded-md shadow-lg p-1">
          <DropdownMenu.Item className="px-2 py-1 cursor-pointer hover:bg-gray-100">
            Edit
          </DropdownMenu.Item>
          <DropdownMenu.Item className="px-2 py-1 cursor-pointer hover:bg-gray-100">
            Delete
          </DropdownMenu.Item>
          <DropdownMenu.Separator className="h-px bg-gray-200 my-1" />
          <DropdownMenu.Item className="px-2 py-1 cursor-pointer hover:bg-gray-100">
            Settings
          </DropdownMenu.Item>
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}
```

**Select:**

```tsx
import * as Select from "@radix-ui/react-select";

function MySelect() {
  return (
    <Select.Root>
      <Select.Trigger className="border px-3 py-2 rounded">
        <Select.Value placeholder="Select option" />
        <Select.Icon />
      </Select.Trigger>
      <Select.Portal>
        <Select.Content className="bg-white border rounded shadow-lg">
          <Select.Viewport>
            <Select.Item value="1" className="px-3 py-2 hover:bg-gray-100">
              <Select.ItemText>Option 1</Select.ItemText>
            </Select.Item>
            <Select.Item value="2" className="px-3 py-2 hover:bg-gray-100">
              <Select.ItemText>Option 2</Select.ItemText>
            </Select.Item>
          </Select.Viewport>
        </Select.Content>
      </Select.Portal>
    </Select.Root>
  );
}
```

</quick_start>

<common_components>
| Component | Use Case |
|-----------|----------|
| `Dialog` | Modals, confirmations |
| `AlertDialog` | Destructive action confirmations |
| `DropdownMenu` | Context menus, action menus |
| `Select` | Form select inputs |
| `Popover` | Floating content, tooltips |
| `Tooltip` | Hover hints |
| `Tabs` | Tabbed interfaces |
| `Accordion` | Collapsible sections |
| `Checkbox` | Boolean inputs |
| `RadioGroup` | Single selection |
| `Switch` | Toggle inputs |
| `Slider` | Range inputs |
</common_components>

<patterns>
**Controlled state:**

```tsx
const [open, setOpen] = useState(false);

<Dialog.Root open={open} onOpenChange={setOpen}>
  {/* ... */}
</Dialog.Root>;
```

**asChild pattern:**

```tsx
// Radix renders the wrapped button element, not its own
<Dialog.Trigger asChild>
  <Button variant="primary">Open</Button>
</Dialog.Trigger>
```

**Portal for proper stacking:**

```tsx
<Dialog.Portal>
  <Dialog.Overlay />
  <Dialog.Content>{/* Content renders outside parent DOM */}</Dialog.Content>
</Dialog.Portal>
```

**Forwarding refs:**

```tsx
const MyTrigger = forwardRef((props, ref) => (
  <button ref={ref} {...props}>
    Custom Trigger
  </button>
));

<Dialog.Trigger asChild>
  <MyTrigger />
</Dialog.Trigger>;
```

</patterns>

<constraints>
**Required:**
- Use `asChild` to compose with your own components
- Use `Portal` for overlays/dropdowns
- Provide accessible labels (Title, Description)
- Handle keyboard navigation (built-in)

**Accessibility:**

- Always include `Title` for dialogs
- Use `Description` for additional context
- Test with keyboard navigation
- Test with screen readers
  </constraints>

<anti_patterns>
**Common mistakes to avoid:**

- Forgetting `asChild` when using custom trigger components
- Missing `Portal` for overlays (causes z-index issues)
- Omitting `Title` from dialogs (accessibility violation)
- Not forwarding refs in custom trigger components
- Inline styles instead of Tailwind classes for consistency
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library  | Context7 ID               |
| -------- | ------------------------- |
| Radix UI | /radix-ui/primitives      |
| Tailwind | /tailwindlabs/tailwindcss |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Radix UI patterns",
      researchGoal: "Search for accessible component patterns",
      reasoning: "Need real-world examples of Radix usage",
      keywordsToSearch: ["@radix-ui", "Dialog.Root", "asChild"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Dialog patterns: `keywordsToSearch: ["Dialog.Root", "Dialog.Portal", "onOpenChange"]`
- Dropdown: `keywordsToSearch: ["DropdownMenu", "DropdownMenu.Content"]`
- Form controls: `keywordsToSearch: ["Select.Root", "Checkbox", "RadioGroup"]`
  </research>

<related_skills>

**Design guidelines:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Auditing keyboard accessibility and focus management
- Checking hit targets and loading states
- Validating form labels and error handling patterns

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Styling Radix components with consistent design tokens
- Establishing depth strategy (borders vs shadows)
- Creating isolated control containers

</related_skills>

<success_criteria>

1. [ ] Context7 docs fetched for current API
2. [ ] Uses `asChild` for custom triggers
3. [ ] Portal used for floating content
4. [ ] Accessible labels provided
5. [ ] Styled with Tailwind (not inline)
</success_criteria>

<evolution>
**Extension Points:**

- Wrap Radix primitives in project-specific styled components
- Add animation variants with Framer Motion integration
- Create compound components combining multiple primitives

**Timelessness:** Accessible, unstyled primitives are the foundation of any design system. Radix patterns apply to headless UI libraries.
</evolution>
