#!/usr/bin/env python3
"""
tools/check_arb.py - Localization ARB file auditor.

Compares app_en.arb and app_vi.arb:
1. Validates JSON syntax.
2. Checks for missing/extra keys between locales.
3. Checks for placeholder consistency in formatted messages.
4. Returns non-zero exit code if errors are found.

Standard Python 3 libraries only.
"""

import argparse
import json
import os
import re
import sys
from typing import Dict, List, Set, Tuple

PLACEHOLDER_REGEX = re.compile(r'\{([a-zA-Z0-9_]+)\}')


def load_arb(path: str) -> Tuple[dict, List[str]]:
    errors = []
    if not os.path.isfile(path):
        errors.append(f"File not found: {path}")
        return {}, errors

    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data, errors
    except json.JSONDecodeError as e:
        errors.append(f"Invalid JSON in {path}: {e}")
        return {}, errors
    except Exception as e:
        errors.append(f"Failed to read {path}: {e}")
        return {}, errors


def extract_keys(arb: dict) -> Tuple[Set[str], Dict[str, Set[str]]]:
    """
    Extracts message keys and their placeholder names.
    Ignores metadata keys starting with '@'.
    """
    message_keys = set()
    placeholders = {}

    for key, val in arb.items():
        if key.startswith('@@'):
            continue  # @@locale
        if key.startswith('@'):
            continue  # metadata descriptor

        message_keys.add(key)
        if isinstance(val, str):
            matches = set(PLACEHOLDER_REGEX.findall(val))
            placeholders[key] = matches
        else:
            placeholders[key] = set()

    return message_keys, placeholders


def check_arb(en_path: str, vi_path: str) -> int:
    print(f"[*] Auditing ARB localization files:")
    print(f"    EN: {en_path}")
    print(f"    VI: {vi_path}")

    en_data, en_errors = load_arb(en_path)
    vi_data, vi_errors = load_arb(vi_path)

    all_errors = []
    all_errors.extend(en_errors)
    all_errors.extend(vi_errors)

    if all_errors:
        print("\n[ERROR] JSON / File loading failures:")
        for err in all_errors:
            print(f"  - {err}")
        return 1

    en_keys, en_placeholders = extract_keys(en_data)
    vi_keys, vi_placeholders = extract_keys(vi_data)

    missing_in_vi = en_keys - vi_keys
    missing_in_en = vi_keys - en_keys

    placeholder_mismatches = []
    common_keys = en_keys & vi_keys

    for key in sorted(common_keys):
        en_ph = en_placeholders.get(key, set())
        vi_ph = vi_placeholders.get(key, set())
        if en_ph != vi_ph:
            placeholder_mismatches.append(
                f"Key '{key}': EN has {sorted(en_ph)}, VI has {sorted(vi_ph)}"
            )

    has_errors = False

    if missing_in_vi:
        has_errors = True
        print(f"\n[ERROR] {len(missing_in_vi)} keys present in EN but missing in VI:")
        for k in sorted(missing_in_vi):
            print(f"  - {k}")

    if missing_in_en:
        has_errors = True
        print(f"\n[ERROR] {len(missing_in_en)} keys present in VI but missing in EN:")
        for k in sorted(missing_in_en):
            print(f"  - {k}")

    if placeholder_mismatches:
        has_errors = True
        print(f"\n[ERROR] {len(placeholder_mismatches)} placeholder mismatches detected:")
        for m in placeholder_mismatches:
            print(f"  - {m}")

    print("\n--- Summary ---")
    print(f"  Total keys in EN: {len(en_keys)}")
    print(f"  Total keys in VI: {len(vi_keys)}")
    print(f"  Common keys:      {len(common_keys)}")

    if has_errors:
        print("\n[FAIL] ARB audit found inconsistencies. Please resolve them.")
        return 1
    else:
        print("\n[SUCCESS] ARB localization files are 100% consistent!")
        return 0


def main():
    parser = argparse.ArgumentParser(description="Audit ARB localization files.")
    parser.add_argument(
        "--en",
        default="lib/l10n/app_en.arb",
        help="Path to English ARB file (default: lib/l10n/app_en.arb)",
    )
    parser.add_argument(
        "--vi",
        default="lib/l10n/app_vi.arb",
        help="Path to Vietnamese ARB file (default: lib/l10n/app_vi.arb)",
    )

    args = parser.parse_args()

    # Resolve paths relative to current working directory or script directory
    en_path = args.en
    vi_path = args.vi

    if not os.path.isabs(en_path) and not os.path.exists(en_path):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_dir = os.path.dirname(script_dir)
        alt_en = os.path.join(project_dir, en_path)
        if os.path.exists(alt_en):
            en_path = alt_en

    if not os.path.isabs(vi_path) and not os.path.exists(vi_path):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_dir = os.path.dirname(script_dir)
        alt_vi = os.path.join(project_dir, vi_path)
        if os.path.exists(alt_vi):
            vi_path = alt_vi

    exit_code = check_arb(en_path, vi_path)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
