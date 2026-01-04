---
name: i18n
description: Internationalization with i18next and react-i18next. Covers translation setup, namespaces, pluralization, and language detection. Triggers on i18n, i18next, translation, t().
triggers: ["i18n", "i18next", "translation", "t\\(", "useTranslation", "Trans"]
---

<objective>
Implement internationalization using i18next with React. Handle translations, pluralization, interpolation, and language switching.
</objective>

<mcp_first>
**CRITICAL: Fetch i18next documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// i18next configuration
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/i18next/i18next",
  topic: "init configuration namespace"
})

// React integration
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/i18next/react-i18next",
  topic: "useTranslation Trans component"
})

// Pluralization and interpolation
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/i18next/i18next",
  topic: "plural interpolation context"
})
```
</mcp_first>

<quick_start>
**i18n configuration:**

```typescript
import i18n from "i18next";
import { initReactI18next } from "react-i18next";

i18n.use(initReactI18next).init({
  resources: {
    en: { translation: enTranslations },
    de: { translation: deTranslations },
  },
  lng: "en",
  fallbackLng: "en",
  interpolation: {
    escapeValue: false, // React already escapes
  },
});

export default i18n;
```

**Usage in components:**

```tsx
import { useTranslation } from "react-i18next";

function MyComponent() {
  const { t } = useTranslation();

  return (
    <div>
      <h1>{t("welcome")}</h1>
      <p>{t("items", { count: 5 })}</p>
      <p>{t("greeting", { name: "John" })}</p>
    </div>
  );
}
```

**Translation file structure:**

```json
{
  "welcome": "Welcome",
  "items_one": "{{count}} item",
  "items_other": "{{count}} items",
  "greeting": "Hello, {{name}}!"
}
```
</quick_start>

<patterns>
**Namespaces:**

```typescript
// Separate by feature
const { t } = useTranslation("dashboard");
t("title"); // dashboard:title

// Multiple namespaces
const { t } = useTranslation(["common", "dashboard"]);
t("common:button.save");
```

**Pluralization:**

```json
{
  "item_zero": "No items",
  "item_one": "One item",
  "item_other": "{{count}} items"
}
```

**Interpolation:**

```json
{
  "greeting": "Hello, {{name}}!",
  "date": "Today is {{date, datetime}}"
}
```

**Context:**

```json
{
  "friend_male": "He is a friend",
  "friend_female": "She is a friend"
}
```

```typescript
t("friend", { context: "male" });
```

**Trans component (for JSX):**

```tsx
import { Trans } from "react-i18next";

<Trans i18nKey="description">
  Welcome to <strong>our app</strong>. Click <a href="/start">here</a> to begin.
</Trans>
```
</patterns>

<file_structure>
```
src/
├── i18n/
│   ├── index.ts          # i18n configuration
│   ├── locales/
│   │   ├── en/
│   │   │   ├── common.json
│   │   │   └── dashboard.json
│   │   └── de/
│   │       ├── common.json
│   │       └── dashboard.json
```
</file_structure>

<constraints>
**Required:**
- Set `escapeValue: false` for React
- Use namespaces for large apps
- Provide fallback language
- Extract strings from code (no inline text)

**Naming:**
- Keys: `snake_case` or `dot.notation`
- Files: `<namespace>.json`
- Namespaces: `common`, `dashboard`, `settings`, etc.
</constraints>

<success_criteria>
- [ ] Context7 docs fetched for current API
- [ ] i18n configured with fallback
- [ ] Translations organized by namespace
- [ ] Pluralization works correctly
- [ ] No hardcoded strings in components
</success_criteria>
