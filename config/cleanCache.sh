#!/bin/bash

set -euo pipefail

# Configuration
CACHE_DIR="$HOME/.cache"
LOGDIR="$HOME/logfiles"
LOGFILE="$LOGDIR/cache_cleanup.log"
MIN_SIZE_MB=100         # Only delete entries larger than this (in MB)
OLDER_THAN_DAYS=30      # Only delete entries older than this (in days)
DRY_RUN=true            # Set to false to actually delete

# Function to get timestamp
get_now() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to write log entries
log() {
    echo "[$(get_now)] $1" | tee -a "$LOGFILE"
}

# Initialize log directory and file
initialize_logging() {
    if [ ! -d "$LOGDIR" ]; then
        mkdir -p "$LOGDIR"
    fi

    if [ ! -f "$LOGFILE" ]; then
        echo "[$(get_now)] Created cache cleanup log file" > "$LOGFILE"
    fi
}

# Main script logic
main() {
    initialize_logging

    log "Started selective cache cleanup (dry-run: $DRY_RUN)"
    log "Criteria: size >= ${MIN_SIZE_MB}MB, age >= ${OLDER_THAN_DAYS} days"

    mapfile -t TARGETS < <(find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d \
        -size +"${MIN_SIZE_MB}"M -mtime +"$OLDER_THAN_DAYS" 2>/dev/null)

    if [[ "${#TARGETS[@]}" -eq 0 ]]; then
        log "No cache directories matched the cleanup criteria."
    else
        for target in "${TARGETS[@]}"; do
            if [[ "$DRY_RUN" == true ]]; then
                log "Would delete: $target"
            else
                if rm -rf "$target"; then
                    log "Deleted: $target"
                else
                    log "Failed to delete: $target"
                fi
            fi
        done
    fi

    log "Finished selective cache cleanup"
}

# Run the main function
main

