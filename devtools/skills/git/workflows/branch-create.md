---
name: branch-create
description: Create feature branch with naming convention
---

<objective>
Create branch: `username/type/slug` from main.
</objective>

<workflow>

1. **Get username:**

   ```bash
   whoami
   ```

2. **Determine type:** feat, fix, hotfix, or chore

3. **Generate slug:** kebab-case from description, max 30 chars

4. **Create branch:**
   ```bash
   git fetch origin main
   git checkout -b ${username}/${type}/${slug} origin/main
   ```

</workflow>

<examples>

```bash
# Feature branch
git checkout -b roderik/feat/asset-transfer origin/main

# Bug fix
git checkout -b roderik/fix/balance-calc origin/main

# Chore
git checkout -b roderik/chore/update-deps origin/main
```

</examples>

<success_criteria>

- [ ] Branch follows `username/type/slug` pattern
- [ ] Created from origin/main

</success_criteria>
