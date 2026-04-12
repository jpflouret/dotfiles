# AGENTS.md

This file provides guidance to coding agents, including Codex and Claude Code,
when working with code in this repository.

## What This Repo Is

Personal dotfiles for JP Flouret. The `files/` directory contains config files that get symlinked to `~/.<name>` by the install script. The `files/vim/` directory is a git submodule in a separate repo.

## Install

```bash
cd ~
git clone --recursive git@github.com:jpflouret/dotfiles.git
./dotfiles/install.sh -f
```

`install.sh` creates symlinks from `~/.<filename>` to each file in `files/`. The `-f` flag forces overwrite of existing symlinks. There is also `install.bat` for Windows and `install_macos.sh` for macOS-specific setup.

## Architecture

- `files/bashrc` - Main shell config. Detects OS (macOS/Linux/WSL/WSL2/MINGW/Cygwin) into `$OSNAME`. Uses `pathadd_front`/`pathadd_back` helpers for safe PATH management. Configures fzf defaults. Sources `~/.shellfishrc` for ShellFish terminal integration. Auto-launches tmux on login via `lib/tmux_auto.sh` (skipped in VSCode and ShellFish terminals). Defines `ta` alias for interactive tmux session picker. Sources `~/.bashrc_local` for machine-specific overrides.
- `lib/tmux_auto.sh` - tmux session picker and auto-launch functions. Provides `_tmux_pick_and_attach` (interactive session picker using fzf when available, TUI fallback otherwise), `_tmux_auto_start` (auto-attach on login), and `_tmux_motd` (MOTD display). Detaching from a tmux session exits the shell to close the SSH connection.
- `files/profile` - Login shell setup. Fixes umask on Windows, loads RVM, sources bashrc.
- `files/gitconfig` - Git config with GPG signing, pull-rebase, LFS, and `feature.manyFiles`. Uses conditional includes: `gitconfig.d/epic` for Epic Games repos (matched by remote URL), `gitconfig.d/local` for machine-local overrides.
- `files/config.omp.json` - Oh My Posh prompt theme (powerline style). Used by both bashrc and `powershell/profile.ps1`. Segments include OS, SSH host, kubectl, UE project/branch (via `USHELL_*` env vars), node/go/python, git status, and path.
- `files/tmux.conf` - tmux config with vi copy-mode, vim-style pane nav (hjkl), mouse on, 256-color.
- `files/inputrc` - Readline config with vi mode keybindings and case-insensitive completion.
- `files/powershell/profile.ps1` - PowerShell profile loading Oh My Posh and EpicWorkspace module.
- `files/clang-format` - C++ formatting: Allman braces, tabs, no column limit.
- `files/editorconfig` - 4-space indent default, tabs for .cpp, 120 char lines.

## Key Conventions

- Shell is bash with **vi mode** (`set -o vi`).
- The repo targets multiple platforms: macOS, Linux, WSL/WSL2, Cygwin, MINGW, and native Windows (PowerShell).
- Files in `files/` are plain names without dots (e.g., `bashrc` not `.bashrc`). The install script prepends the dot when symlinking.
- `gitconfig.d/` holds conditional git config fragments. `epic` is included for Epic Games remotes; `local` is always included and is machine-specific (not meant to be portable).
- `~/.bashrc_local` is sourced at the end of bashrc for per-machine customization (not tracked in this repo).
- `~/.no_tmux` file suppresses auto-tmux launch.
- `~/.hushlogin` suppresses MOTD and changes tmux auto-launch behavior.

## Adding New Dotfiles

Move the file into `files/` (without the leading dot), then re-run `install.sh -f`.
