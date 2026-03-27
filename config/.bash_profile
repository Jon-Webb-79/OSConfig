#!/usr/bin/bash
# ================================================================================
# Bash Login Initialization File (.bash_profile)
# ================================================================================
#
# Description:
#   This file is executed for login shells in Bash. Its primary responsibility
#   is to initialize the user environment and delegate configuration to
#   `.bashrc`, which handles interactive shell setup.
#
#   This design ensures:
#     - A single source of truth for interactive configuration
#     - Consistent behavior between login and non-login shells
#     - Minimal duplication of configuration logic
#
#   Typical responsibilities of `.bash_profile` include:
#     - Setting environment variables (if not handled elsewhere)
#     - Initializing login-specific behavior
#     - Sourcing `.bashrc` for interactive configuration
#
#   In this setup, `.bash_profile` is intentionally minimal and acts as a
#   bootstrapper for `.bashrc`.
#
# Usage:
#   This file is automatically sourced by Bash during login sessions
#   (e.g., console login, SSH sessions, display managers depending on setup).
#
# Notes:
#   - `.bashrc` is sourced to ensure all modular shell configurations
#     (located in ~/.config/shell/) are applied consistently
#   - This file should remain lightweight and avoid duplicating logic
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   December 24, 2020
#   Updated:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
# ================================================================================
# ================================================================================
# eof
