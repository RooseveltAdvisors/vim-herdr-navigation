# Vision

Upstream built this plugin so `Ctrl+h/j/k/l` moves across herdr panes and Vim/Neovim splits as one surface, the way `vim-tmux-navigator` does for tmux.
This fork exists so the operator who lives in herdr and Vim every day can fix what their own daily operation breaks, on their own machines and at their own cadence, without waiting on upstream.

## Why the fork exists

Herdr injects `$HERDR_BIN_PATH` into every pane, and that path goes stale when Herdr is upgraded or reinstalled.
Upstream trusted the variable blindly, so an upgrade could leave every keypress failing until the path was repaired by hand.
The fork's founding fix is the guard against exactly that: every consumer - shell, Vim, and Neovim - uses the injected path only when it is executable, falls back to `herdr` from PATH otherwise, and reports the failure on stderr with exit 127 when neither works.
The same operational honesty shaped the rest of what the fork carries: `navigate.sh` validates the requested direction before it resolves Herdr, so a bad invocation (exit 2) and a missing Herdr (exit 127) stay distinct and diagnosable.
It also carries the machinery to keep such fixes trustworthy: a CI workflow running shellcheck, syntax checks, and a behavioral test suite that drives `navigate.sh` through a mock herdr binary instead of asserting on source text.
Those checks replaced the Makefile and the source-only assertions the fork inherited, because a test that never runs the code cannot catch a broken binary.

## What the fork must never diverge on

The user-facing contract is upstream's contract, held exactly.
Four actions, one per direction, bound to plain `Ctrl+h/j/k/l`; the action ids in `herdr-plugin.toml`; the edge-crossing handshake between `navigate.sh` and `editor/nvim.lua` and `editor/vim.vim`; the `HERDR_NAV_PASSTHROUGH_RE` opt-in for other TUIs - all stay as upstream defines them.
It stays a plain script plugin: bash plus `jq` plus calls to the `herdr` CLI, no build step, and no dependencies beyond what upstream already requires of a herdr `>= 0.7.0` user on Linux or macOS.
It stays MIT-licensed so fixes can travel in both directions.
A behavior fix that proves itself here is expected to be proposed upstream rather than accumulate as permanent private drift.

## What the fork refuses to own

It refuses to grow the key surface: force-focus Option/Alt+`hjkl` actions were tried here and deliberately removed, because every added chord collides with something a user already relies on.
It refuses multiplexers other than herdr; tmux users already have `vim-tmux-navigator`.
It refuses features that are not focus and key forwarding - pane layouts, session management, remote control - and refuses to bind maps beyond the normal-mode defaults users can extend themselves.

## Non-goals

- No actions beyond left, down, up, right.
- No tmux or GNU screen support.
- No insert- or terminal-mode mappings by default.
- No configuration file of its own; the herdr config and environment variables are the only knobs.
- No installer beyond `herdr plugin link`.

## Done well, one year out

A Herdr upgrade lands on the machines that run this fork and navigation keeps working off PATH without anyone touching a config.
Every merge here is green on CI and covered by a behavioral test that would have failed for the regression class it guards.
The diff against upstream stays small enough to explain line by line, and each divergence carries either an upstream proposal or a recorded reason to remain fork-only.
A user of upstream could switch to this fork and notice only that it breaks less and says so plainly when it cannot navigate.
