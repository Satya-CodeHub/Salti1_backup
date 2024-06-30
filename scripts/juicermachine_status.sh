#!/bin/bash

URL="https://instant-websocket.bigbasket.com/kwiksocket/v2/analytics/machine/viGGmaR58t9hsGMLu7o7oW/availability"

#EMAIL="vineetha.rayalacheruvu@bigbasket.com"
EMAILS="bbinstant.techops@bigbasket.com, abhishek.dhakare@bigbasket.com, rajesh.p1@bigbasket.com, vinoth.m1@bigbasket.com, anthony@bigbasket.com"

LOG_FILE="/root/scripts/juicermachine_status.log"

RESPONSE=$(curl -s "$URL")

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Log the timestamp and response to the log file
echo "$TIMESTAMP - Response: $RESPONSE" >> "$LOG_FILE"

# Extract the status code from response
STATUS=$(echo "$RESPONSE" | grep -o '"status":[0-9]*' | awk -F: '{print $2}')

STATUS=$(echo "$STATUS" | tr -d ' ')

# Check if the status is not 200, then send an email
if [ "$STATUS" != "200" ]; then
    SUBJECT="BB Juicer Machine BBJ10001 availability status on $(date +'%Y-%m-%d')"
    BODY="Hi Team,

The BB Juicer Machine BBJ10001 availability status is $RESPONSE
Please check asap.

Regards,
Vineetha R"
    #Send email using mutt
    echo -e "$BODY" | mutt -s "$SUBJECT" -- $EMAILS
else
  echo "No issue found.so, No email will be sent."
fi

