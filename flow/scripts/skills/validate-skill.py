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


def extract_skill_name(content: str) -> str | None:
    """Extract skill name from frontmatter."""
    if not content.startswith("---"):
        return None

    parts = content.split("---", 2)
    if len(parts) < 3:
        return None

    try:
        frontmatter = yaml.safe_load(parts[1].strip())
        return frontmatter.get("name")
    except yaml.YAMLError:
        return None


def extract_related_skills(content: str) -> list[str]:
    """Extract skill references from related_skills section."""
    related_skills = []

    # Look for related_skills tag content
    match = re.search(r"<related_skills>(.*?)</related_skills>", content, re.DOTALL)
    if match:
        section = match.group(1)
        # Extract skill names from Skill() calls
        skill_refs = re.findall(r'Skill\(\s*\{\s*skill:\s*["\']([^"\']+)["\']', section)
        related_skills.extend(skill_refs)
        # Also check for plain skill names in bullet points
        bullet_refs = re.findall(r"[-*]\s*`([a-z][a-z0-9:_-]+)`", section)
        related_skills.extend(bullet_refs)

    return list(set(related_skills))


def validate_skill_name(name: str) -> tuple[bool, list[str]]:
    """Validate skill name follows conventions."""
    errors = []

    if not name:
        errors.append("Skill name is empty")
        return False, errors

    # Check for valid characters
    if not re.match(r"^[a-z][a-z0-9:-]*$", name):
        errors.append(
            f"Invalid skill name '{name}': must be lowercase, start with letter, contain only a-z, 0-9, :, -"
        )

    # Check for proper namespacing
    if ":" in name:
        parts = name.split(":")
        if any(not p for p in parts):
            errors.append(f"Invalid skill name '{name}': empty namespace segment")

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

    # Validate skill name
    name = extract_skill_name(content)
    if name:
        name_valid, name_errors = validate_skill_name(name)
        errors.extend(name_errors)

    # Validate XML tags
    xml_valid, xml_errors = validate_xml_tags(content)
    errors.extend(xml_errors)

    return len(errors) == 0, errors


def validate_dependencies(
    files: list[Path], known_skills: set[str]
) -> tuple[bool, dict[Path, list[str]]]:
    """Validate that all related_skills references exist."""
    dependency_errors: dict[Path, list[str]] = {}

    for filepath in files:
        content = filepath.read_text()
        related = extract_related_skills(content)

        missing = [s for s in related if s not in known_skills]
        if missing:
            dependency_errors[filepath] = [
                f"References unknown skill: {s}" for s in missing
            ]

    return len(dependency_errors) == 0, dependency_errors


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

    # First pass: validate individual files and collect skill names
    known_skills: set[str] = set()
    for filepath in files:
        valid, errors = validate_skill_file(filepath)
        name = extract_skill_name(filepath.read_text())
        if name:
            known_skills.add(name)

        if valid:
            print(f"✓ {filepath}")
        else:
            all_valid = False
            print(f"✗ {filepath}")
            for error in errors:
                print(f"  - {error}")

    # Second pass: validate dependencies
    deps_valid, dep_errors = validate_dependencies(files, known_skills)
    if not deps_valid:
        all_valid = False
        print("\nDependency errors:")
        for filepath, errors in dep_errors.items():
            print(f"✗ {filepath}")
            for error in errors:
                print(f"  - {error}")

    sys.exit(0 if all_valid else 1)


if __name__ == "__main__":
    main()
