#!/usr/bin/bash 
# ================================================================================
# Shell Aliases and Utility Functions
# ================================================================================
#
# Description:
#   This file defines a collection of shell aliases, helper functions, and
#   development utilities intended to enhance command-line productivity and
#   streamline common workflows.
#
#   The configuration includes:
#     - Core command overrides and enhancements (e.g., ls, grep, vim → nvim)
#     - Cross-platform handling for Linux and macOS environments
#     - Directory navigation and file management helpers
#     - Search and filtering utilities
#     - Development workflow helpers for C, C++, and Python projects
#     - Integration with external tools (tmux, fzf, bat, xdg-open, etc.)
#
#   Functions are designed to be:
#     - Safe (basic argument validation included)
#     - Portable (OS-aware behavior where applicable)
#     - Extensible (modular structure for adding new tooling)
#
# Usage:
#   This file should be sourced by your shell configuration (e.g., ~/.bashrc
#   or ~/.zshrc) to make all aliases and functions available in interactive
#   sessions.
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   February 22, 2022
#   Updated:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================

# ------------------------------------------------------------------------------
# OS detection
# ------------------------------------------------------------------------------
case "$(uname -s)" in
    Linux*)  OS_FAMILY="linux" ;;
    Darwin*) OS_FAMILY="macos" ;;
    *)       OS_FAMILY="other" ;;
esac

# ------------------------------------------------------------------------------
# Core aliases
# ------------------------------------------------------------------------------
alias vim='nvim'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

# ls variants differ between GNU/Linux and BSD/macOS
if [ "$OS_FAMILY" = "linux" ]; then
    alias ls='ls --color=auto'
    alias ll='ls -FGlAhp --color=auto'
else
    alias ls='ls -G'
    alias ll='ls -FGlAhp'
fi

alias mkdir='mkdir -pv'
alias cpv='rsync -ah --info=progress2'
alias less='less -FSRXc'

# ------------------------------------------------------------------------------
# Directory navigation
# ------------------------------------------------------------------------------
alias cd2='cd ../..'
alias cd3='cd ../../..'
alias cd4='cd ../../../..'

mkcdir() {
    [ -n "$1" ] || { printf 'Usage: mkcdir <directory>\n' >&2; return 1; }
    mkdir -p -- "$1" && cd -P -- "$1"
}

alias cdnvim='cd ~/.config/nvim'

# ------------------------------------------------------------------------------
# File and path helpers
# ------------------------------------------------------------------------------
mnt() {
    if [ "$OS_FAMILY" = "linux" ] && command -v mount >/dev/null 2>&1; then
        mount | awk '{printf "%s\t%s\n",$1,$3}' | column -t | grep '^/dev/' | sort
    elif [ "$OS_FAMILY" = "macos" ] && command -v mount >/dev/null 2>&1; then
        mount | awk '{printf "%s\t%s\n",$1,$3}' | column -t | sort
    else
        printf 'mnt: unsupported platform or missing mount command.\n' >&2
        return 1
    fi
}

# Removes Finder metadata files when present.
cleanupDS() {
    find . -type f -name '.DS_Store' -print -delete 2>/dev/null
}

alias count='find . -type f | wc -l'

paths() {
    printf '%s\n' "${PATH//:/$'\n'}"
}

alias execs='type -a'

show_options() {
    if [ -n "${BASH_VERSION:-}" ]; then
        shopt
    elif [ -n "${ZSH_VERSION:-}" ]; then
        setopt
    else
        printf 'show_options: unsupported shell.\n' >&2
        return 1
    fi
}

alias qfind='find . -name'

