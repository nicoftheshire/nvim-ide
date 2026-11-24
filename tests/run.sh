#!/usr/bin/env bash
# Runs the headless feedkeys-driven test suite (ticket 12) against the real
# nvim-ide config, under its real NVIM_APPNAME so it shares the already
# lazy.nvim-installed plugins.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

NVIM_APPNAME=nvim-ide nvim --headless -u init.lua -c "lua dofile('tests/run.lua')"
