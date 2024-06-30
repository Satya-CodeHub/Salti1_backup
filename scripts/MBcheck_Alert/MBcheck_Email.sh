#!/bin/bash
Master_Path="/root/scripts/MBcheck_Alert"
Machine_List="/root/scripts/Chiller_Alert/Machine_Name"
Output_File="${Master_Path}/MBcheck_output.csv"
#Recipient_Email="vineetha.rayalacheruvu@bigbasket.com"
#Cc_Emails="vineetha.rayalacheruvu@bigbasket.com"
Recipient_Email="bbinstant.techops@bigbasket.com"
Cc_Emails="vineetha.rayalacheruvu@bigbasket.com,sunil.kumarb@bigbasket.com"
Subject="BBI - VS Firmware error - $(date +'%Y-%m-%d')"
Body="Hi Team,\n\nPlease find below the vendingservers which have Motherboard issues. Please take the necessary action asap.\n"

# Remove existing output file if it exists
if [ -f "$Output_File" ]; then
   rm -rf "$Output_File"
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

# Check if output file is empty
if [ -s "$Output_File" ]; then
  # Prepare the email content
  Content="$Body\n$(cat "$Output_File")"

  # Send email using mutt
  echo -e "$Content" | mutt -s "$Subject" -c "$Cc_Emails" -- "$Recipient_Email"
else
  echo "No issue found.so, No email will be sent."
fi
