# Fast-Track Workflow

A streamlined workflow for urgent fixes and small changes.

## When to Use

- Critical bug fixes
- Single-file changes
- Documentation updates
- Configuration tweaks
- Urgent hotfixes

## Phases

### Phase 1: Quick Assessment (5 min)

1. **Understand the issue**: What's broken or needed?
2. **Identify scope**: Single file or minimal changes
3. **Check risk**: Is this safe to fast-track?

**Go/No-go decision:** If scope is larger than expected, use Standard Workflow instead.

### Phase 2: Rapid Implementation (15-30 min)

1. **Create branch**: `hotfix/description` or `quick/description`
2. **Make change**: Focus and minimal
3. **Verify locally**: Quick test that it works
4. **Run tests**: Must pass

### Phase 3: Express Review (10 min)

1. **Self-review**: Check the diff
2. **Create PR**: Mark as urgent/hotfix
3. **Request expedited review**: Tag appropriate reviewer
4. **Address critical feedback only**: Minor issues can wait

### Phase 4: Deploy

1. **Merge when approved**
2. **Deploy immediately**
3. **Verify in production**
4. **Monitor for issues**

## Success Criteria

- [ ] Issue resolved
- [ ] Tests passing
- [ ] Reviewed and approved
- [ ] Deployed and verified

## Guardrails

**DO NOT fast-track if:**

- Changes span multiple files significantly
- New features are being added
- Database migrations are involved
- Security-sensitive changes
- You're unsure about the impact

**Always fast-track with:**

- Clear rollback plan
- Monitoring in place
- Communication to team
