#!/bin/bash
Master_Path="/root/scripts/MBcheck_Alert"
Machine_List="/root/scripts/Chiller_Alert/Machine_Name"
Output_File="${Master_Path}/MBcheck_output.csv"

# Remove existing output file if it exists
if [ -f "$Output_File" ]; then
  rm "$Output_File"
fi

# Iterate over each file in the directory
for file in "${Machine_List}"/*; do
  output=$(cat "$file" | grep "^KW" | uniq)

  # Check if output is not empty
  if [ -n "$output" ]; then
    # Formatting the output as a table
    table=$(echo "$output" | awk 'BEGIN {FS=" - "} {printf("%-10s %-10s %-10s\n", $1, $2, $3)}')

    # Save the table to the output file
    echo "$table" >> "$Output_File"
  fi
done
