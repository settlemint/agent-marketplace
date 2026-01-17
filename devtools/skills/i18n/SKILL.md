---
name: i18n
description: Internationalization with i18next. Use when asked to "add translations", "internationalize app", or "support multiple languages". Covers translation setup, namespaces, pluralization, and language detection.
license: MIT
triggers:
  - "i18n"
  - "i18next"
  - "react-i18next"
  - "translation"
  - "translate"
  - "t\\("
  - "useTranslation"
  - "Trans"
  - "internationali[zs]"
  - "locali[zs]"
  - "locale"
  - "multilingual"
  - "multi.?language"
  - "multiple.?languages"
  - "language.?switch"
  - "switch.?language"
  - "change.?language"
  - "fallbackLng"
  - "namespace"
  - "plurali[zs]"
  - "interpolation"
  - "RTL"
  - "right.?to.?left"
  - "LTR"
  - "left.?to.?right"
  - "language.?detection"
  - "translation.?file"
  - '\\.json.?translation'
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
  libraryId: "/i18next/i18next",
  query: "How do I configure init with configuration and namespaces?",
});

// React integration
mcp__context7__query_docs({
  libraryId: "/i18next/react-i18next",
  query: "How do I use useTranslation and the Trans component?",
});

// Pluralization and interpolation
mcp__context7__query_docs({
  libraryId: "/i18next/i18next",
  query: "How do I handle plural, interpolation, and context?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Workflow:**
1. Install dependencies: `npm install i18next react-i18next`
2. Create `src/i18n/index.ts` with init config
3. Add translation files in `src/i18n/locales/{lang}/`
4. Wrap app with `I18nextProvider`
5. Use `useTranslation()` hook in components

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
</Trans>;
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

<anti_patterns>

- Hardcoding text in components instead of using translation keys
- Forgetting fallback language configuration
- Using `escapeValue: true` with React (double escaping)
- Deeply nested translation keys that are hard to maintain
- Missing pluralization rules for countable items
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library       | Context7 ID            |
| ------------- | ---------------------- |
| i18next       | /i18next/i18next       |
| react-i18next | /i18next/react-i18next |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production i18next patterns",
      researchGoal: "Search for translation and namespace patterns",
      reasoning: "Need real-world examples of i18n setup",
      keywordsToSearch: ["useTranslation", "i18next", "namespace"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Configuration: `keywordsToSearch: ["i18n.init", "resources", "fallbackLng"]`
- Pluralization: `keywordsToSearch: ["_one", "_other", "count", "i18next"]`
- React usage: `keywordsToSearch: ["useTranslation", "Trans", "react-i18next"]`
  </research>

<few_shot_examples>
<example name="namespace-setup">
<input>Set up i18n with separate namespaces for common UI elements and dashboard-specific text</input>
<output>
**src/i18n/index.ts:**
```typescript
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

// Import translation files
import enCommon from "./locales/en/common.json";
import enDashboard from "./locales/en/dashboard.json";
import deCommon from "./locales/de/common.json";
import deDashboard from "./locales/de/dashboard.json";

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: {
        common: enCommon,
        dashboard: enDashboard,
      },
      de: {
        common: deCommon,
        dashboard: deDashboard,
      },
    },
    defaultNS: "common",
    fallbackLng: "en",
    interpolation: {
      escapeValue: false, // React handles escaping
    },
    detection: {
      order: ["localStorage", "navigator"],
      caches: ["localStorage"],
    },
  });

export default i18n;
```

**src/i18n/locales/en/common.json:**
```json
{
  "button": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "confirm": "Confirm"
  },
  "validation": {
    "required": "This field is required",
    "email": "Please enter a valid email"
  },
  "navigation": {
    "home": "Home",
    "settings": "Settings",
    "logout": "Log out"
  }
}
```

**src/i18n/locales/en/dashboard.json:**
```json
{
  "title": "Dashboard",
  "welcome": "Welcome back, {{name}}!",
  "stats": {
    "users": "Total Users",
    "revenue": "Revenue",
    "orders": "Orders"
  },
  "recent_activity": "Recent Activity",
  "no_data": "No data available"
}
```

**Usage in component:**
```tsx
import { useTranslation } from "react-i18next";

function Dashboard({ userName }: { userName: string }) {
  const { t } = useTranslation("dashboard");
  const { t: tCommon } = useTranslation("common");

  return (
    <div>
      <h1>{t("title")}</h1>
      <p>{t("welcome", { name: userName })}</p>
      <button>{tCommon("button.save")}</button>
    </div>
  );
}
```
</output>
<reasoning>Separates common UI text (buttons, validation) from feature-specific text (dashboard). Uses browser language detection with localStorage persistence. Demonstrates namespace-scoped hooks.</reasoning>
</example>

<example name="pluralization-and-context">
<input>Add translations for items count with pluralization and gendered greetings</input>
<output>
**src/i18n/locales/en/common.json:**
```json
{
  "item_zero": "No items",
  "item_one": "{{count}} item",
  "item_other": "{{count}} items",

  "message_zero": "You have no messages",
  "message_one": "You have {{count}} new message",
  "message_other": "You have {{count}} new messages",

  "greeting_male": "Welcome back, Mr. {{name}}",
  "greeting_female": "Welcome back, Ms. {{name}}",
  "greeting_other": "Welcome back, {{name}}",

  "last_seen_male": "He was last seen {{time}}",
  "last_seen_female": "She was last seen {{time}}",
  "last_seen_other": "They were last seen {{time}}"
}
```

**Usage in component:**
```tsx
import { useTranslation } from "react-i18next";

interface User {
  name: string;
  gender: "male" | "female" | "other";
  messageCount: number;
  lastSeen: string;
}

function UserProfile({ user }: { user: User }) {
  const { t } = useTranslation();

  return (
    <div>
      {/* Gender context */}
      <h1>{t("greeting", { context: user.gender, name: user.name })}</h1>

      {/* Pluralization */}
      <p>{t("message", { count: user.messageCount })}</p>

      {/* Combined: gender + variable */}
      <p>{t("last_seen", { context: user.gender, time: user.lastSeen })}</p>

      {/* Zero handling */}
      <p>{t("item", { count: 0 })}</p>  {/* "No items" */}
      <p>{t("item", { count: 1 })}</p>  {/* "1 item" */}
      <p>{t("item", { count: 5 })}</p>  {/* "5 items" */}
    </div>
  );
}
```

**German translations (different plural rules):**
```json
{
  "item_zero": "Keine Artikel",
  "item_one": "{{count}} Artikel",
  "item_other": "{{count}} Artikel",

  "greeting_male": "Willkommen zurück, Herr {{name}}",
  "greeting_female": "Willkommen zurück, Frau {{name}}",
  "greeting_other": "Willkommen zurück, {{name}}"
}
```
</output>
<reasoning>Shows pluralization with _zero, _one, _other suffixes (i18next pluralization categories). Demonstrates context for gender-specific text. German example shows that some languages have same plural form but different greetings.</reasoning>
</example>
</few_shot_examples>

<related_skills>

**React components:** Load via `Skill({ skill: "devtools:react" })` when:

- Building language switcher components
- Integrating translations with forms
- Managing locale state

**Zod validation:** Load via `Skill({ skill: "devtools:zod" })` when:

- Validating locale codes
- Building typed translation keys
  </related_skills>

<success_criteria>

1. [ ] Context7 docs fetched for current API
2. [ ] i18n configured with fallback language
3. [ ] Translations organized by namespace
4. [ ] Pluralization works correctly
5. [ ] No hardcoded strings in components
6. [ ] Language switcher implemented (if needed)
</success_criteria>

<evolution>
**Extension Points:**
- Add language detection plugins for browser/server
- Create extraction scripts for translation keys
- Build locale-aware formatting utilities

**Timelessness:** Internationalization requirements grow with global reach; i18next patterns scale from single-language to multi-region deployments.
</evolution>
