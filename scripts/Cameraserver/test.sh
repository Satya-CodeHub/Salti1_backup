#!/bin/bash

Master_Path="/root/scripts/Cameraserver"
Machine_List="/root/scripts/Cameraserver/Machine_Details"
Failed_Details="/root/scripts/Cameraserver/Failed_Details"

mkdir -p $Failed_Details


find ${Machine_List} -type f -mmin -60 > ${Master_Path}/rouh_extracted.txt
cat ${Master_Path}/rouh_extracted.txt |  grep -Eo '.{14}$' > ${Master_Path}/extra.txt

echo "##########Starting##########"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"

###Validating Machines Having Latest Scripts

while IFS= read -r Machine_Name
do

Alert=$(cat $Machine_List/$Machine_Name | grep -i "Latest Video" | cut -d"-" -f2 | tr -d ' ')

if [ "$Alert" == "Success" ];then

echo "$Machine_Name - Latest Video found"

else

echo "$Machine_Name - Latest Video not found"

Machine_ID=$(ls $Machine_List/$Machine_Name | cut -d"_" -f3)

echo "$Machine_ID,Latest_Video,Failed" >> /root/scripts/Cameraserver/Latest_Vid.csv

fi

done < ${Master_Path}/extra.txt
