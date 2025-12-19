#!/bin/bash
# Run WDQS updater in a controlled loop with logging and signal handling.
# WF 2025-06-04
# see https://github.com/scatter-llc/private-wikidata-query
# and https://wiki.bitplan.com/index.php/Wikidata_Import_2025-05-02
# and https://github.com/WolfgangFahl/get-your-own-wdqs

set -euo pipefail

# Default values
LOGFILE="/var/log/wdqs/update-loop.log"
INTERVAL=10

# Function to show usage
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -d, --daemon    Detach and run in background via nohup"
    echo "  -l, --loop      Run update loop in foreground"
    echo "  -h, --help      Show this help message"
    exit 0
}

# Function to handle daemon mode detachment
run_daemon_mode() {
    if [[ "${DETACHED:-}" != "true" ]]; then
        echo "Detaching process via nohup..."
        export DETACHED=true
        nohup "$0" --loop > "$LOGFILE" 2>&1 &
        echo "Process detached. PID: $!"
        exit 0
    fi
    run_main_loop
}

# Function to run the main update loop
run_main_loop() {
    trap 'echo "[$(date -Iseconds)] Caught termination signal. Exiting." >> "$LOGFILE"; exit 0' SIGINT SIGTERM
    echo "[$(date -Iseconds)] Starting WDQS update loop..." >> "$LOGFILE"
    
    while true; do
        echo "[$(date -Iseconds)] Running /wdqs/runUpdate.sh ..." >> "$LOGFILE"
        /wdqs/runUpdate.sh -n wdq >> "$LOGFILE" 2>&1
        echo "[$(date -Iseconds)] Sleeping $INTERVAL seconds..." >> "$LOGFILE"
        sleep $INTERVAL
    done
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--daemon)
            run_daemon_mode
            exit 0
            ;;
        -l|--loop)
            run_main_loop
            exit 0
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            ;;
    esac
done

# No options provided
show_help
