#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/navigate.sh"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat > "$tmp_dir/herdr" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > "$HERDR_TEST_LOG"
EOF
chmod +x "$tmp_dir/herdr"

HERDR_BIN_PATH="$tmp_dir/deleted-herdr" \
HERDR_TEST_LOG="$tmp_dir/invocation" \
HERDR_PANE_ID="" \
PATH="$tmp_dir:/usr/bin:/bin" \
  "$script" left
grep -Fxq 'pane focus --direction left --current' "$tmp_dir/invocation"

set +e
HERDR_BIN_PATH="$tmp_dir/deleted-herdr" \
PATH="/usr/bin:/bin" \
  "$script" right 2>"$tmp_dir/error"
status=$?
set -e

[ "$status" -eq 127 ]
grep -Fq 'navigate.sh: unable to find an executable herdr' "$tmp_dir/error"
