#!/bin/bash

Master_Path="/root/scripts/Cameraserver"
Machine_List="/root/scripts/Cameraserver/Machine_Details"
Failed_Details="/root/scripts/Cameraserver/Failed_Details"

mkdir -p $Failed_Details

#ls ${Machine_List} > ${Master_Path}/extracted.txt

find ${Machine_List} -type f -mmin -60 > ${Master_Path}/tryrough_extracted.txt
cat ${Master_Path}/tryrough_extracted.txt |  grep -Eo '.{14}$' > ${Master_Path}/tryextracted.txt

echo "##########Starting##########"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"

###Validating Machines Having Latest Scripts

while IFS= read -r Machine_Name
do

Alert=$(cat $Machine_List/$Machine_Name | grep -i "MAC-Binding" | cut -d"-" -f3 | tr -d ' ')

if [ "$Alert" == "Success" ];then

echo "$Machine_Name - Mac-Binding is Proper"

else

echo "$Machine_Name - Mac-Binding Not Done"

Machine_ID=$(ls $Machine_List/$Machine_Name | cut -d"_" -f3)

echo "$Machine_ID,Mac_Binding,Failed" >> /root/scripts/Cameraserver/Failed_Details/tMac_Binding.csv

fi

done < ${Master_Path}/tryextracted.txt


echo "##########Ending##########"
