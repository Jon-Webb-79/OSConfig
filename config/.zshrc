#!/usr/bin/zsh
# ================================================================================
# Zsh Initialization File (.zshrc)
# ================================================================================
#
# Description:
#   This file serves as the primary entry point for interactive Zsh sessions.
#   It initializes the shell environment by sourcing modular configuration
#   components that define PATH behavior, shared settings, aliases, and
#   Zsh-specific enhancements.
#
#   The configuration follows a layered, modular architecture:
#
#     1. Core environment setup
#        - PATH configuration
#        - Common cross-shell settings
#
#     2. General shell enhancements
#        - Aliases and utility functions
#        - Web search helpers
#
#     3. Zsh-specific configuration
#        - History behavior
#        - Completion system
#        - Plugins and prompt configuration
#
#     4. Conditional tool integrations
#        - Arch Linux package management (pacman)
#        - Git workflow enhancements
#
#   Design goals:
#     - Modular (each concern isolated in its own file)
#     - Portable (graceful handling of missing tools/files)
#     - Efficient (only loads what is required)
#     - Maintainable (clear separation of responsibilities)
#
# Usage:
#   This file is automatically sourced by Zsh for interactive shells.
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
#   Updated:   (update as needed)
#   Version:   2.0
#
# ================================================================================
# ================================================================================ 

[[ -o interactive ]] || return

[ -f "$HOME/.config/shell/path.sh" ] && source "$HOME/.config/shell/path.sh"
[ -f "$HOME/.config/shell/common.sh" ] && source "$HOME/.config/shell/common.sh"
[ -f "$HOME/.config/shell/aliases.sh" ] && source "$HOME/.config/shell/aliases.sh"
[ -f "$HOME/.config/shell/web_search.sh" ] && source "$HOME/.config/shell/web_search.sh"
[ -f "$HOME/.config/shell/zsh_only.zsh" ] && source "$HOME/.config/shell/zsh_only.zsh"

if command -v pacman >/dev/null 2>&1; then
    [ -f "$HOME/.config/shell/arch_aliases.sh" ] && source "$HOME/.config/shell/arch_aliases.sh"
fi

if command -v git >/dev/null 2>&1; then
    [ -f "$HOME/.config/shell/git_aliases.sh" ] && source "$HOME/.config/shell/git_aliases.sh"
fi
# ================================================================================
# ================================================================================
# eof
