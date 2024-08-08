#!/usr/bin/bash

# Function to log messages
log_message() {
    echo "$1"
    echo "$1" >> speedtest_1.csv
}

# สร้างไฟล์ CSV และเพิ่ม header
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_message "Speedtest results collected on $timestamp"
speedtest-cli --csv-header >>speedtest_1.csv

# Log the start time at the top of the file
start_time=$(date +"%Y-%m-%d %H:%M:%S")
log_message "Speedtest started at: $start_time"

# Get the list of all speedtest servers with retry mechanism
get_server_list() {
    local retries=3
    while [ $retries -gt 0 ]; do
        server_list=$(speedtest-cli --list | grep -E '^[ ]*[0-9]+\)' | awk '{print $1}' | tr -d ')')
        if [[ -n "$server_list" ]]; then
            break
        fi
        log_message "Failed to retrieve server list, retrying..."
        retries=$((retries-1))
        sleep 2
    done

    if [[ -z "$server_list" ]]; then
        log_message "ERROR: Could not retrieve server list. Exiting."
        exit 1
    fi
}

get_server_list

# Function to perform speedtest on a server
perform_speedtest() {
    server=$1
    log_message "Testing server ID: $server"
    speedtest-cli --server $server --csv >>speedtest_1.csv
}

for server in $server_list; do
    perform_speedtest $server &
    if (($(jobs | wc -l) >= 5)); then
        wait -n
    fi
done

wait

# Log the end time at the bottom of the file
end_time=$(date +"%Y-%m-%d %H:%M:%S")
log_message "Speedtest completed at: $end_time"

# Print completion message to CLI
log_message "Testing completed. Results saved in speedtest_1.csv"

# Feature: Periodically run the script every k minutes
k=5  # Set k to your desired interval in minutes

while true; do
    ./speedtestAll.sh  # Replace with the actual script name
    sleep $(($k * 60))
done

