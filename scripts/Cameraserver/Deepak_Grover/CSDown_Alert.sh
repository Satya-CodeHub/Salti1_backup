#!/bin/bash

echo "############################"
echo "##########STARTING##########"
echo "############################"

dt=$(date '+%d/%m/%Y');
echo "$dt"

NEW_DIR=$(mkdir -p /tmp/csalert)

TEMPORARY_DIR="/tmp/csalert"

Attachment="select a.Machine_ID as Machine_ID,m.friendly_name as Location_Name,l.state as State,a.Status as Status,a.Date_Created as Date_Created from csdown a, machine m, location l where a.Machine_ID=m.name and m.location_id=l.id and a.Date_Created >= DATE_SUB(NOW(),INTERVAL 35 minute)order by l.state;"

DB_USER="dashboard_user"
PASSWORD="s1u9p0e3r1s9t7a7r"
HOSTNAME="mysql.staging.aws.bigbasketinstant.com"
DATABASE="dashboard"

mysql -u $DB_USER -p$PASSWORD -h$HOSTNAME << EOF >> $TEMPORARY_DIR/alert.txt 2>&1
use $DATABASE;
$Attachment
EOF

cat $TEMPORARY_DIR/alert.txt|wc -l

cat $TEMPORARY_DIR/alert.txt | tail -n+2 | tr '\t' ',' > $TEMPORARY_DIR/LIST.csv

printf "Team, attached is the list of Camera Servers (PAN India) which are currently down.\n"| mutt -e "set content_type=text/html" -s "Alert Notification: List of Down Camera Servers $dt" bbinstant.techops@bigbasket.com, amit.sarswat@bigbasket.com, prajwal.4@bigbasket.com, mayur.kamble@bigbasket.com, chandrakant.r@bigbasket.com, santosh.dhanve@bigbasket.com -c deepak.grover@bigbasket.com,surendran.a@bigbasket.com,sunil.kumarb@bigbasket.com -a /tmp/csalert/LIST.csv

rm -rf /tmp/csalert

echo "############################"
echo "###########ENDING###########"
echo "############################"
