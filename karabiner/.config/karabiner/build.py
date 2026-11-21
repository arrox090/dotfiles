"""
Karabiner Config Compiler
Compiles modular .jsonc rule files and base.json into ~/.config/karabiner/karabiner.json.
Supports single-line (//) and multi-line (/* */) comments.
"""

import json
import os
import re
import sys
from pathlib import Path

KARABINER_DIR = Path(__file__).resolve().parent
BASE_FILE = KARABINER_DIR / "base.json"
RULES_DIR = KARABINER_DIR / "rules"
OUTPUT_FILE = Path(os.path.expanduser("~/.config/karabiner/karabiner.json"))


def strip_jsonc_comments(text: str) -> str:
    """Strip // and /* */ comments from JSON without affecting strings."""
    pattern = r'(".*?(?<!\\)")|(/\*.*?\*/)|(//.*?$)'

    def replace(match):
        if match.group(1):
            return match.group(1)
        return ""

    return re.sub(pattern, replace, text, flags=re.DOTALL | re.MULTILINE)


def build():
    if not BASE_FILE.exists():
        print(f"Error: {BASE_FILE} not found!", file=sys.stderr)
        sys.exit(1)

    with open(BASE_FILE, "r", encoding="utf-8") as f:
        base_data = json.loads(strip_jsonc_comments(f.read()))

    all_rules = []
    rule_files = sorted(RULES_DIR.glob("*.jsonc"))

    if not rule_files:
        print(f"Warning: No .jsonc files found in {RULES_DIR}", file=sys.stderr)

    for rule_file in rule_files:
        with open(rule_file, "r", encoding="utf-8") as f:
            content = f.read().strip()
            if not content:
                continue

            clean = strip_jsonc_comments(content)

            # Strip trailing commas before } or ]
            clean = re.sub(r",\s*([\]}])", r"\1", clean)
            try:
                parsed = json.loads(clean)
                if isinstance(parsed, list):
                    all_rules.extend(parsed)
                elif isinstance(parsed, dict):
                    all_rules.append(parsed)
            except json.JSONDecodeError as e:
                print(f"Error parsing {rule_file.name}: {e}", file=sys.stderr)
                sys.exit(1)

    # Insert rules into primary profile
    base_data["profiles"][0]["complex_modifications"]["rules"] = all_rules

    # Ensure output directory exists
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    # Write to live ~/.config/karabiner/karabiner.json
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(base_data, f, indent=2)

    print(
        f"✓ Compiled {len(all_rules)} rules from {len(rule_files)} files into {OUTPUT_FILE}"
    )


if __name__ == "__main__":
    build()
