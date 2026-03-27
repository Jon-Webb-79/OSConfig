#!/usr/bin/bash
# ================================================================================
# Web Search and URL Utility Functions
# ================================================================================
#
# Description:
#   This file provides lightweight helper functions for encoding search queries
#   and launching web-based searches directly from the command line using the
#   system's default browser.
#
#   It includes:
#     - URL-safe query encoding for simple search strings
#     - Cross-platform browser invocation (xdg-open / macOS open)
#     - Convenience functions for common web searches:
#         * Google
#         * DuckDuckGo
#         * GitHub
#         * Weather (NOAA)
#
#   The design emphasizes:
#     - Simplicity (minimal dependencies and fast execution)
#     - Portability (Linux and macOS support)
#     - Usability (natural command-line search workflows)
#
# Usage:
#   Source this file in your shell configuration:
#
#       source ~/.config/shell/web.sh
#
#   Example usage:
#       google "c++ allocator design"
#       duckduck "bash string replace"
#       github_search "simd string library"
#       weather_search "Salt Lake City"
#
# Dependencies:
#     - xdg-open (Linux) OR open (macOS)
#
# Notes:
#   The encoding function performs basic space-to-plus substitution and is
#   suitable for simple queries. It is not a full URL encoder.
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   March 26, 2026
#   Version:   1.0
#
# ================================================================================
# ================================================================================ 

web_encode() {
    local q="$*"
    q="${q// /+}"
    printf '%s\n' "$q"
}

open_command() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$@" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
        command open "$@" >/dev/null 2>&1 &
    else
        printf 'open_command: no supported opener found\n' >&2
        return 1
    fi
}

google() {
    open_command "https://www.google.com/search?q=$(web_encode "$*")"
}

duckduck() {
    open_command "https://duckduckgo.com/?q=$(web_encode "$*")"
}

github_search() {
    open_command "https://github.com/search?q=$(web_encode "$*")"
}

weather_search() {
    open_command "https://www.weather.gov/search?query=$(web_encode "$*")"
}
