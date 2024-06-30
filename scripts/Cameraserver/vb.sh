#!/bin/bash

Master_Path="/root/scripts/Cameraserver"
Machine_List="/root/scripts/Cameraserver/Machine_Details"
Failed_Details="/root/scripts/Cameraserver/Failed_Details"

#mkdir -p $Failed_Details



echo "##########Starting##########"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"

###Validating Machines Having Latest Scripts

if grep -q "Latest Video" /root/scripts/Cameraserver/Machine_Details/BB_KW21687H_CS; then
    Alert=$(grep -i "Latest Video" /root/scripts/Cameraserver/Machine_Details/BB_KW21687H_CS | cut -d"-" -f2 | tr -d ' ')
    echo "$Alert"
    if [ "$Alert" == "Success" ]; then
        echo "$Machine_Name - Latest Video found"
    else
        echo "$Machine_Name - Latest Video not found"
    fi
else
    echo "$Machine_Name - Latest Video line not found in the file"
fi



