#!/bin/bash

set -euo pipefail

LOGDIR="$HOME/logfiles"
LOGFILE="$LOGDIR/downloads.log"
DOWNLOADS="$HOME/Downloads"

# Set the check period manually (options: 1H, 1D, 1WK, 2WK, 1MO)
period="1WK"

# Function to get current timestamp in ISO-like format
get_now() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Convert named period to number of seconds
parse_period_to_seconds() {
    case "$1" in
        1H)  echo $((60 * 60)) ;;
        1D)  echo $((60 * 60 * 24)) ;;
        1WK) echo $((60 * 60 * 24 * 7)) ;;
        2WK) echo $((60 * 60 * 24 * 14)) ;;
        1MO) echo $((60 * 60 * 24 * 30)) ;;  # Approximate month
        *)   echo "Error: Invalid period format '$1'" >&2; exit 1 ;;
    esac
}

# Ensure log directory and file exist
initialize_log() {
    if [ ! -d "$LOGDIR" ]; then
        mkdir -p "$LOGDIR"
        echo "$(get_now) Created initial log" > "$LOGFILE"
    elif [ ! -f "$LOGFILE" ]; then
        echo "$(get_now) Created initial log" > "$LOGFILE"
    fi
}

# Get the timestamp of the most recent non-error log entry
get_last_valid_timestamp() {
    grep -v "Error" "$LOGFILE" | tail -n 1 | cut -d' ' -f1,2
}

# Main logic block
main() {
    initialize_log

    last_entry="$(get_last_valid_timestamp)"
    if [ -z "$last_entry" ]; then
        echo "Error: No valid previous log entry found" >&2
        exit 1
    fi

    # Convert timestamps to epoch seconds
    last_epoch=$(date -d "$last_entry" +%s)
    now_epoch=$(date +%s)

    elapsed_seconds=$((now_epoch - last_epoch))
    threshold_seconds=$(parse_period_to_seconds "$period")

    if [ "$elapsed_seconds" -gt "$threshold_seconds" ]; then
        if rm -rf "$DOWNLOADS"/*; then
            echo "$(get_now) Deleted Downloads directory" >> "$LOGFILE"
        else
            echo "$(get_now) Error: Failed to delete Downloads directory" >> "$LOGFILE"
        fi
    fi
}

# Run the main function and catch unexpected failures
{
    main
} || {
    echo "$(get_now) Error: Script failed with exit code $?" >> "$LOGFILE"
    exit 1
}

