---
name: incremental-update
description: Targeted doc refresh based on changed files since last generation
---

<objective>

Efficiently update only the documentation files whose watched files have changed since the last generation. Minimizes agent work and preserves unchanged docs.

</objective>

<trigger>

Activates when:

- `--incremental` flag passed
- Hook detects staleness and triggers refresh
- `.meta.json` exists and is recent (< 24 hours)

</trigger>

<workflow>

## Step 1: Load metadata

```bash
if [[ ! -f ".claude/docs/.meta.json" ]]; then
  echo "error: No .meta.json found. Run full init first."
  echo "hint: Skill({ skill: \"flow:init-enhanced\" })"
  exit 1
fi

LAST_SHA=$(jq -r '.gitSha' .claude/docs/.meta.json)
CURRENT_SHA=$(git rev-parse HEAD)

if [[ "$LAST_SHA" == "$CURRENT_SHA" ]]; then
  echo "info: Docs are up to date (SHA: ${LAST_SHA:0:7})"
  exit 0
fi
```

## Step 2: Get changed files

```bash
CHANGED_FILES=$(git diff --name-only "$LAST_SHA" HEAD 2>/dev/null)
CHANGED_COUNT=$(echo "$CHANGED_FILES" | wc -l)

echo "info: $CHANGED_COUNT files changed since last doc generation"
```

## Step 3: Match changed files to docs

For each doc in `.meta.json`, check if any watched files match:

```javascript
const meta = JSON.parse(fs.readFileSync(".claude/docs/.meta.json"));
const changedFiles = getChangedFiles();
const docsToUpdate = [];

for (const [docName, docMeta] of Object.entries(meta.docs)) {
  const patterns = docMeta.watchPatterns;
  const matches = changedFiles.filter((file) =>
    patterns.some((pattern) => minimatch(file, pattern)),
  );

  if (matches.length > 0) {
    docsToUpdate.push({
      doc: docName,
      reason: matches.slice(0, 3).join(", "),
    });
  }
}
```

## Step 4: Report update plan

```
Docs to update:
- architecture.md (changed: src/index.ts, package.json)
- dependencies.md (changed: package.json)

Docs unchanged:
- api-reference.md
- testing.md
- deployment.md
- glossary.md
```

## Step 5: Launch targeted agents

Only spawn agents for docs that need updates:

```javascript
docsToUpdate.forEach(({ doc, reason }) => {
  const agentPrompt = getAgentPromptForDoc(doc);

  Task({
    subagent_type: "Explore",
    description: `Update ${doc}`,
    prompt: `${agentPrompt}

CONTEXT: Updating due to changes in: ${reason}
Focus on areas affected by these changes.
Keep output under 500 tokens.`,
    run_in_background: true,
  });
});
```

## Step 6: Merge updates

For each updated doc:

1. Read existing content
2. Find `<!-- AUTO-GENERATED: X -->` markers
3. Replace content between markers with new findings
4. Preserve content outside markers

## Step 7: Update .meta.json

```javascript
const now = new Date().toISOString();
meta.gitSha = currentSha;

docsToUpdate.forEach(({ doc }) => {
  meta.docs[doc].updated = now;
});

fs.writeFileSync(".claude/docs/.meta.json", JSON.stringify(meta, null, 2));
```

## Step 8: Summary

```
Updated 2 of 8 docs:
- architecture.md (was 3 days old)
- dependencies.md (was 3 days old)

Skipped 6 unchanged docs.
New SHA: abc1234
```

</workflow>

<efficiency_gains>

| Scenario            | Full Init | Incremental |
| ------------------- | --------- | ----------- |
| All docs stale      | 6 agents  | 6 agents    |
| 2 docs stale        | 6 agents  | 2 agents    |
| Config-only changes | 6 agents  | 1 agent     |
| No relevant changes | 6 agents  | 0 agents    |

Average: 60% reduction in agent work for typical updates.

</efficiency_gains>

<success_criteria>

- [ ] Only stale docs regenerated
- [ ] Unchanged docs preserved exactly
- [ ] `.meta.json` updated with new SHA
- [ ] Manual edits preserved
- [ ] Clear summary of what changed

</success_criteria>
