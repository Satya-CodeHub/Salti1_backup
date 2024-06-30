#!/bin/bash
Master_Path="/root/scripts/mbcheck_test"
Machine_List="/root/scripts/mbcheck_test/Machine_Name"

grep -lE '^[0-9]+|^[0-9]+.*KW' ${Machine_List}/* | grep -v "KW30" | grep -v "KW40" | awk -F/ '{ print $NF }' | cut -d"_" -f2 > ${Master_Path}/extracted.txt

DB_USER="dashboard"
PASSWORD="s1u9p0e3r1s9t7a7r"
HOSTNAME="mysql.staging.aws.bigbasketinstant.com"
DATABASE="dashboard"

if [ -z "$(ls -A /root/scripts/mbcheck_test/Machine_Name)" ]; then

   echo "Not Issue Found,Hence Sending No Issue Mail"
   echo "Team All Looks Good! No Issue Found In Temprature Check." | mutt -s "Chiller Alert V2-Machines" vineetha.rayalacheruvu@bigbasket.com
   exit 0

else

while IFS= read -r Machine_Name
do
COMMAND="select m.name as Machine_ID,m.friendly_name as Machine_Name,l.state as State from dashboard.machine m, dashboard.location l where m.location_id=l.id and m.name='$Machine_Name'"
mysql -u $DB_USER -h $HOSTNAME -p$PASSWORD -se "$COMMAND" >> $Master_Path/output.txt

cat $Machine_List/BB_${Machine_Name}_VS | grep -v "KW" >> $Master_Path/temp.txt

#rm -rf $Machine_List/BB_${Machine_Name}_VS

done < ${Master_Path}/extracted.txt

paste $Master_Path/output.txt $Master_Path/temp.txt >> $Master_Path/full_append.txt

cat $Master_Path/full_append.txt | tr '\t' ',' > $Master_Path/Chiller_Status.csv

sort -t, -k3,3 -k2,2 $Master_Path/Chiller_Status.csv > $Master_Path/Orginal.csv

sed -i '1s/^/Machine_ID,Machine_Name,State,Temprature\n/' $Master_Path/Orginal.csv

rm -rf $Master_Path/Chiller_Status.csv

/root/scripts/Chiller_Alert/csv_to_html.sh $Master_Path/Orginal.csv > /root/scripts/Chiller_Alert/chiller.html

echo "Issue Found Sending Full Details"

#mutt -e "set content_type=text/html" -s "Chiller Alert V2-Machines" vineetha.rayalacheruvu@bigbasket.com -c vineetha.rayalacheruvu@bigbasket.com </root/scripts/mbcheck_test/chiller.html

#rm -rf $Master_Path/output.txt
#rm -rf $Master_Path/extracted.txt
#rm -rf $Master_Path/*.csv
#rm -rf $Master_Path/chiller.html
#rm -rf $Master_Path/temp.txt
#rm -rf $Master_Path/full_append.txt
#rm -rf $Machine_List/*

fi