ff() {
    [ $# -gt 0 ] || { printf 'Usage: ff <pattern>\n' >&2; return 1; }
    find . -name "$1"
}

ffs() {
    [ $# -gt 0 ] || { printf 'Usage: ffs <prefix>\n' >&2; return 1; }
    find . -name "$1*"
}

ffe() {
    [ $# -gt 0 ] || { printf 'Usage: ffe <suffix>\n' >&2; return 1; }
    find . -name "*$1"
}

fzfvim() {
    command -v fzf >/dev/null 2>&1 || { printf 'fzfvim: fzf is not installed.\n' >&2; return 1; }
    command -v bat >/dev/null 2>&1 || { printf 'fzfvim: bat is not installed.\n' >&2; return 1; }
    command -v nvim >/dev/null 2>&1 || { printf 'fzfvim: nvim is not installed.\n' >&2; return 1; }

    local selection
    selection="$(fzf -m --preview='bat --color=always --style=numbers --line-range=:500 {}')" || return 1
    [ -n "$selection" ] || return 0
    nvim $selection
}

# ------------------------------------------------------------------------------
# Open URL / file helpers
# ------------------------------------------------------------------------------
if [ "$OS_FAMILY" = "linux" ] && command -v xdg-open >/dev/null 2>&1; then
    alias open='xdg-open'
elif [ "$OS_FAMILY" = "macos" ] && command -v open >/dev/null 2>&1; then
    alias open='open'
fi

# Internet shortcuts only if "open" is available
if command -v xdg-open >/dev/null 2>&1 || [ "$OS_FAMILY" = "macos" ]; then
    alias duckduckgo='open https://duckduckgo.com'
    alias pandora='open https://www.pandora.com/station/play/4603528905632915968'
    alias github='open https://github.com'
    alias weather='open https://www.weather.gov'
    alias stack_overflow='open https://stackoverflow.com'
    alias photo_site='open https://www.appletonwebbphotography.com'
    alias tmux_cheat='open http://tmuxcheatsheet.com'
    alias vim_cheat='open https://vim.rtorr.com'
    alias latex_cheat='open https://wch.github.io/latexsheet/latexsheet.pdf'
    alias bash_cheat='open https://oit.ua.edu/wp-content/uploads/2016/10/Linux_bash_cheat_sheet.pdf'
    alias bash_scripting_cheat='open https://devhints.io/bash'
fi

# ------------------------------------------------------------------------------
# Networking helpers
# ------------------------------------------------------------------------------
alias myip='curl -fsSL ip.appspot.com'
alias netCons='lsof -i'
alias lsock='sudo lsof -i -P'

ii() {
    printf '\nYou are logged on %s\n' "${HOSTNAME:-$(hostname 2>/dev/null)}"
    printf '\nAdditional information:\n'; uname -a
    printf '\nUsers logged on:\n'; w -h
    printf '\nCurrent date:\n'; date
    printf '\nMachine stats:\n'; uptime

    if [ "$OS_FAMILY" = "macos" ] && command -v scselect >/dev/null 2>&1; then
        printf '\nCurrent network location:\n'
        scselect
    elif [ "$OS_FAMILY" = "linux" ] && command -v hostnamectl >/dev/null 2>&1; then
        printf '\nHost information:\n'
        hostnamectl
    fi

    printf '\nPublic facing IP Address:\n'
    myip || true
    printf '\n'
}

# ------------------------------------------------------------------------------
# Development helpers
# ------------------------------------------------------------------------------
alias cd-python='cd ~/Code_Dev/Python'
#alias create_py_dir='bash ~/.config/shell/create_dir.sh Python'
alias create_py_file='bash ~/.config/shell/create_file.sh Python'
alias create_py_test='bash ~/.config/shell/create_file.sh Python_Test'
#alias open_py_ide='bash ~/.config/shell/create_project_tmux.sh Python'
alias sphinx_doc='sphinx-build -b html source build'

create_py_dir() {
    if [[ $# -gt 0 ]]; then
        bash "$HOME/.config/shell/create_dir.sh" Python "$1"
    else
        bash "$HOME/.config/shell/create_dir.sh" Python
    fi
}

open_py_ide() {
    local input path

    if [[ $# -eq 0 ]]; then
        path="$PWD"
    else
        input="$1"

        if [[ -d "$input" ]]; then
            path="$(cd "$input" && pwd -P)"
        elif [[ -d "$HOME/Code_Dev/Python/$input" ]]; then
            path="$HOME/Code_Dev/Python/$input"
        else
            printf 'open_py_ide: invalid project path: %s\n' "$input" >&2
            return 1
        fi
    fi

    "$HOME/.config/shell/create_project_tmux.sh" Python "$path"
}

alias ve='python3 -m venv .venv'
alias va='source .venv/bin/activate'

alias cd-c='cd ~/Code_Dev/C'
#alias create_c_dir='bash ~/.config/shell/create_dir.sh C'
alias create_c_file='bash ~/.config/shell/create_file.sh C'
alias create_c_test='bash ~/.config/shell/create_file.sh C_Test'
alias create_c_lib='bash ~/.config/shell/create_file.sh C_Lib'
#alias open_c_ide='bash ~/.config/shell/create_project_tmux.sh C'

create_c_dir() {
    if [[ $# -gt 0 ]]; then
        bash "$HOME/.config/shell/create_dir.sh" C "$1"
    else
        bash "$HOME/.config/shell/create_dir.sh" C
    fi
}

open_c_ide() {
    local input path

    if [[ $# -eq 0 ]]; then
        path="$PWD"
    else
        input="$1"

        # If the provided path exists as typed (relative or absolute), use it.
        if [[ -d "$input" ]]; then
            path="$(cd "$input" && pwd -P)"
        # Otherwise, try the default C projects directory.
        elif [[ -d "$HOME/Code_Dev/C/$input" ]]; then
            path="$HOME/Code_Dev/C/$input"
        else
            printf 'open_c_ide: invalid project path: %s\n' "$input" >&2
            return 1
        fi
    fi

    "$HOME/.config/shell/create_project_tmux.sh" C "$path"
}

alias cd-cpp='cd ~/Code_Dev/C++'
#alias create_cpp_dir='bash ~/.config/shell/create_dir.sh C++'
alias create_cpp_file='bash ~/.config/shell/create_file.sh C++'
alias create_cpp_test='bash ~/.config/shell/create_file.sh C++_Test'
alias create_cpp_lib='bash ~/.config/shell/create_file.sh C++_Lib'
alias create_cpp_main='bash ~/.config/shell/create_file.sh C++_Main'
#alias open_cpp_ide='bash ~/.config/shell/create_project_tmux.sh C++'

create_cpp_dir() {
    if [[ $# -gt 0 ]]; then
        bash "$HOME/.config/shell/create_dir.sh" C++ "$1"
    else
        bash "$HOME/.config/shell/create_dir.sh" C++
    fi
}

open_cpp_ide() {
    local input path

    if [[ $# -eq 0 ]]; then
        path="$PWD"
    else
        input="$1"

        if [[ -d "$input" ]]; then
            path="$(cd "$input" && pwd -P)"
        elif [[ -d "$HOME/Code_Dev/C++/$input" ]]; then
            path="$HOME/Code_Dev/C++/$input"
        else
            printf 'open_cpp_ide: invalid project path: %s\n' "$input" >&2
            return 1
        fi
    fi

    "$HOME/.config/shell/create_project_tmux.sh" C++ "$path"
}
# ------------------------------------------------------------------------------
# Video project structure
# ------------------------------------------------------------------------------
create_vid_dir() {
    local day month year project_name project_dir
    day="$(date +%d)"
    month="$(date +%m)"
    year="$(date +%Y)"

    printf 'Enter the project name: '
    IFS= read -r project_name
    [ -n "$project_name" ] || { printf 'No project name entered.\n' >&2; return 1; }

    project_dir="${year}-${month}-${day}-${project_name}"
    mkdir -p -- "$project_dir" || return 1

    mkdir -p -- \
        "$project_dir/01-Footage" \
        "$project_dir/02-Audio" \
        "$project_dir/03-Graphics" \
        "$project_dir/04-Music" \
        "$project_dir/05-Photos" \
        "$project_dir/06-Documents" \
        "$project_dir/07-Editor" \
        "$project_dir/08-AE" \
        "$project_dir/09-Exports"

    printf 'Created: %s\n' "$project_dir"
}

# ================================================================================
# ================================================================================
# eof

