#!/usr/bin/bash 
# ================================================================================
# Bash Initialization File (.bashrc)
# ================================================================================
#
# Description:
#   This file serves as the primary entry point for interactive Bash sessions.
#   It initializes the shell environment by sourcing modular configuration
#   components that define PATH behavior, common settings, aliases, and
#   tool-specific enhancements.
#
#   The configuration is structured in a layered, modular fashion:
#
#     1. Core environment setup
#        - PATH configuration
#        - Common cross-shell settings
#
#     2. General shell enhancements
#        - Aliases and utility functions
#        - Web search helpers
#
#     3. Bash-specific configuration
#        - History behavior
#        - Prompt configuration
#
#     4. Conditional tool integrations
#        - Arch Linux package management (pacman)
#        - Git workflow enhancements
#
#   Design goals:
#     - Modular (each concern isolated in its own file)
#     - Portable (graceful handling of missing tools/files)
#     - Efficient (only loads what is needed)
#     - Maintainable (clear separation of responsibilities)
#
# Usage:
#   This file is automatically sourced by Bash for interactive shells.
#   It should remain lightweight and delegate functionality to the
#   configuration files located in:
#
#       ~/.config/shell/
#
# Notes:
#   - Non-interactive shells exit early to avoid unnecessary overhead
#   - All sourced files are conditionally loaded for safety
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   February 22, 2022
#   Updated:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================

[[ $- != *i* ]] && return

[ -f "$HOME/.config/shell/path.sh" ] && . "$HOME/.config/shell/path.sh"
[ -f "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"
[ -f "$HOME/.config/shell/aliases.sh" ] && . "$HOME/.config/shell/aliases.sh"
[ -f "$HOME/.config/shell/web_search.sh" ] && . "$HOME/.config/shell/web_search.sh"
[ -f "$HOME/.config/shell/bash_only.sh" ] && . "$HOME/.config/shell/bash_only.sh"

if command -v pacman >/dev/null 2>&1; then
    [ -f "$HOME/.config/shell/arch_aliases.sh" ] && . "$HOME/.config/shell/arch_aliases.sh"
fi

if command -v git >/dev/null 2>&1; then
    [ -f "$HOME/.config/shell/git_aliases.sh" ] && . "$HOME/.config/shell/git_aliases.sh"
fi
# ================================================================================ 
# ================================================================================ 
# eof
