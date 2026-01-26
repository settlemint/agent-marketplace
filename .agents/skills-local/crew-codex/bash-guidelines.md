# Bash Guidelines

## Output buffering
- Avoid piping through `head`, `tail`, `less`, `more` - causes buffering issues
- Let commands complete fully, or use command-specific flags (e.g., `git log -n 10` not `git log | head -10`)
- Read files directly rather than piping through filters
