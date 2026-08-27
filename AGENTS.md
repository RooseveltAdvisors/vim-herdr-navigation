# vim-herdr-navigation project memory

This plugin joins herdr pane focus with Vim/Neovim split navigation through the
four `Ctrl+h/j/k/l` actions. Start with [README.md](README.md); the shell,
Neovim, and Vim integration contracts live in `navigate.sh`, `editor/nvim.lua`,
and `editor/vim.vim`.

## Invariants and sharp edges

- `$HERDR_BIN_PATH` is injected and can become stale after a Herdr upgrade.
  Every consumer must use it only when executable (`-x` in shell, `executable()`
  in Vim/Neovim), then fall back to `herdr` from `PATH`.
- `navigate.sh` validates the direction before resolving Herdr. Unknown
  directions must retain the stderr error and exit 2; an unresolved Herdr
  executable is the separate exit-127 path.
- The shell and Neovim handoffs target the invoking pane when
  `$HERDR_PANE_ID` is available. `--current` means the server's global focus;
  it is only the shell script's outside-pane fallback.

## Checks

Run the same checks as [`.github/workflows/ci.yml`](.github/workflows/ci.yml):

```bash
shellcheck navigate.sh
bash -n navigate.sh test/navigate_test.sh
bash test/navigate_test.sh
```

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
