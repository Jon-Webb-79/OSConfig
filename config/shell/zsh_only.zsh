#!/usr/bin/zsh
# ================================================================================
# Zsh-Specific Shell Configuration
# ================================================================================
#
# Description:
#   This file defines Zsh-specific configuration settings to enhance interactive
#   shell behavior, history management, completion, and user experience.
#
#   It is intended to be sourced only in Zsh environments and complements
#   shared/common shell configuration files by providing features unique to Zsh.
#
#   The configuration includes:
#     - Advanced history management and session sharing
#     - Shell behavior customization via `setopt`
#     - Vi-style keybindings
#     - Command-line completion system initialization
#     - Plugin integration (syntax highlighting, autosuggestions)
#     - Optional Powerline prompt support
#
#   Features are designed to be:
#     - Interactive-focused (optimized for daily CLI usage)
#     - Persistent (shared history across sessions)
#     - Modular (plugins loaded conditionally)
#     - Portable (graceful fallback if plugins are missing)
#
# Usage:
#   Source this file from your ~/.zshrc:
#
#       [ -n "$ZSH_VERSION" ] && source ~/.config/shell/zsh_only.zsh
#
# Dependencies (optional):
#     - zsh-syntax-highlighting
#     - zsh-autosuggestions
#     - powerline (zsh bindings)
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   (add if known)
#   Updated:   (update as needed)
#   Version:   2.0
#
# ================================================================================
# ================================================================================ 

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=20000

setopt autocd
setopt extendedglob
setopt notify
setopt appendhistory
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
setopt sharehistory
setopt incappendhistory

bindkey -v

autoload -Uz compinit
compinit

if [[ -r "$HOME/.config/shell/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.config/shell/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [[ -r "$HOME/.config/shell/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.config/shell/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Powerline prompt
if [[ -r /usr/share/powerline/bindings/zsh/powerline.zsh ]]; then
    POWERLINE_ZSH_CONTINUATION=1
    POWERLINE_ZSH_SELECT=1
    source /usr/share/powerline/bindings/zsh/powerline.zsh
fi

PROMPT_EOL_MARK=''

# ================================================================================ 
# ================================================================================ 
# eof
