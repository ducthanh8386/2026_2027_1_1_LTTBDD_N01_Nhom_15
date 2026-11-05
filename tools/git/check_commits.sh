#!/usr/bin/env bash
# Kiểm tra TỪNG commit trong khoảng có analyze sạch (đề yêu cầu mỗi commit build được).
# Dùng: tools/git/check_commits.sh <base> [head=HEAD] [--build]
#   vd: tools/git/check_commits.sh origin/main        (các commit của nhánh hiện tại)
# --build: chạy thêm `flutter build apk --debug` (chậm). Chỉ đọc, dùng git worktree tạm.
set -uo pipefail
BASE="${1:?base}"; HEAD_REF="${2:-HEAD}"; MODE="${3:-}"
[[ "$HEAD_REF" == "--build" ]] && { MODE="--build"; HEAD_REF="HEAD"; }
ROOT="$(git rev-parse --show-toplevel)"; TMP="$(mktemp -d)"; FAIL=0
trap 'git -C "$ROOT" worktree remove --force "$TMP/wt" >/dev/null 2>&1; rm -rf "$TMP"' EXIT
for c in $(git rev-list --reverse "$BASE..$HEAD_REF"); do
  git -C "$ROOT" worktree add -f --detach "$TMP/wt" "$c" >/dev/null 2>&1 || { echo "✖ worktree $c"; FAIL=1; continue; }
  ( cd "$TMP/wt" && flutter pub get >/dev/null 2>&1 && flutter gen-l10n >/dev/null 2>&1; \
    flutter analyze --no-pub >/tmp/fittrack_an.log 2>&1 && \
    { [[ "$MODE" != "--build" ]] || flutter build apk --debug >/tmp/fittrack_bd.log 2>&1; } )
  RC=$?
  if [[ $RC -eq 0 ]]; then echo "✔ $(git -C "$ROOT" log -1 --format='%h %s' "$c")"
  else echo "✖ $(git -C "$ROOT" log -1 --format='%h %s' "$c")"; FAIL=1; fi
  git -C "$ROOT" worktree remove --force "$TMP/wt" >/dev/null 2>&1
done
exit $FAIL
