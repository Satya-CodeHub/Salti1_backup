#!/bin/bash

Master_Path="/root/scripts/Cameraserver"
Machine_List="/root/scripts/Cameraserver/Machine_Details"
Failed_Details="/root/scripts/Cameraserver/Failed_Details"

mkdir -p $Failed_Details

#ls ${Machine_List} > ${Master_Path}/extracted.txt

find ${Machine_List} -type f -mmin -60 > ${Master_Path}/rough_extracted.txt
cat ${Master_Path}/rough_extracted.txt |  grep -Eo '.{14}$' > ${Master_Path}/extracted.txt

echo "##########Starting##########"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"

###Validating Machines Having Latest Scripts

while IFS= read -r Machine_Name
do

Alert=$(cat $Machine_List/$Machine_Name | grep -i "LCD LatestScripts" | cut -d"-" -f2 | tr -d ' ')

if [ "$Alert" == "Success" ];then

echo "$Machine_Name - LCD LatestScripts found"

else

echo "$Machine_Name - LCD LatestScripts not found"

Machine_ID=$(ls $Machine_List/$Machine_Name | cut -d"_" -f3)

echo "$Machine_ID,LCD_LatestScripts,Failed" >> /root/scripts/Cameraserver/Failed_Details/LCD_LatestScripts.csv

fi

done < ${Master_Path}/extracted.txt

###
#DataBase Details
###

DB_USERNAME="dashboard_user"
DB_PASSWORD="s1u9p0e3r1s9t7a7r"
DB_HOSTNAME="mysql.staging.aws.bigbasketinstant.com"
DB_NAME="dashboard"

##Inserting The Failed Machine Details
if [ -e /root/scripts/Cameraserver/Failed_Details/LCD_LatestScripts.csv ]
then

while IFS=, read -r Machine Alert Status
do

mysql -u$DB_USERNAME -h$DB_HOSTNAME -p$DB_PASSWORD $DB_NAME -e "insert into csalerts (Machine_ID,Alert_Name,Status) values ('$Machine','$Alert','Failed');"

done < /root/scripts/Cameraserver/Failed_Details/LCD_LatestScripts.csv

rm -rf /root/scripts/Cameraserver/Failed_Details/LCD_LatestScripts.csv

else

exit 0

fi

echo "##########Ending##########"
