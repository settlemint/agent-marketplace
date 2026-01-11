#!/usr/bin/env python3
"""Validate task files in .claude/branches/<branch>/tasks/

Usage: validate_tasks.py [branch]
  If branch not specified, uses current git branch (slugified).

Output format (one line per issue):
  ERROR: <file>: <message>
  WARN: <file>: <message>

Exit codes:
  0 = all valid
  1 = errors found
"""

import os
import re
import sys
from pathlib import Path

# Task filename pattern: {order}-{status}-{priority}-{story}-{slug}.md
FILENAME_PATTERN = re.compile(
    r'^(\d{3})-(pending|in_progress|complete)-(p[123])-([a-z0-9]+)-(.+)\.md$'
)

VALID_STATUSES = {'pending', 'in_progress', 'complete'}
VALID_PRIORITIES = {'p1', 'p2', 'p3'}


def slugify_branch(branch: str) -> str:
    """Convert branch name to slug (/ -> -)."""
    return branch.replace('/', '-')


def get_current_branch() -> str:
    """Get current git branch name."""
    import subprocess
    result = subprocess.run(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        capture_output=True, text=True
    )
    return result.stdout.strip()


def parse_frontmatter(content: str) -> dict:
    """Extract YAML frontmatter from markdown content."""
    if not content.startswith('---'):
        return {}

    lines = content.split('\n')
    end_idx = -1
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == '---':
            end_idx = i
            break

    if end_idx == -1:
        return {}

    frontmatter = {}
    for line in lines[1:end_idx]:
        if ':' in line:
            key, _, value = line.partition(':')
            frontmatter[key.strip()] = value.strip()

    return frontmatter


def validate_task_file(filepath: Path) -> list[tuple[str, str]]:
    """Validate a single task file. Returns list of (level, message)."""
    issues = []
    filename = filepath.name

    # Check filename pattern
    match = FILENAME_PATTERN.match(filename)
    if not match:
        issues.append(('ERROR', f'Invalid filename format: {filename}'))
        return issues

    order, file_status, file_priority, file_story, slug = match.groups()

    # Read and parse file
    try:
        content = filepath.read_text()
    except Exception as e:
        issues.append(('ERROR', f'Cannot read file: {e}'))
        return issues

    frontmatter = parse_frontmatter(content)

    # Check frontmatter exists
    if not frontmatter:
        issues.append(('ERROR', 'Missing YAML frontmatter'))
        return issues

    # Check required fields
    required = ['status', 'priority', 'story']
    for field in required:
        if field not in frontmatter:
            issues.append(('ERROR', f'Missing required field: {field}'))

    # Check status matches filename
    fm_status = frontmatter.get('status', '')
    if fm_status and fm_status != file_status:
        issues.append(('ERROR', f'Status mismatch: filename={file_status}, frontmatter={fm_status}'))

    # Check priority matches filename
    fm_priority = frontmatter.get('priority', '')
    if fm_priority and fm_priority != file_priority:
        issues.append(('ERROR', f'Priority mismatch: filename={file_priority}, frontmatter={fm_priority}'))

    # Check story matches filename
    fm_story = frontmatter.get('story', '')
    if fm_story and fm_story != file_story:
        issues.append(('WARN', f'Story mismatch: filename={file_story}, frontmatter={fm_story}'))

    # Check for acceptance criteria
    if 'Given' not in content and 'Acceptance' not in content:
        issues.append(('WARN', 'No acceptance criteria found'))

    # Check parallel field for pending tasks
    if file_status == 'pending' and 'parallel' not in frontmatter:
        issues.append(('WARN', 'Pending task missing parallel field'))

    return issues


def main():
    # Determine branch
    if len(sys.argv) > 1:
        branch = sys.argv[1]
    else:
        branch = get_current_branch()

    slug = slugify_branch(branch)
    tasks_dir = Path('.claude/branches') / slug / 'tasks'

    if not tasks_dir.exists():
        print(f'No tasks directory: {tasks_dir}')
        sys.exit(0)

    task_files = sorted(tasks_dir.glob('*.md'))
    if not task_files:
        print(f'No task files in {tasks_dir}')
        sys.exit(0)

    has_errors = False
    for filepath in task_files:
        issues = validate_task_file(filepath)
        for level, message in issues:
            print(f'{level}: {filepath.name}: {message}')
            if level == 'ERROR':
                has_errors = True

    if not has_errors:
        print(f'OK: {len(task_files)} task files validated')

    sys.exit(1 if has_errors else 0)


if __name__ == '__main__':
    main()
