#!/usr/bin/env bash

set -euo pipefail

# ==============================================================================
# OSConfig configuration setup script
#
# This script installs user configuration files from the OSConfig repository.
# Existing files may be overwritten, so backups are created before replacement.
# ==============================================================================

REPO_DIR="${HOME}/Code_Dev/OS/OSConfig"
CONFIG_DIR="${REPO_DIR}/config"
BACKUP_DIR="${HOME}/.config_backup/osconfig_$(date +%Y%m%d_%H%M%S)"

# ------------------------------------------------------------------------------
print_header() {
    echo "============================================================"
    echo "OSConfig Configuration Setup"
    echo "============================================================"
    echo
}

# ------------------------------------------------------------------------------
print_warning() {
    cat <<EOF
WARNING:
This script installs configuration files from:

  ${REPO_DIR}

Proceeding may overwrite existing files in your home directory, including:
  - ~/.zshrc
  - ~/.zsh_profile
  - ~/.bashrc
  - ~/.bash_profile
  - ~/.tmux.conf
  - ~/.config/nvim
  - ~/.config/ghostty
  - ~/.config/templates
  - ~/.config/shell
  - ~/scripts/cleanCache.sh
  - ~/scripts/mngDownloads.sh

Optional system-level files may also be installed:
  - /usr/share/powerline
  - /usr/local/bin/core_backup

Backups of user files will be stored in:

  ${BACKUP_DIR}

EOF
}

# ------------------------------------------------------------------------------
confirm_continue() {
    read -r -p "Do you want to continue? [y/N]: " response
    case "${response}" in
        [yY]|[yY][eE][sS]) ;;
        *)
            echo "Aborted."
            exit 0
            ;;
    esac
}

# ------------------------------------------------------------------------------
check_repo() {
    if [[ ! -d "${REPO_DIR}" ]]; then
        echo "ERROR: OSConfig repository not found at:"
        echo "  ${REPO_DIR}"
        echo
        echo "Clone it first with:"
        echo "  mkdir -p ~/Code_Dev/OS"
        echo "  cd ~/Code_Dev/OS"
        echo "  git clone https://github.com/Jon-Webb-79/OSConfig.git"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
make_backup_dir() {
    mkdir -p "${BACKUP_DIR}"
}

# ------------------------------------------------------------------------------
backup_if_exists() {
    local target="$1"

    if [[ -e "${target}" || -L "${target}" ]]; then
        mkdir -p "${BACKUP_DIR}"
        echo "Backing up ${target}"
        cp -a "${target}" "${BACKUP_DIR}/"
    fi
}

# ------------------------------------------------------------------------------
copy_dir() {
    local src="$1"
    local dst="$2"

    if [[ ! -d "${src}" ]]; then
        echo "WARNING: Source directory not found: ${src}"
        return
    fi

    backup_if_exists "${dst}"
    rm -rf "${dst}"
    mkdir -p "$(dirname "${dst}")"
    cp -a "${src}" "${dst}"
    echo "Installed directory: ${dst}"
}

# ------------------------------------------------------------------------------
copy_file() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "${src}" ]]; then
        echo "WARNING: Source file not found: ${src}"
        return
    fi

    backup_if_exists "${dst}"
    mkdir -p "$(dirname "${dst}")"
    cp -a "${src}" "${dst}"
    echo "Installed file: ${dst}"
}

# ------------------------------------------------------------------------------
install_powerline_if_needed() {
    if [[ -d "/usr/share/powerline" ]]; then
        echo "Powerline already present at /usr/share/powerline"
        return
    fi

    local src="${CONFIG_DIR}/shell/powerline"
    if [[ ! -d "${src}" ]]; then
        echo "WARNING: Powerline source directory not found: ${src}"
        return
    fi

    echo
    echo "Powerline was not found at /usr/share/powerline."
    read -r -p "Install bundled powerline files to /usr/share? [y/N]: " response
    case "${response}" in
        [yY]|[yY][eE][sS])
            sudo cp -a "${src}" /usr/share/
            echo "Installed powerline to /usr/share/"
            ;;
        *)
            echo "Skipping powerline installation."
            ;;
    esac
}

