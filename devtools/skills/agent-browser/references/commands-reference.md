# agent-browser Commands Reference

## Navigation

```bash
agent-browser open <url>              # Navigate to URL
agent-browser back                    # Go back
agent-browser forward                 # Go forward
agent-browser reload                  # Reload page
agent-browser close                   # Close browser
```

## Snapshots (AI-critical)

```bash
agent-browser snapshot                # Full accessibility tree
agent-browser snapshot -i             # Interactive elements only
agent-browser snapshot -i --json      # JSON output with refs
agent-browser snapshot -c             # Compact (no empty nodes)
agent-browser snapshot -d 3           # Limit depth
agent-browser snapshot -s "#form"     # Scope to selector
```

## Interactions

```bash
agent-browser click @e2               # Click by ref
agent-browser fill @e3 "text"         # Fill input
agent-browser type "text"             # Type without clearing
agent-browser press Enter             # Keyboard key
agent-browser hover @e4               # Hover over element
agent-browser check @e5               # Check checkbox
agent-browser select @e6 "option"     # Select dropdown
agent-browser scroll down 500         # Scroll by pixels
agent-browser scrollintoview @e7      # Scroll element into view
```

## Information

```bash
agent-browser get text @e1            # Get element text
agent-browser get html @e1            # Get element HTML
agent-browser get value @e1           # Get input value
agent-browser get attr @e1 href       # Get attribute
agent-browser get title               # Page title
agent-browser get url                 # Current URL
agent-browser is visible @e1          # Check visibility
```

## Screenshots/PDF

```bash
agent-browser screenshot              # Screenshot to stdout
agent-browser screenshot output.png   # Save to file
agent-browser screenshot -f           # Full page
agent-browser pdf output.pdf          # PDF export
```

## Wait Conditions

```bash
agent-browser wait @e1                # Wait for visibility
agent-browser wait 2000               # Wait milliseconds
agent-browser wait --text "Success"   # Wait for text
agent-browser wait --url "**/done"    # Wait for URL pattern
agent-browser wait --load networkidle # Wait for network idle
```

## Sessions (Parallel Browsers)

```bash
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com
agent-browser session list            # Show active sessions
AGENT_BROWSER_SESSION=agent1 agent-browser click @e1
```

## Advanced

```bash
agent-browser eval "document.title"   # Execute JavaScript
agent-browser --headed open url       # Show browser window
agent-browser set viewport 1920 1080  # Set viewport size
agent-browser set device "iPhone 14"  # Device emulation
agent-browser network route "**/api" --abort  # Block requests
agent-browser tab new                 # New tab
agent-browser tab 2                   # Switch to tab
```

## Selectors

**Selector types (in order of preference):**

1. **Refs (recommended)** - From snapshot output

   ```bash
   agent-browser click @e2
   ```

2. **Semantic locators** - Accessibility-based

   ```bash
   agent-browser click "role button[name=Submit]"
   agent-browser fill "label Email" "user@example.com"
   ```

3. **CSS selectors** - When needed

   ```bash
   agent-browser click "#submit-btn"
   agent-browser fill ".email-input" "text"
   ```

4. **Text selectors** - Match visible text
   ```bash
   agent-browser click "text=Submit"
   ```
