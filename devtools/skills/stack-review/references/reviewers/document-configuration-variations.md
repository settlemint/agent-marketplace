# Document configuration variations

> **Repository:** oven-sh/bun
> **Dependencies:** @types/bun

When documenting or implementing configuration options, always include variations needed for different environments and use cases. Ensure that your configuration files, installation guides, and rule definitions cover all common scenarios.

For installation instructions, include platform-specific commands and hardware variations:
```powershell
# Standard installation
winget install Oven-sh.Bun

# For CPUs without AVX2 instruction set support
winget install Oven-sh.Bun.Baseline
```

For rule definitions and pattern matching, include all relevant files:
```
globs: *.ts, *.tsx, *.html, *.css, *.js, *.jsx, package.json
```

This ensures users can successfully set up and use the system regardless of their specific environment, and automation tools will properly process all configuration files.