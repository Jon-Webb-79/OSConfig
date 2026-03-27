#!/usr/bin/bash 
# ================================================================================
# Arch Linux Package Management Aliases and Utilities
# ================================================================================
#
# Description:
#   This file provides a comprehensive set of aliases and helper functions
#   tailored for managing an Arch Linux system. It standardizes and simplifies
#   common package management workflows across multiple tools, including:
#
#     - pacman  (official package manager)
#     - aura    (AUR helper)
#     - yay     (AUR helper)
#
#   The configuration includes:
#     - Short, consistent aliases for installation, removal, upgrades, and queries
#     - Cache management and orphan cleanup utilities
#     - File/package ownership and lookup helpers
#     - Key management and trust automation for pacman
#     - Convenience functions for inspecting system state (e.g., disowned files)
#     - Integration with web resources (e.g., opening package pages)
#
#   Functions are designed to be:
#     - Safe (input validation and error handling where applicable)
#     - Informative (clear usage messages and structured output)
#     - Efficient (leveraging native Arch tools like expac, pacman, and find)
#
# Usage:
#   This file should be sourced in your shell configuration (e.g., ~/.bashrc
#   or ~/.zshrc). It is intended for use on Arch Linux or Arch-based systems.
#
#   Some functions require optional dependencies:
#     - expac (for paclist)
#     - xdg-open (for pacweb)
#     - aura or yay (for AUR-related aliases)
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
# Pacman aliases
# ------------------------------------------------------------------------------

alias pacupg='sudo pacman -Syu'          # Full system upgrade
alias pacupd='sudo pacman -Sy'           # Refresh sync databases
alias pacmir='sudo pacman -Syy'          # Force refresh all package databases

alias pacin='sudo pacman -S'             # Install package from repos
alias pacins='sudo pacman -U'            # Install local package file
alias pacinsd='sudo pacman -S --asdeps'  # Install as dependency

alias pacre='sudo pacman -R'             # Remove package
alias pacrem='sudo pacman -Rns'          # Remove package with unused deps

alias pacrep='pacman -Si'                # Show remote package info
alias pacreps='pacman -Ss'               # Search remote packages
alias pacloc='pacman -Qi'                # Show locally installed package info
alias paclocs='pacman -Qs'               # Search installed packages

alias paclean='sudo pacman -Sc'          # Remove uninstalled package cache
alias paclr='sudo pacman -Scc'           # Remove all cached packages

alias paclsorphans='pacman -Qdt'         # List orphaned packages
alias pacrmorphans='sudo pacman -Rs $(pacman -Qtdq)'  # Remove orphaned packages

alias pacfileupg='sudo pacman -Fy'       # Refresh file database
alias pacfiles='pacman -F'               # Search file database
alias pacls='pacman -Ql'                 # List files owned by a package
alias pacown='pacman -Qo'                # Identify package owning a file/path

alias pacmanallkeys='sudo pacman-key --refresh-keys'  # Refresh pacman keys

# ------------------------------------------------------------------------------
# paclist
# ------------------------------------------------------------------------------
# Print explicitly installed packages in a compact list.
#
# Requirements:
# - pacman
# - expac
#
# Example:
#   paclist
# ------------------------------------------------------------------------------
paclist() {
    if ! command -v expac >/dev/null 2>&1; then
        printf 'paclist: expac is required but not installed.\n' >&2
        return 1
    fi

    pacman -Qqe | xargs -r -I '{}' expac '%-20n %d' '{}'
}

# ------------------------------------------------------------------------------
# pacdisowned
# ------------------------------------------------------------------------------
# List files under common system paths that are not owned by any installed
# package. This can help identify manually installed files or stale artifacts.
#
# Example:
#   pacdisowned
# ------------------------------------------------------------------------------
pacdisowned() {
    local tmp db fs
    tmp="${TMPDIR:-/tmp}/pacman-disowned-${UID}-$$"
    db="$tmp/db"
    fs="$tmp/fs"

    mkdir -p "$tmp" || return 1
    trap 'rm -rf "$tmp"' EXIT

    pacman -Qlq | sort -u > "$db"

    find /bin /etc /lib /sbin /usr ! -name lost+found \
        \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

    comm -23 "$fs" "$db"
}

