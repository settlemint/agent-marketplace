# Optimization Workflow

A structured approach to optimization that ensures measurable improvement without introducing regressions.

## Prerequisites

- [ ] Clear optimization target defined
- [ ] Test suite available and passing
- [ ] Ability to measure target metric
- [ ] Time allocated for careful work

## Phases

### Phase 1: Baseline Measurement

**Goal:** Establish current state

1. **Define metrics**: What exactly are we measuring?
   - Performance: Response time, memory usage, bundle size
   - Quality: Complexity score, duplication percentage
   - Debt: Count of issues, dependency age

2. **Take measurements**: Record current values

   ```
   Metric: [name]
   Current value: [value]
   Target value: [goal]
   Measured at: [timestamp]
   Method: [how measured]
   ```

3. **Document environment**: Ensure reproducibility
   - System specs
   - Node/runtime version
   - Dependencies

**Checkpoint:** Baseline documented, target set

### Phase 2: Analysis

**Goal:** Understand what to optimize

1. **Profile/analyze**: Use appropriate tools
   - Performance: Profiler, flame graphs
   - Quality: Static analysis, code review
   - Debt: Audit tools, manual review

2. **Identify candidates**: List potential optimizations

3. **Prioritize**: Rank by impact vs effort
   | Candidate | Expected Impact | Effort | Priority |
   |-----------|-----------------|--------|----------|
   | ... | High/Med/Low | High/Med/Low | 1-N |

**Checkpoint:** Optimization candidates prioritized

### Phase 3: Implementation

**Goal:** Make improvements safely

For each optimization (highest priority first):

1. **Create branch**: Isolate changes

2. **Write test first**: If not already covered
   - Test current behavior
   - Test expected improvement

3. **Implement change**: Focus and minimal
   - One optimization at a time
   - Keep changes small
   - Maintain readability

4. **Verify tests pass**: All tests green

5. **Measure improvement**: Compare to baseline

6. **Document change**: What, why, and impact

**Loop until:** Targets met or diminishing returns

**Checkpoint:** Improvements implemented and verified

### Phase 4: Validation

**Goal:** Ensure no regressions

1. **Run full test suite**: Must pass

2. **Run integration tests**: If available

3. **Manual testing**: Critical paths

4. **Performance regression check**: No new problems

**Checkpoint:** All validation passed

### Phase 5: Finalization

**Goal:** Complete and document

1. **Final measurements**: Record improved metrics

   ```
   Metric: [name]
   Before: [baseline]
   After: [new value]
   Improvement: [percentage]
   ```

2. **Update documentation**: If needed

3. **Create PR**: With clear description of changes

4. **Merge and monitor**: Watch for issues

## Success Metrics

- [ ] Baseline established
- [ ] Optimizations prioritized
- [ ] Changes implemented incrementally
- [ ] All tests passing
- [ ] Improvement measured and documented
- [ ] No regressions introduced

## Rollback Plan

If problems arise after merge:

1. Revert the PR immediately
2. Investigate the issue
3. Fix and re-attempt with more caution
4. Consider smaller increments

## Post-Optimization Review

After completion, reflect:

- Did we hit our targets?
- What worked well?
- What would we do differently?
- Are there follow-up optimizations?
