---
name: crew:work:feature-video
description: Record a video walkthrough of a feature and add it to the PR description
argument-hint: "[PR number or 'current'] [optional: base URL, default localhost:3000]"
allowed-tools:
  [
    "Bash",
    "Read",
    "Write",
    "Edit",
    "Glob",
    "Grep",
    "MCPSearch",
    "AskUserQuestion",
    "mcp__claude-in-chrome__*",
  ]
---

# Feature Video Walkthrough

<command_purpose>Record a video walkthrough demonstrating a feature, upload it, and add it to the PR description using Claude's native browser automation.</command_purpose>

## Introduction

<role>Developer Relations Engineer creating feature demo videos</role>

This command creates professional video walkthroughs of features for PR documentation:

- Records browser interactions using Claude-in-Chrome extension
- Demonstrates the complete user flow with screenshots or GIF recording
- Uploads the video to GitHub for sharing
- Updates the PR description with an embedded video/GIF

## Prerequisites Check

<prerequisites>
Before starting, verify required tools are available:

```bash
# Check for ffmpeg (required for video/GIF creation)
if ! command -v ffmpeg &>/dev/null; then
  echo "ffmpeg not found. Installing via Homebrew..."
  if command -v brew &>/dev/null; then
    brew install ffmpeg
  else
    echo "ERROR: Homebrew not found. Please install ffmpeg manually:"
    echo "  macOS: brew install ffmpeg"
    echo "  Ubuntu: sudo apt install ffmpeg"
    echo "  Windows: choco install ffmpeg"
    exit 1
  fi
fi
echo "ffmpeg: $(ffmpeg -version | head -1)"

# Check for gh CLI (required for PR operations)
if ! command -v gh &>/dev/null; then
  echo "ERROR: GitHub CLI (gh) not found. Please install it:"
  echo "  macOS: brew install gh"
  echo "  Then: gh auth login"
  exit 1
fi
echo "gh: $(gh --version | head -1)"

# Verify gh is authenticated
if ! gh auth status &>/dev/null; then
  echo "ERROR: GitHub CLI not authenticated. Run: gh auth login"
  exit 1
fi
```

**Browser Requirements:**

- Claude-in-Chrome extension must be active
- Load browser tools via MCPSearch before use
  </prerequisites>

## Main Tasks

### 1. Parse Arguments

<parse_args>

**Arguments:** $ARGUMENTS

Parse the input:

