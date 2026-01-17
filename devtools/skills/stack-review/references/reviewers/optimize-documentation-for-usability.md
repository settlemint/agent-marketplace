# Optimize documentation for usability

> **Repository:** shadcn-ui/ui
> **Dependencies:** @vitest/ui

When creating component documentation, prioritize the developer experience by providing clear, usable examples and configurations. For Storybook components, configure props documentation thoughtfully—rather than removing props like `children` from the table entirely, consider using more specific controls:

```js
// Instead of hiding children completely:
children: {
  table: {
    disable: true,
  },
},

// Better approach - disable only the control:
children: {
  control: false,
},

// Or constrain to text when appropriate:
children: {
  control: 'text',
},
```

Organize documentation in a logical structure that matches user expectations (such as aligning with your public documentation structure) and leverage specialized documentation blocks like ColorPalette and TypeSet for design systems. This makes documentation more intuitive and helps developers quickly find and implement components.