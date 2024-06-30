#!/bin/bash

Path1="/root/scripts/Cameraserver/Deepak_Grover"
Path2="/root/scripts/Cameraserver/Machine_Details"

echo "############################"
echo "##########STARTING##########"
echo "############################"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"

find $Path2 -type f -mmin -30 -printf '%f\n' > $Path1/Active_CS.txt

comm -23 <(sort $Path1/Latest_CS.txt) <(sort $Path1/Active_CS.txt) > $Path1/NotPinging.txt

while IFS= read -r Machine_Name Alert
do

Machine_ID=$(echo $Machine_Name |cut -d"_" -f2)
Alert=$(echo 'Down')

echo "$Machine_ID,$Alert" >> $Path1/Down_Alert.csv

done < $Path1/NotPinging.txt


###
#DataBase Details
###

DB_USERNAME="dashboard_user"
DB_PASSWORD="s1u9p0e3r1s9t7a7r"
DB_HOSTNAME="mysql.staging.aws.bigbasketinstant.com"
DB_NAME="dashboard"

##Inserting down-time list to the database

if [ -e $Path1/Down_Alert.csv ]
then

while IFS=, read -r Machine Status
do

mysql -u$DB_USERNAME -h$DB_HOSTNAME -p$DB_PASSWORD $DB_NAME -e "insert into csdown (Machine_ID,Status) values ('$Machine','Down');"

done < $Path1/Down_Alert.csv

rm -rf $Path1/Down_Alert.csv

else

exit 0

fi

echo "############################"
echo "###########ENDING###########"
echo "############################"
