---
name: crew:work:feature-video
description: Record a video walkthrough of a feature and add it to the PR description
argument-hint: "[PR number or 'current'] [optional: base URL, default localhost:3000]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - MCPSearch
  - AskUserQuestion
---

<objective>

Record browser walkthrough demonstrating a feature using Claude-in-Chrome, create GIF, upload to GitHub release, and embed in PR description.

</objective>

<workflow>

## Step 1: Check Prerequisites

```bash
# Verify ffmpeg and gh CLI are available
command -v ffmpeg || echo "ERROR: ffmpeg required - brew install ffmpeg"
command -v gh || echo "ERROR: gh required - brew install gh"
gh auth status || echo "ERROR: gh not authenticated - gh auth login"
```

## Step 2: Parse Arguments

```javascript
const args = "$ARGUMENTS".split(" ");
const prNumber = args[0] || "current";
const baseUrl = args[1] || "http://localhost:3000";

// Get PR number if "current"
if (prNumber === "current") {
  const pr = Bash({ command: "gh pr view --json number -q '.number'" });
}
```

## Step 3: Get PR Context

```bash
gh pr view $PR_NUMBER --json title,body,files,headRefName -q '.'
```

## Step 4: Setup Browser Tools

```javascript
MCPSearch({ query: "select:mcp__claude-in-chrome__navigate" });
MCPSearch({ query: "select:mcp__claude-in-chrome__gif_creator" });
MCPSearch({ query: "select:mcp__claude-in-chrome__tabs_context_mcp" });
MCPSearch({ query: "select:mcp__claude-in-chrome__form_input" });
MCPSearch({ query: "select:mcp__claude-in-chrome__computer" });

mcp__claude-in-chrome__tabs_context_mcp({});
```

## Step 5: Plan Video Flow

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Video flow for PR #${prNumber}:\n1. Start: ${baseUrl}\n2. Navigate to feature\n3. Demonstrate interactions\n4. Show result\n\nProceed?`,
      header: "Flow",
      options: [
        { label: "Yes", description: "Start recording" },
        { label: "Modify", description: "Describe changes" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 6: Record GIF

```javascript
// Setup recording directory
Bash({ command: "mkdir -p tmp/videos && rm -f tmp/videos/*.gif" });

// Start GIF recording
mcp__claude-in-chrome__gif_creator({
  action: "start",
  filename: "tmp/videos/feature-demo.gif",
});

// Navigate and perform interactions
mcp__claude-in-chrome__navigate({ url: `${baseUrl}/feature-route` });
// ... perform user flow interactions ...

// Stop recording
mcp__claude-in-chrome__gif_creator({ action: "stop" });
```

## Step 7: Upload to GitHub Release

```bash
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
RELEASE_TAG="pr-assets"

# Create release if not exists
gh release view "$RELEASE_TAG" || gh release create "$RELEASE_TAG" \
  --title "PR Demo Assets" --notes "Automated demo videos"

# Upload GIF
gh release upload "$RELEASE_TAG" tmp/videos/feature-demo.gif --clobber

VIDEO_URL="https://github.com/${REPO}/releases/download/${RELEASE_TAG}/feature-demo.gif"
```

## Step 8: Update PR Description

```bash
# Get current body and append demo section
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q '.body')

gh pr edit $PR_NUMBER --body "${CURRENT_BODY}

## Demo

![Feature Demo](${VIDEO_URL})

_Feature walkthrough recorded with Claude Code_"
```

## Step 9: Report Completion

```javascript
console.log(`Feature video complete:
- PR: #${prNumber}
- Video: ${videoUrl}
- PR updated with demo section`);
```

</workflow>

<success_criteria>

- [ ] Prerequisites verified (ffmpeg, gh)
- [ ] Browser tools loaded via MCPSearch
- [ ] GIF recorded with gif_creator
- [ ] Video uploaded to GitHub release
- [ ] PR description updated with demo section

</success_criteria>
