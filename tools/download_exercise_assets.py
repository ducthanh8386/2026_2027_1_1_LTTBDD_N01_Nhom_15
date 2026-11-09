#!/usr/bin/env python3
"""
tools/download_exercise_assets.py

Downloads real exercise demonstration media (animated GIFs and thumbnails)
from the community-preserved Gym Visual / exercises-dataset archive.

Maps all 48 curated exercises in assets/data/exercises_seed.json:
- Saves animated GIFs to assets/exercises/gifs/{source_id}.gif
- Saves thumbnail images to assets/exercises/images/{source_id}.jpg
"""

import json
import os
import sys
import urllib.request
import time

REMOTE_DATASET_URL = (
    "https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/data/exercises.json"
)
MEDIA_BASE_URL = (
    "https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/{media_id}.gif"
)

# Custom mapping for non-matching IDs
CUSTOM_MEDIA_MAP = {
    "0062": "DsgkuIt",  # Dumbbell Lateral Raise (0334)
    "0093": "dK9394r",  # Burpee (1160)
}


def download_media():
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    seed_path = os.path.join(project_root, "assets", "data", "exercises_seed.json")
    gifs_dir = os.path.join(project_root, "assets", "exercises", "gifs")
    images_dir = os.path.join(project_root, "assets", "exercises", "images")

    os.makedirs(gifs_dir, exist_ok=True)
    os.makedirs(images_dir, exist_ok=True)

    print(f"[*] Reading curated seed from: {seed_path}")
    with open(seed_path, "r", encoding="utf-8") as f:
        seed_data = json.load(f)

    target_ids = [x["source_id"] for x in seed_data]
    print(f"[*] Total exercises to download: {len(target_ids)}")

    print(f"[*] Fetching remote exercise metadata index...")
    req = urllib.request.Request(
        REMOTE_DATASET_URL, headers={"User-Agent": "FitTrack-Downloader/1.0"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        remote_data = json.loads(resp.read().decode("utf-8"))

    remote_id_map = {x["id"]: x.get("media_id") for x in remote_data if "id" in x}

    success_count = 0
    total_bytes = 0

    for idx, sid in enumerate(target_ids, 1):
        media_id = CUSTOM_MEDIA_MAP.get(sid) or remote_id_map.get(sid)
        if not media_id:
            print(f"[-] [{idx}/{len(target_ids)}] No media_id found for exercise {sid}")
            continue

        gif_url = MEDIA_BASE_URL.format(media_id=media_id)
        gif_dest = os.path.join(gifs_dir, f"{sid}.gif")
        img_dest = os.path.join(images_dir, f"{sid}.jpg")

        try:
            mreq = urllib.request.Request(
                gif_url, headers={"User-Agent": "FitTrack-Downloader/1.0"}
            )
            with urllib.request.urlopen(mreq, timeout=15) as mresp:
                content = mresp.read()

            with open(gif_dest, "wb") as gf:
                gf.write(content)

            # Copy to image asset so thumbnail decoder has the real image
            with open(img_dest, "wb") as imgf:
                imgf.write(content)

            total_bytes += len(content)
            success_count += 1
            print(
                f"[+] [{idx:02d}/{len(target_ids)}] Downloaded {sid} ({media_id}.gif) - {len(content) // 1024} KB"
            )
            time.sleep(0.05)
        except Exception as e:
            print(f"[!] [{idx:02d}/{len(target_ids)}] Error downloading {sid} ({gif_url}): {e}")

    print("\n" + "=" * 50)
    print(f"[SUCCESS] Downloaded {success_count}/{len(target_ids)} exercise media assets.")
    print(f"[INFO] Total media downloaded: {total_bytes / (1024 * 1024):.2f} MB")
    print("=" * 50)


if __name__ == "__main__":
    download_media()

