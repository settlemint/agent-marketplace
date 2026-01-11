---
name: crew:git:branch:create
description: Create a feature branch
model: haiku
allowed-tools:
  - Skill
---

<objective>

Delegate to branch creation command.

</objective>

<workflow>

## Step 1: Create Branch

```javascript
Skill({ skill: "crew:git:branch:new", args: "--base main" });
```

</workflow>

<success_criteria>

- [ ] Branch created via delegated skill

</success_criteria>
