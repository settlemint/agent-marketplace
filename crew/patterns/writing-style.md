---
description: Writing style for PRs and documentation
globs: "**/commands/git/pr.md,**/commands/git/update-pr.md"
alwaysApply: false
---

# Writing Style

Follow SettleMint style guide for all PR descriptions and documentation.

## Voice and Tone

- **Active voice** - "This PR adds..." not "A feature was added..."
- **Be specific** - "Fixes null pointer in user lookup" not "Fixes bug"
- **Be concise** - Remove unnecessary words

## Formatting

- **Sentence case headings** - "Design decisions" not "Design Decisions"
- **Oxford commas** - "A, B, and C" not "A, B and C"

## Words to Avoid

Never use these overused/vague words:

- seamless
- leverage
- utilize (use "use" instead)
- dive into
- game-changing
- cutting-edge
- unlock
- robust
- scalable (unless quantified)
- innovative

## Adverbs to Cut

Remove these unnecessary adverbs:

- actually
- very
- really
- just
- basically
- simply
- quite

## PR Description Structure

1. **What** - One sentence describing the change
2. **Why** - Motivation/problem being solved
3. **How** - Brief technical approach (if non-obvious)
4. **Testing** - How to verify the change works
