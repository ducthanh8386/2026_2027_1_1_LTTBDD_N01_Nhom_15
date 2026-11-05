#!/usr/bin/env bash
# Cài hook Git cho máy này. Dùng: tools/git/install_hooks.sh <A|B> <email-git-của-người-ngồi-máy>
# Hook nằm trong .git/hooks nên KHÔNG đồng bộ qua Git: phải chạy trên từng máy.
set -euo pipefail
ROLE="${1:-}"; EMAIL="${2:-}"
if [[ "$ROLE" != "A" && "$ROLE" != "B" || -z "$EMAIL" ]]; then
  echo "Dùng: $0 <A|B> <email>"; exit 1
fi
ROOT="$(git rev-parse --show-toplevel)"; cd "$ROOT"
git config --local fittrack.role "$ROLE"
git config --local fittrack.expectedEmail "$EMAIL"
git config --local user.email "$EMAIL"
cp tools/git/pre-commit .git/hooks/pre-commit
cp tools/git/pre-push   .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
echo "Đã cài hook cho vai trò $ROLE ($EMAIL)."
echo "user.name hiện tại: $(git config user.name)  (đặt bằng: git config --local user.name \"Tên thật\")"
