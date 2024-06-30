#!/bin/bash

file_path="/home/satyanarayanbiswal/ActiveVSbkp"
api_base_url="https://instant-websocket.bigbasket.com/kwiksocket/v2/analytics/machine"
output_file="/home/satyanarayanbiswal/jkl"

while IFS= read -r line; do
    machine_id=$(awk '{print $1}' <<< "$line")
    api_url="${api_base_url}/${machine_id}/availability"

    # Run the curl command in the background
    (curl -s "${api_url}" | jq -r '.status') &

done < "$file_path" | paste -d' ' - "$file_path" > /home/satyanarayanbiswal/test
#Ofile_path="/home/satyanarayanbiswal/test"
#while IFS= read -r read result line; do
result=`cat /home/satyanarayanbiswal/test | grep -w '503'`

echo "$result"  >> "$output_file"
#    echo "$line : $result `TZ='Asia/Kolkata' date '+%d-%b-%Y at %R %p'`"

    # Check if the HTTP status code is not "200"
#    if [[ $result != "200" ]]; then
#        echo "$line $result"  >> "$output_file"
#    fi
#done

# Wait for all background processes to finish
wait