# ------------------------------------------------------------------------------
install_user_scripts() {
    local scripts_dir="${HOME}/scripts"

    echo
    echo "Installing user utility scripts..."

    mkdir -p "${scripts_dir}"

    copy_file "${CONFIG_DIR}/cleanCache.sh" "${scripts_dir}/cleanCache.sh"
    copy_file "${CONFIG_DIR}/mngDownloads.sh" "${scripts_dir}/mngDownloads.sh"

    chmod +x "${scripts_dir}/cleanCache.sh" "${scripts_dir}/mngDownloads.sh" 2>/dev/null || true

    echo "User scripts installed in ${scripts_dir}"
}

# ------------------------------------------------------------------------------
install_backup_script() {
    local src="${CONFIG_DIR}/core_backup"
    local dst="/usr/local/bin/core_backup"

    if [[ ! -f "${src}" ]]; then
        echo "WARNING: core_backup script not found at ${src}"
        return
    fi

    echo
    read -r -p "Install system backup script to /usr/local/bin? [y/N]: " response
    case "${response}" in
        [yY]|[yY][eE][sS])
            if [[ -f "${dst}" ]]; then
                echo "Backing up existing ${dst}"
                sudo cp "${dst}" "${dst}.bak"
            fi

            sudo cp "${src}" "${dst}"
            sudo chmod +x "${dst}"

            echo "Installed core_backup to ${dst}"
            echo "You can run it with: sudo core_backup"
            ;;
        *)
            echo "Skipping backup script installation."
            ;;
    esac
}

# ------------------------------------------------------------------------------
set_default_shell() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "WARNING: zsh is not installed. Skipping default shell change."
        return
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"

    echo
    read -r -p "Set ${zsh_path} as your default shell? [y/N]: " response
    case "${response}" in
        [yY]|[yY][eE][sS])
            chsh -s "${zsh_path}"
            echo "Default shell updated to ${zsh_path}"
            echo "Log out and back in for the change to take effect."
            ;;
        *)
            echo "Skipping shell change."
            ;;
    esac
}

# ------------------------------------------------------------------------------
main() {
    print_header
    check_repo
    print_warning
    confirm_continue
    make_backup_dir

    mkdir -p "${HOME}/.config"

    echo
    echo "Checking powerline installation..."
    install_powerline_if_needed

    echo
    echo "Installing Neovim configuration..."
    copy_dir "${CONFIG_DIR}/nvim" "${HOME}/.config/nvim"

    echo
    echo "Installing shell configuration..."
    copy_dir "${CONFIG_DIR}/shell" "${HOME}/.config/shell"
    copy_file "${REPO_DIR}/.zshrc" "${HOME}/.zshrc"
    copy_file "${CONFIG_DIR}/.zsh_profile" "${HOME}/.zsh_profile"
    copy_file "${CONFIG_DIR}/.bashrc" "${HOME}/.bashrc"
    copy_file "${CONFIG_DIR}/.bash_profile" "${HOME}/.bash_profile"

    echo
    echo "Installing tmux configuration..."
    copy_file "${CONFIG_DIR}/.tmux.conf" "${HOME}/.tmux.conf"

    echo
    echo "Installing Ghostty configuration..."
    copy_dir "${CONFIG_DIR}/ghostty" "${HOME}/.config/ghostty"

    echo
    echo "Installing code templates..."
    copy_dir "${CONFIG_DIR}/templates" "${HOME}/.config/templates"

    echo
    echo "Installing utility scripts..."
    install_user_scripts

    echo
    echo "Installing backup script..."
    install_backup_script

    echo
    echo "Configuration installation complete."
    echo "Backups were saved to:"
    echo "  ${BACKUP_DIR}"

    set_default_shell

    echo
    echo "Next steps:"
    echo "  1. Restart your shell or run: source ~/.bashrc"
    echo "  2. Start Neovim to allow lazy.nvim to install plugins"
    echo "  3. Start tmux and Ghostty to verify configuration"
    echo "  4. Log out and back in if you changed your default shell"
}

main "$@"