- First argument: PR number or "current" (defaults to current branch's PR)
- Second argument: Base URL (defaults to `http://localhost:3000`)

```bash
# Get PR number for current branch if needed
gh pr view --json number -q '.number' 2>/dev/null || echo "No PR found for current branch"
```

</parse_args>

### 2. Setup Browser Tools

<setup_browser>

Load the required Claude-in-Chrome MCP tools:

```javascript
// Load browser navigation and screenshot tools
MCPSearch({ query: "select:mcp__claude-in-chrome__navigate" });
MCPSearch({ query: "select:mcp__claude-in-chrome__computer" });
MCPSearch({ query: "select:mcp__claude-in-chrome__gif_creator" });
MCPSearch({ query: "select:mcp__claude-in-chrome__read_page" });
MCPSearch({ query: "select:mcp__claude-in-chrome__tabs_context_mcp" });
MCPSearch({ query: "select:mcp__claude-in-chrome__form_input" });
```

Get current browser context:

```javascript
mcp__claude-in-chrome__tabs_context_mcp({});
```

</setup_browser>

### 3. Gather Feature Context

<gather_context>

**Get PR details:**

```bash
gh pr view [number] --json title,body,files,headRefName -q '.'
```

**Get changed files:**

```bash
gh pr view [number] --json files -q '.files[].path'
```

**Identify testable routes from changed files:**

- Look for route definitions, page components, or API endpoints
- Map file patterns to likely URLs
- Ask user to confirm the target URL if unclear

</gather_context>

### 4. Plan the Video Flow

<plan_flow>

Before recording, create a shot list:

1. **Opening shot**: Homepage or starting point (2-3 seconds)
2. **Navigation**: How user gets to the feature
3. **Feature demonstration**: Core functionality (main focus)
4. **Edge cases**: Error states, validation, etc. (if applicable)
5. **Success state**: Completed action/result

Ask user to confirm or adjust the flow:

```markdown
**Proposed Video Flow**

Based on PR #[number]: [title]

1. Start at: /[starting-route]
2. Navigate to: /[feature-route]
3. Demonstrate:
   - [Action 1]
   - [Action 2]
   - [Action 3]
4. Show result: [success state]

Estimated duration: ~[X] seconds

Does this look right?

1. Yes, start recording
2. Modify the flow (describe changes)
3. Add specific interactions to demonstrate
```

</plan_flow>

### 5. Setup Recording Directory

<setup_recording>

```bash
# Create directories for screenshots and videos
mkdir -p tmp/videos tmp/screenshots

# Clean any previous screenshots
rm -f tmp/screenshots/*.png 2>/dev/null || true

echo "Recording directories ready:"
echo "  Screenshots: tmp/screenshots/"
echo "  Videos: tmp/videos/"
```

</setup_recording>

### 6. Record the Walkthrough

<record_walkthrough>

**Option A: GIF Recording (Recommended)**

Use the gif_creator tool for smooth recording:

```javascript
// Start GIF recording
mcp__claude-in-chrome__gif_creator({
  action: "start",
  filename: "tmp/videos/feature-demo.gif"
});

// Navigate to starting point
mcp__claude-in-chrome__navigate({ url: "[base-url]/[start-route]" });

// Wait for page load and capture
// ... perform interactions ...

// Stop recording
mcp__claude-in-chrome__gif_creator({
  action: "stop"
});
```

**Option B: Screenshot-based Video**

If GIF recording isn't available, capture screenshots at each step:

```javascript
// Step 1: Navigate to starting point
mcp__claude-in-chrome__navigate({ url: "[base-url]/[start-route]" });
// Wait 2 seconds for page to load
mcp__claude-in-chrome__computer({ action: "screenshot" });
// Save screenshot to tmp/screenshots/01-start.png

// Step 2: Perform navigation
mcp__claude-in-chrome__computer({ action: "click", coordinate: [x, y] });
// Wait for transition
mcp__claude-in-chrome__computer({ action: "screenshot" });
// Save to tmp/screenshots/02-navigate.png

// Step 3: Demonstrate feature
mcp__claude-in-chrome__form_input({ ... });
mcp__claude-in-chrome__computer({ action: "screenshot" });
// Save to tmp/screenshots/03-feature.png

// Step 4: Capture result
mcp__claude-in-chrome__computer({ action: "screenshot" });
// Save to tmp/screenshots/04-result.png
```

**Convert screenshots to video:**

```bash
# Create MP4 video (best quality, good compression)
# -framerate 0.5 = 2 seconds per frame
ffmpeg -y -framerate 0.5 -pattern_type glob -i 'tmp/screenshots/*.png' \
  -c:v libx264 -pix_fmt yuv420p -vf "scale=1280:-2" \
  tmp/videos/feature-demo.mp4

# Create preview GIF (small file for GitHub embed)
ffmpeg -y -framerate 0.5 -pattern_type glob -i 'tmp/screenshots/*.png' \
  -vf "scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse" \
  -loop 0 tmp/videos/feature-demo-preview.gif

echo "Videos created:"
ls -la tmp/videos/
```

</record_walkthrough>

### 7. Upload to GitHub and Update PR

<upload_and_update_pr>

**Get repository info:**

```bash
# Get repo owner and name
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
PR_NUMBER=[number]
```

**Upload video as GitHub release asset:**

For larger videos (MP4), create a release asset:

```bash
# Create a release for PR assets (if not exists)
RELEASE_TAG="pr-assets"
if ! gh release view "$RELEASE_TAG" &>/dev/null; then
  gh release create "$RELEASE_TAG" --title "PR Demo Assets" --notes "Automated demo videos for pull requests"
fi

# Upload video to release
gh release upload "$RELEASE_TAG" tmp/videos/feature-demo.mp4 --clobber

# Get the download URL
VIDEO_URL="https://github.com/${REPO}/releases/download/${RELEASE_TAG}/feature-demo.mp4"
echo "Video URL: $VIDEO_URL"
```

**Upload GIF directly to PR comment (GitHub will host it):**

For GIFs under 10MB, GitHub automatically hosts images uploaded via the API:

```bash
# Get current PR body
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q '.body')

# Create a PR comment with the GIF - GitHub will host the image
# The GIF will be uploaded when you drag-drop or use the web UI
# For CLI, we'll reference the release asset or use a comment
```

**Add demo section to PR description:**

```bash
# Get current PR body
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q '.body')

# Check if Demo section already exists
if echo "$CURRENT_BODY" | grep -q "## Demo"; then
  # Replace existing Demo section (up to next ## or end)
  NEW_BODY=$(echo "$CURRENT_BODY" | sed '/## Demo/,/^## [^D]/{ /^## [^D]/!d; }')
else
  NEW_BODY="$CURRENT_BODY"
fi

# Append new Demo section
DEMO_SECTION="## Demo

![Feature Demo]($VIDEO_URL)

_Feature walkthrough recorded with Claude Code_"

# Update PR
gh pr edit $PR_NUMBER --body "${NEW_BODY}

${DEMO_SECTION}"
```

**Alternative: Add as PR comment (simpler):**

```bash
gh pr comment $PR_NUMBER --body "## Feature Demo

https://github.com/${REPO}/releases/download/${RELEASE_TAG}/feature-demo.mp4

_Automated walkthrough of the changes in this PR_"
```

**Note:** GitHub renders video URLs from releases as playable videos in PR comments and descriptions.

</upload_and_update_pr>

### 8. Cleanup

<cleanup>

```bash
# Optional: Clean up screenshots (keep videos)
# rm -rf tmp/screenshots

echo "Recording complete!"
echo ""
echo "Files retained:"
ls -la tmp/videos/ 2>/dev/null || echo "  (no videos)"
```

</cleanup>

### 9. Summary

<summary>

Present completion summary:

```markdown
## Feature Video Complete

**PR:** #[number] - [title]
**Video:** [url or local path]
**Duration:** ~[X] seconds
**Format:** [GIF/MP4]

### Shots Captured

1. [Starting point] - [description]
2. [Navigation] - [description]
3. [Feature demo] - [description]
4. [Result] - [description]

### PR Updated

- [x] Video section added to PR description
- [ ] Ready for review

**Next steps:**

- Review the video to ensure it accurately demonstrates the feature
- Share with reviewers for context
```

</summary>

## Quick Usage Examples

```bash
# Record video for current branch's PR
/crew:work:feature-video

# Record video for specific PR
/crew:work:feature-video 847

# Record with custom base URL
/crew:work:feature-video 847 http://localhost:5000

# Record for staging environment
/crew:work:feature-video current https://staging.example.com
```

## Tips

- **Keep it short**: 10-30 seconds is ideal for PR demos
- **Focus on the change**: Don't include unrelated UI
- **Show before/after**: If fixing a bug, show the broken state first (if possible)
- **Use GIF for GitHub**: GitHub can't embed external MP4s, use GIF preview linking to video
- **Check browser extension**: Ensure Claude-in-Chrome is active before recording
