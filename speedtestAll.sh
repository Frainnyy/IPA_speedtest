#!/usr/bin/bash

# สร้างไฟล์ CSV และเพิ่ม header
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
echo "Speedtest results collected on $timestamp" >speedtest_1.csv
speedtest-cli --csv-header >>speedtest_1.csv

# Get the list of all speedtest servers
server_list=$(speedtest-cli --list | grep -E '^[ ]*[0-9]+\)' | awk '{print $1}' | tr -d ')')

# Function to perform speedtest on a server
perform_speedtest() {
    server=$1
    echo "Testing server ID: $server"
    speedtest-cli --server $server --csv >>speedtest_1.csv
}

# Log the start time at cli
start_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Speedtest started at: $start_time"

for server in $server_list; do
    perform_speedtest $server &
    if (($(jobs | wc -l) >= 5)); then
        wait -n
    fi
done

wait

# Log the end time at cli
end_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Speedtest completed at: $end_time"

#for server in $servers; do
#   perform_speedtest $server &
# Optional: limit the number of parallel jobs (e.g., max 5 jobs at once)
#  if (( $(jobs | wc -l) >= 5 )); then
#    wait -n
# fi
#done
#wait

echo "Testing completed. Results saved in speedtest_1.csv"
