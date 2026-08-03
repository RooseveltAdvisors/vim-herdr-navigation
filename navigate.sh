#!/usr/bin/env bash
#
# vim-herdr-navigation — herdr side
#
# Invoked by a herdr keybind as: navigate.sh <left|down|up|right> [force]
#
# If the focused pane is running Vim/Neovim in the foreground, hand the matching
# Ctrl chord to that pane so Vim moves between its own splits (and, at a split
# edge, calls back into herdr to cross the pane boundary — see editor/*). The same
# forwarding can be turned on for other TUIs that own Ctrl+h/j/k/l themselves via
# HERDR_NAV_PASSTHROUGH_RE (off by default — see below). For any other foreground
# process, move herdr's pane focus directly.
#
# Pass a second argument `force` (or set HERDR_NAV_FORCE_FOCUS=1) to always move
# herdr pane focus and never forward into the editor. Bind this to Option/Alt+hjkl
# so navigation still works when Neovim is focused and would otherwise swallow keys.
#
# Requires `jq`. Without it, detection is skipped and every key just moves the
# herdr pane focus (no Vim awareness).

set -euo pipefail

dir="${1:?usage: navigate.sh <left|down|up|right> [force]}"
mode="${2:-}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_PANE_ID:-}"

case "$dir" in
  left)  key="ctrl+h" ;;
  down)  key="ctrl+j" ;;
  up)    key="ctrl+k" ;;
  right) key="ctrl+l" ;;
  *) echo "navigate.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

force=0
if [ "$mode" = "force" ] || [ "${HERDR_NAV_FORCE_FOCUS:-}" = "1" ]; then
  force=1
fi

focus_pane() {
  if [ -n "$pane" ]; then
    exec "$herdr" pane focus --direction "$dir" --pane "$pane"
  fi
  exec "$herdr" pane focus --direction "$dir" --current
}

if [ "$force" -eq 1 ]; then
  focus_pane
fi

# Foreground process names that mean "Vim is in control of this pane".
# Same matcher vim-tmux-navigator uses: vi, vim, nvim, view, gvim, *diff, ...
vim_re='^g?(view|l?n?vim?x?)(diff)?$'

# Opt-in passthrough for non-Vim TUIs (see README): HERDR_NAV_PASSTHROUGH_RE is an
# ERE matched against the lower-cased process name. Empty (default) forwards only Vim.
passthrough_re="${HERDR_NAV_PASSTHROUGH_RE:-}"

forward=0
if [ -n "$pane" ] && command -v jq >/dev/null 2>&1; then
  if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
    | jq -e --arg vim "$vim_re" --arg pass "$passthrough_re" \
        '.result.process_info.foreground_processes[]?.name
         | ascii_downcase
         | select(test($vim) or ($pass != "" and (try test($pass) catch false)))' >/dev/null 2>&1; then
    forward=1
  fi
fi

if [ "$forward" -eq 1 ]; then
  exec "$herdr" pane send-keys "$pane" "$key"
fi

focus_pane
