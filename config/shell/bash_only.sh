# ================================================================================
# Bash-Specific Shell Configuration
# ================================================================================
#
# Description:
#   This file contains Bash-specific configuration settings that enhance
#   interactive shell behavior, history management, and prompt appearance.
#
#   It is intended to be sourced only when running Bash (not Zsh or other shells),
#   and complements more general shell configuration files by providing features
#   unique to Bash.
#
#   The configuration includes:
#     - Shell option tuning via `shopt`
#     - Enhanced command history behavior and persistence
#     - Automatic history synchronization across sessions
#     - Optional Powerline prompt integration for improved UI/UX
#
#   Features are designed to be:
#     - Non-intrusive (safe defaults for interactive use)
#     - Persistent (history retained across sessions)
#     - Conditional (Powerline only enabled if available)
#
# Usage:
#   Source this file from your ~/.bashrc or equivalent:
#
#       [ -n "$BASH_VERSION" ] && source ~/.config/shell/bash_only.sh
#
#   This ensures the configuration is only applied in Bash environments.
#
# Dependencies (optional):
#     - powerline-daemon (for enhanced prompt)
#     - powerline bash bindings
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================ 

shopt -s cdspell
shopt -s checkwinsize
shopt -s histappend

HISTCONTROL=ignoredups:erasedups
HISTSIZE=5000
HISTFILESIZE=20000
PROMPT_COMMAND='history -a'

# Powerline prompt
if command -v powerline-daemon >/dev/null 2>&1 && \
   [ -r /usr/share/powerline/bindings/bash/powerline.sh ]; then
    powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . /usr/share/powerline/bindings/bash/powerline.sh
fi

# ================================================================================ 
# ================================================================================ 
# eof
