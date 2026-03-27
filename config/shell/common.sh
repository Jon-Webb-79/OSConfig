# ================================================================================
# Common Shell Environment Configuration
# ================================================================================
#
# Description:
#   This file defines environment variables and aliases that are shared across
#   multiple shell environments (e.g., Bash, Zsh). It provides a consistent
#   baseline configuration for editor behavior, command-line utilities, and
#   cross-platform compatibility.
#
#   The configuration includes:
#     - Default editor settings (EDITOR, VISUAL)
#     - Colorized output for common utilities
#     - Standardized command aliases (vim → nvim, grep variants)
#     - Cross-platform file/URL opening helper (xdg-open / open)
#
#   This file is intended to be:
#     - Shell-agnostic (compatible with Bash, Zsh, etc.)
#     - Minimal and stable (only widely portable features included)
#     - Foundational (used by higher-level shell configs)
#
# Usage:
#   Source this file in your shell configuration (e.g., ~/.bashrc, ~/.zshrc):
#
#       source ~/.config/shell/common.sh
#
# Dependencies (optional):
#     - nvim        (for editor aliases)
#     - xdg-open    (Linux)
#     - open        (macOS)
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================ 

export EDITOR='nvim'
export VISUAL='nvim'

export LS_COLORS='di=1;91:fi=0;97:ex=4;32'

alias vim='nvim'

alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

if command -v xdg-open >/dev/null 2>&1; then
    alias open='xdg-open'
elif command -v open >/dev/null 2>&1; then
    alias open='open'
fi

# ================================================================================ 
# ================================================================================ 
# eof

