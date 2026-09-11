#!/usr/bin/env bash
# Small, dependency-free terminal scene used only to record the README demo.
set -eu

row=0
col=0

draw() {
  local -a panes=("nvim  ▸ app/routes.ts" "shell  ▸ herdr status" "nvim  ▸ README.md" "logs   ▸ demo.log")
  printf '\033[2J\033[H'
  printf '\033[1;38;5;117m vim-herdr-navigation \033[0m  '
  printf '\033[38;5;245mCtrl+h/j/k/l  •  one focus model\033[0m\n\n'
  for r in 0 1; do
    for c in 0 1; do
      i=$((r * 2 + c))
      if [ "$r" -eq "$row" ] && [ "$c" -eq "$col" ]; then
        printf '\033[1;48;5;24m  ● %-26s\033[0m' "${panes[$i]}"
      else
        printf '\033[38;5;245m  ○ %-26s\033[0m' "${panes[$i]}"
      fi
      [ "$c" -eq 0 ] && printf '  '
    done
    printf '\n'
    for c in 0 1; do
      i=$((r * 2 + c))
      if [ "$r" -eq "$row" ] && [ "$c" -eq "$col" ]; then
        printf '\033[1;38;5;117m  %-30s\033[0m' "${panes[$i]}"
      else
        printf '\033[38;5;245m  %-30s\033[0m' "${panes[$i]}"
      fi
      [ "$c" -eq 0 ] && printf '  '
    done
    printf '\n'
    for c in 0 1; do
      i=$((r * 2 + c))
      if [ "$r" -eq "$row" ] && [ "$c" -eq "$col" ]; then
        printf '\033[1;38;5;255m  %-30s\033[0m' "pane $((i + 1))  <ACTIVE>"
      else
        printf '\033[38;5;245m  %-30s\033[0m' "pane $((i + 1))"
      fi
      [ "$c" -eq 0 ] && printf '  '
    done
    printf '\n\n'
  done
  printf '\033[38;5;245m  Press '
  printf '\033[1;38;5;117mCtrl+h/j/k/l\033[0m'
  printf '\033[38;5;245m to hop focus • q to quit\033[0m\n'
}

move() {
  case "$1" in
    h) col=0 ;; l) col=1 ;; k) row=0 ;; j) row=1 ;;
  esac
  draw
}

trap 'printf "\033[0m\033[2J\033[H"' EXIT
draw
while IFS= read -r -n1 key; do
  case "$key" in
    h|$'\x08') move h ;;
    j|$'\x0a') move j ;;
    k|$'\x0b') move k ;;
    l|$'\x0c') move l ;;
    q) exit 0 ;;
  esac
done
