#!/usr/bin/env python3
"""
FitTrack - Exercise Dataset Curation & Validation Tool
Owned by Partner B (Le Van Son). Standard library only.

Usage:
  python tools/curate_exercises.py --check
  python tools/curate_exercises.py --stats
  python tools/curate_exercises.py --seed assets/data/exercises_seed.json --plans assets/data/sample_plans.json --check
"""

import argparse
import json
import os
import sys
from collections import Counter


def check_seed_and_plans(seed_path: str, plans_path: str, assets_dir: str = "assets/exercises") -> int:
    """Validates exercises_seed.json and sample_plans.json according to contract.md."""
    errors = []
    warnings = []

    if not os.path.exists(seed_path):
        print(f"[ERROR] Seed file not found: {seed_path}", file=sys.stderr)
        return 1

    try:
        with open(seed_path, "r", encoding="utf-8") as f:
            exercises = json.load(f)
    except Exception as e:
        print(f"[ERROR] Failed to parse JSON in {seed_path}: {e}", file=sys.stderr)
        return 1

    if not isinstance(exercises, list):
        print(f"[ERROR] Root of {seed_path} must be a JSON array.", file=sys.stderr)
        return 1

    print(f"[*] Loaded {len(exercises)} exercises from {seed_path}")

    # Check for unique source_id and required fields
    source_ids = set()
    body_parts = Counter()
    equipments = Counter()

    for idx, ex in enumerate(exercises):
        sid = ex.get("source_id")
        if not sid:
            errors.append(f"Exercise #{idx} missing 'source_id'")
            continue

        if sid in source_ids:
            errors.append(f"Duplicate source_id found: '{sid}' at index {idx}")
        source_ids.add(sid)

        name_en = ex.get("name_en", "")
        name_vi = ex.get("name_vi", "")
        body_part = ex.get("body_part", "")
        equipment = ex.get("equipment", "")

        if not name_en or not name_en.strip():
            errors.append(f"Exercise '{sid}' missing 'name_en'")
        if not name_vi or not name_vi.strip():
            warnings.append(f"Exercise '{sid}' ({name_en}) missing 'name_vi'")
        if not body_part or not body_part.strip():
            errors.append(f"Exercise '{sid}' missing 'body_part'")
        else:
            body_parts[body_part] += 1

        if equipment:
            equipments[equipment] += 1

        # Check media assets if defined
        img = ex.get("image_asset")
        if img:
            full_img_path = img.replace("/", os.sep)
            if not os.path.exists(full_img_path):
                warnings.append(f"Exercise '{sid}' image asset not found on disk: {img}")

        gif = ex.get("gif_asset")
        if gif:
            full_gif_path = gif.replace("/", os.sep)
            if not os.path.exists(full_gif_path):
                warnings.append(f"Exercise '{sid}' gif asset not found on disk: {gif}")

    # Validate sample_plans.json
    if plans_path and os.path.exists(plans_path):
        try:
            with open(plans_path, "r", encoding="utf-8") as f:
                plans = json.load(f)
            if not isinstance(plans, list):
                errors.append(f"Root of {plans_path} must be a JSON array.")
            else:
                print(f"[*] Validating {len(plans)} plans in {plans_path}...")
                for p_idx, plan in enumerate(plans):
                    p_name = plan.get("name_en", f"Plan #{p_idx}")
                    days = plan.get("days", [])
                    if not days:
                        errors.append(f"Plan '{p_name}' has no days.")
                    for d_idx, day in enumerate(days):
                        d_name = day.get("name_en", f"Day #{d_idx}")
                        items = day.get("items", [])
                        if not items:
                            errors.append(f"Plan '{p_name}' - '{d_name}' has no items.")
                        for item in items:
                            item_sid = item.get("source_id")
                            if not item_sid:
                                errors.append(f"Item in '{p_name}' -> '{d_name}' missing source_id.")
                            elif item_sid not in source_ids:
                                errors.append(f"Plan item source_id '{item_sid}' not found in seed dataset!")
                            sets = item.get("sets", 0)
                            reps = item.get("reps", 0)
                            if sets <= 0 or reps <= 0:
                                errors.append(f"Item '{item_sid}' in '{p_name}' has invalid sets ({sets}) or reps ({reps}).")
        except Exception as e:
            errors.append(f"Failed to read {plans_path}: {e}")

    # Summary report
    print("\n--- Statistics by Body Part ---")
    for bp, count in body_parts.most_common():
        print(f"  {bp:15}: {count:3d}")

    print("\n--- Statistics by Equipment ---")
    for eq, count in equipments.most_common():
        print(f"  {eq:15}: {count:3d}")

    if warnings:
        print(f"\n[WARNINGS] ({len(warnings)} found):")
        for w in warnings[:10]:
            print(f"  - {w}")
        if len(warnings) > 10:
            print(f"  ... and {len(warnings) - 10} more warnings.")

    if errors:
        print(f"\n[ERRORS] ({len(errors)} found):", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print("\n[SUCCESS] All checks passed cleanly with 0 errors!")
    return 0


def main():
    parser = argparse.ArgumentParser(description="FitTrack Exercise Curation Tool")
    parser.add_argument("--seed", default="assets/data/exercises_seed.json", help="Path to exercises_seed.json")
    parser.add_argument("--plans", default="assets/data/sample_plans.json", help="Path to sample_plans.json")
    parser.add_argument("--check", action="store_true", help="Run contract validation checks")
    parser.add_argument("--stats", action="store_true", help="Print dataset statistics")

    args = parser.parse_args()

    if args.check or args.stats or True:
        sys.exit(check_seed_and_plans(args.seed, args.plans))


if __name__ == "__main__":
    main()

