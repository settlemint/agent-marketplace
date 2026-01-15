# Standard Workflow

A general-purpose workflow for most development tasks.

## Phases

### Phase 1: Planning

1. **Define scope**: What exactly needs to be accomplished?
2. **Gather requirements**: What are the constraints and dependencies?
3. **Create task breakdown**: Split into manageable pieces
4. **Estimate effort**: How long will each task take?
5. **Identify risks**: What could go wrong?

**Checkpoint:** Requirements clear and tasks defined

### Phase 2: Setup

1. **Create branch**: New feature branch from main
2. **Setup environment**: Ensure all dependencies ready
3. **Review related code**: Understand the context
4. **Prepare tests**: Identify what needs testing

**Checkpoint:** Environment ready, context understood

### Phase 3: Implementation

1. **Write tests first**: TDD approach
2. **Implement solution**: Focus on minimal viable
3. **Verify tests pass**: All tests green
4. **Code review prep**: Self-review the changes

**Checkpoint:** Implementation complete, tests passing

### Phase 4: Quality Assurance

1. **Run full test suite**: Catch regressions
2. **Check code style**: Linting and formatting
3. **Review for security**: No vulnerabilities introduced
4. **Performance check**: No degradation

**Checkpoint:** Quality gates passed

### Phase 5: Delivery

1. **Update documentation**: If needed
2. **Create pull request**: With clear description
3. **Address feedback**: From reviewers
4. **Merge and deploy**: When approved

**Checkpoint:** Merged to main, deployed

## Success Criteria

- [ ] All tasks completed
- [ ] Tests passing
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Deployed successfully
