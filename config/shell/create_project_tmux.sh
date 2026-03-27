#!/usr/bin/bash
# ==============================================================================
# File: create_project_tmux.sh
# Purpose: Open a tmux session tailored to a project language.
#
# Usage:
#   create_project_tmux.sh <Python|C|C++|Arduino> <project_root>
# ==============================================================================

set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
TMUX_BIN="/usr/bin/tmux"

usage() {
    cat <<'EOF'
Usage: create_project_tmux.sh <Python|C|C++|Arduino> <project_root>
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

build_three_pane_window() {
    local target_window="$1"
    local dir="$2"

    "$TMUX_BIN" select-pane -t "${target_window}.1"
    "$TMUX_BIN" split-window -t "${target_window}.1" -h -c "$dir"
    "$TMUX_BIN" split-window -t "${target_window}.1" -v -c "$dir"
    "$TMUX_BIN" select-layout -t "$target_window" tiled >/dev/null 2>&1 || true
}

main() {
    [[ $# -eq 2 ]] || { usage; exit 1; }

    local language="$1"
    local project_root="$2"

    case "$language" in
        Python|C|C++|Arduino) ;;
        *) usage; exit 1 ;;
    esac

    [[ -x "$TMUX_BIN" ]] || die "tmux is not installed at $TMUX_BIN"
    [[ -d "$project_root" ]] || die "Project root does not exist: $project_root"

    local session
    session="$(basename "$project_root")"

    local code_dir="$project_root"
    local test_dir="$project_root"
    local readme_file="${project_root}/README.rst"

    case "$language" in
        Python)
            code_dir="${project_root}/${session}"
            test_dir="${project_root}/tests"
            ;;
        C|C++)
            code_dir="${project_root}/${session}"
            test_dir="${project_root}/${session}/test"
            ;;
    esac

    [[ -d "$code_dir" ]] || die "Code directory does not exist: $code_dir"

    if "$TMUX_BIN" has-session -t "$session" 2>/dev/null; then
        printf 'tmux session "%s" already exists.\n' "$session"
        exec "$TMUX_BIN" attach-session -t "$session"
    fi

    "$TMUX_BIN" new-session -d -s "$session" -n 'Main' -c "$code_dir"
    build_three_pane_window "${session}:Main" "$code_dir"

    if [[ -d "$test_dir" ]]; then
        "$TMUX_BIN" new-window -t "${session}:2" -n 'Test' -c "$test_dir"
        build_three_pane_window "${session}:Test" "$test_dir"
    fi

    "$TMUX_BIN" new-window -t "${session}:3" -n 'README' -c "$project_root"
    if [[ -f "$readme_file" ]]; then
        "$TMUX_BIN" send-keys -t "${session}:README.1" "nvim \"$readme_file\"" C-m
    fi

    if [[ "$language" == "Python" ]]; then
        "$TMUX_BIN" new-window -t "${session}:4" -n 'Python3' -c "$project_root"
        "$TMUX_BIN" send-keys -t "${session}:Python3.1" 'python3' C-m
        "$TMUX_BIN" new-window -t "${session}:5" -n 'Shell' -c "$project_root"
    else
        "$TMUX_BIN" new-window -t "${session}:4" -n 'Shell' -c "$project_root"
    fi

    "$TMUX_BIN" select-window -t "${session}:Main"
    "$TMUX_BIN" select-pane -t "${session}:Main.1"

    exec "$TMUX_BIN" attach-session -t "$session"
}

main "$@"
