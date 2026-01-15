#!/usr/bin/env python3
"""
Flow skill validation utility.
Validates skill structure and content against conventions.
"""

import sys
import os
import re
import yaml
from pathlib import Path


def validate_frontmatter(content: str) -> tuple[bool, list[str]]:
    """Validate YAML frontmatter in skill file."""
    errors = []

    # Check for frontmatter delimiters
    if not content.startswith("---"):
        errors.append("Missing frontmatter: File must start with '---'")
        return False, errors

    # Extract frontmatter
    parts = content.split("---", 2)
    if len(parts) < 3:
        errors.append("Invalid frontmatter: Missing closing '---'")
        return False, errors

    frontmatter_text = parts[1].strip()

    try:
        frontmatter = yaml.safe_load(frontmatter_text)
    except yaml.YAMLError as e:
        errors.append(f"Invalid YAML in frontmatter: {e}")
        return False, errors

    # Required fields
    required_fields = ["name", "description"]
    for field in required_fields:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    return len(errors) == 0, errors


def validate_xml_tags(content: str) -> tuple[bool, list[str]]:
    """Validate required XML tags in skill body."""
    errors = []

    # Required tags
    required_tags = ["objective", "quick_start", "success_criteria"]

    for tag in required_tags:
        open_tag = f"<{tag}>"
        close_tag = f"</{tag}>"

        if open_tag not in content:
            errors.append(f"Missing required tag: <{tag}>")
        elif close_tag not in content:
            errors.append(f"Unclosed tag: <{tag}> (missing </{tag}>)")

    # Check for unclosed tags
    tag_pattern = re.compile(r"<([a-z_]+)>")
    close_pattern = re.compile(r"</([a-z_]+)>")

    open_tags = set(tag_pattern.findall(content))
    close_tags = set(close_pattern.findall(content))

    unclosed = open_tags - close_tags
    for tag in unclosed:
        if tag not in ["br", "hr"]:  # Self-closing tags
            errors.append(f"Unclosed tag: <{tag}>")

    return len(errors) == 0, errors


def validate_skill_file(filepath: Path) -> tuple[bool, list[str]]:
    """Validate a single skill file."""
    errors = []

    if not filepath.exists():
        return False, [f"File not found: {filepath}"]

    content = filepath.read_text()

    # Validate frontmatter
    fm_valid, fm_errors = validate_frontmatter(content)
    errors.extend(fm_errors)

    # Validate XML tags
    xml_valid, xml_errors = validate_xml_tags(content)
    errors.extend(xml_errors)

    return len(errors) == 0, errors


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: validate-skill.py <skill-file-or-directory>")
        sys.exit(1)

    target = Path(sys.argv[1])

    if target.is_file():
        files = [target]
    elif target.is_dir():
        files = list(target.glob("**/SKILL.md"))
    else:
        print(f"Error: {target} is not a valid file or directory")
        sys.exit(1)

    all_valid = True

    for filepath in files:
        valid, errors = validate_skill_file(filepath)

        if valid:
            print(f"✓ {filepath}")
        else:
            all_valid = False
            print(f"✗ {filepath}")
            for error in errors:
                print(f"  - {error}")

    sys.exit(0 if all_valid else 1)


if __name__ == "__main__":
    main()