# ------------------------------------------------------------------------------
# pacmansignkeys
# ------------------------------------------------------------------------------
# Receive, locally sign, and set trust on one or more pacman keys.
#
# Usage:
#   pacmansignkeys <keyid> [keyid...]
#
# Example:
#   pacmansignkeys 0123456789ABCDEF
# ------------------------------------------------------------------------------
pacmansignkeys() {
    local key

    if [[ $# -eq 0 ]]; then
        printf 'Usage: pacmansignkeys <keyid> [keyid...]\n' >&2
        return 1
    fi

    for key in "$@"; do
        sudo pacman-key --recv-keys "$key" || return 1
        sudo pacman-key --lsign-key "$key" || return 1
        printf 'trust\n3\n' | sudo gpg --homedir /etc/pacman.d/gnupg \
            --no-permission-warning \
            --command-fd 0 \
            --edit-key "$key"
    done
}

# ------------------------------------------------------------------------------
# pacweb
# ------------------------------------------------------------------------------
# Open the Arch Linux package page for a repository package in the default
# browser.
#
# Usage:
#   pacweb <package>
#
# Example:
#   pacweb bash
# ------------------------------------------------------------------------------
pacweb() {
    local pkg infos repo arch

    if [[ $# -ne 1 ]]; then
        printf 'Usage: pacweb <package>\n' >&2
        return 1
    fi

    if ! command -v xdg-open >/dev/null 2>&1; then
        printf 'pacweb: xdg-open is required but not installed.\n' >&2
        return 1
    fi

    pkg="$1"
    infos="$(LANG=C pacman -Si "$pkg" 2>/dev/null)" || return 1
    [[ -z "$infos" ]] && return 1

    repo="$(grep -m 1 '^Repository' <<< "$infos" | awk '{print $3}')"
    arch="$(grep -m 1 '^Architecture' <<< "$infos" | awk '{print $3}')"

    [[ -z "$repo" || -z "$arch" ]] && return 1

    xdg-open "https://archlinux.org/packages/${repo}/${arch}/${pkg}/" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Aura aliases
# ------------------------------------------------------------------------------
# These aliases assume aura is installed.
# ------------------------------------------------------------------------------
alias auupg='sudo sh -c "aura -Syu && aura -Au"'                  # Upgrade repos + AUR
alias ausu='sudo sh -c "aura -Syu --no-confirm && aura -Au --no-confirm"'

alias auupd='sudo aura -Sy'               # Refresh sync databases
alias aumir='sudo aura -Syy'              # Force refresh all package databases

alias auin='sudo aura -S'                 # Install repo package
alias aurin='sudo aura -A'                # Install AUR package
alias auins='sudo aura -U'                # Install local package file
alias auinsd='sudo aura -S --asdeps'      # Install repo package as dependency
alias aurinsd='sudo aura -A --asdeps'     # Install AUR package as dependency

alias aure='sudo aura -R'                 # Remove package
alias aurem='sudo aura -Rns'              # Remove package with unused deps

alias aurep='aura -Si'                    # Show repo package info
alias aurrep='aura -Ai'                   # Show AUR package info
alias aureps='aura -As --both'            # Search repo and AUR
alias auras='aura -As --both'             # Search repo and AUR

alias auloc='aura -Qi'                    # Show local package info
alias aulocs='aura -Qs'                   # Search installed packages
alias aulst='aura -Qe'                    # List explicitly installed packages

alias auclean='sudo aura -Sc'             # Remove uninstalled package cache
alias auclr='sudo aura -Scc'              # Remove all cached packages

alias aurph='sudo aura -Oj'               # View AUR package snapshots / info
alias auown='aura -Qqo'                   # Find package owning a file
alias auls='aura -Qql'                    # List files owned by package

# ------------------------------------------------------------------------------
# auownloc
# ------------------------------------------------------------------------------
# Show local package info for the package that owns a given file.
#
# Usage:
#   auownloc <path>
# ------------------------------------------------------------------------------
auownloc() {
    aura -Qi "$(aura -Qqo "$1")"
}

# ------------------------------------------------------------------------------
# auownls
# ------------------------------------------------------------------------------
# List files for the package that owns a given file.
#
# Usage:
#   auownls <path>
# ------------------------------------------------------------------------------
auownls() {
    aura -Qql "$(aura -Qqo "$1")"
}

# ------------------------------------------------------------------------------
# yay aliases
# ------------------------------------------------------------------------------
# These aliases assume yay is installed.
# ------------------------------------------------------------------------------
alias yaupg='yay -Syu'                    # Upgrade repos + AUR
alias yasu='yay -Syu --noconfirm'         # Upgrade repos + AUR without prompts

alias yaupd='yay -Sy'                     # Refresh sync databases
alias yamir='yay -Syy'                    # Force refresh all package databases

alias yain='yay -S'                       # Install package
alias yains='yay -U'                      # Install local package file
alias yainsd='yay -S --asdeps'            # Install as dependency

alias yare='yay -R'                       # Remove package
alias yarem='yay -Rns'                    # Remove package with unused deps

alias yarep='yay -Si'                     # Show remote package info
alias yareps='yay -Ss'                    # Search remote packages
alias yaloc='yay -Qi'                     # Show local package info
alias yalocs='yay -Qs'                    # Search installed packages
alias yalst='yay -Qe'                     # List explicitly installed packages
alias yaorph='yay -Qtd'                   # List orphaned packages

alias yaclean='yay -Sc'                   # Remove uninstalled package cache
alias yaclr='yay -Scc'                    # Remove all cached packages
alias yaconf='yay -Pg'                    # Print yay config
# ================================================================================
# ================================================================================
# eof

