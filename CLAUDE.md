# Claude Code Guidelines

## Versioning Requirements

When modifying any plugin, you MUST update version numbers in ALL locations.

### Semantic Versioning

- **PATCH** (x.y.Z): Bug fixes, documentation, minor tweaks
- **MINOR** (x.Y.0): New features, backward-compatible changes
- **MAJOR** (X.0.0): Breaking changes, removed features

### Files to Update

For each plugin change, update these files:

#### 1. Plugin Manifest
`<plugin>/.claude-plugin/plugin.json` → Update `"version"` field

#### 2. Root README
`README.md` → Update version in plugin section header:
- `### Plan Mode (vX.Y.Z)`
- `### Build Mode (vX.Y.Z)`
- `### Git (vX.Y.Z)`

#### 3. Plugin README
`<plugin>/README.md` → Update version in:
- Title: `# <Plugin> Plugin vX.Y.Z`
- Version History section (add entry describing changes)

### Version History Format

Add a new entry at the top of the Version History section:

```markdown
- **vX.Y.Z**: Brief description of changes
```

If the plugin README lacks a Version History section, add one before the License section.

### When to Version

**DO bump version:**
- New features, commands, agents, skills, hooks
- Bug fixes
- Configuration changes
- Behavior changes

**DON'T bump version:**
- Typo fixes in comments
- Whitespace/formatting only
- Changes to unrelated files

### Checklist

Before completing any plugin change:
- [ ] Determine version bump type (patch/minor/major)
- [ ] Update `<plugin>/.claude-plugin/plugin.json`
- [ ] Update `README.md` section header
- [ ] Update `<plugin>/README.md` title
- [ ] Add Version History entry in `<plugin>/README.md`
