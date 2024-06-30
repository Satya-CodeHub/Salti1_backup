#!/bin/bash
Master_Path="/root/scripts/mbcheck_test"
Machine_List="/root/scripts/mbcheck_test/Machine_Name"

output=$(cat "${Machine_List}"/* | grep "^KW" | uniq)

# Formatting the output as a table
table=$(echo "$output" | awk 'BEGIN {FS=" - "} {printf("%-10s %-10s %-10s\n", $1, $2, $3)}')

# Save the table to a file
echo "$table" > "${Master_Path}/mb_temp_table.csv"

# Send email using mutt
#email_subject="BBI | Motherboard Check Report"
#recipient="vineetha.rayalacheruvu@bigbasket.com"
#email_body="Please find the MB Check report below:\n\n$table"

#echo -e "$email_body" | mutt -s "$email_subject" -- "$recipient"
