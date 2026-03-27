# ================================================================================
# PATH Environment Configuration
# ================================================================================
#
# Description:
#   This file manages additions to the system PATH environment variable in a
#   safe, idempotent, and portable manner. It ensures that commonly used binary
#   directories are included in PATH without introducing duplicate entries.
#
#   The configuration:
#     - Prepends user-level and system-level binary directories
#     - Avoids duplicate PATH entries using guarded checks
#     - Maintains predictable command resolution order
#
#   Directories included:
#     - $HOME/.local/bin   (user-installed executables)
#     - /usr/local/bin     (locally compiled/system-wide tools)
#
#   Design goals:
#     - Idempotent (safe to source multiple times)
#     - Portable (works across Bash, Zsh, and POSIX-like shells)
#     - Minimal (focused solely on PATH management)
#
# Usage:
#   Source this file in your shell configuration:
#
#       source ~/.config/shell/path.sh
#
#   This should typically be loaded early in your shell initialization so that
#   subsequent configurations and scripts can rely on the updated PATH.
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================ 

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":$PATH:" in
    *":/usr/local/bin:"*) ;;
    *) PATH="/usr/local/bin:$PATH" ;;
esac

export PATH

# ================================================================================ 
# ================================================================================ 
# eof
