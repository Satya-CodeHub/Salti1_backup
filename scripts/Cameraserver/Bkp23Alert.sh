#!/bin/bash

NEW_DIR=$(mkdir -p /tmp/csalert)

#Creating Temporary Directory
$NEW_DIR
echo "##########Starting##########"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"

TEMPORARY_DIR="/tmp/csalert"
echo $TEMPORARY_DIR
DB_USER="dashboard_user"
PASSWORD="s1u9p0e3r1s9t7a7r"
HOSTNAME="mysql.staging.aws.bigbasketinstant.com"
DATABASE="dashboard"
Cron_File_Permission_Check="select count(Alert_Name) as Cron_Permission from csalerts where Alert_Name='Cron_Permission' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Cronjob_Not_Enabled="select count(Alert_Name) as Cronjob_Not_Enabled from csalerts where Alert_Name='Cronjob_Enable' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Cronjob="select count(Alert_Name) as Cronjob from csalerts where Alert_Name='Cronjob' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Disk_Alert="select count(Alert_Name) as Disk_Alert from csalerts where Alert_Name='Disk' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Latest_Script="select count(Alert_Name) as Latest_Script from csalerts where Alert_Name='Latest_Script' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Mac_Binding="select count(Alert_Name) as Mac_Binding from csalerts where Alert_Name='Mac_Binding' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Pendrive="select count(Alert_Name) as Pendrive from csalerts where Alert_Name='Pendrive' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Video_Directory="select count(Alert_Name) as Video_Directory from csalerts where Alert_Name='Video_Directory' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Software_Watchdog="select count(Alert_Name) as Software_Watchdog from csalerts  where Alert_Name='Software_Watchdog' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Camera_Detection="select count(Alert_Name) as Camera_Detection from csalerts where Alert_Name='Camera_Detection' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Motion_Device="select count(Alert_Name) as Motion_Device from csalerts where Alert_Name='Motion_Device' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"

Latest_Video="select count(Alert_Name) as Latest_Video from csalerts where Alert_Name='Latest_Video' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
LCD_LatestScripts="select count(Alert_Name) as LCD_LatestScripts from csalerts where Alert_Name='LCD_LatestScripts' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
Motion_package="select count(Alert_Name) as Motion_package from csalerts where Alert_Name='Motion_package' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"
False_VideoFormat="select count(Alert_Name) as False_VideoFormat from csalerts where Alert_Name='False_VideoFormat' and Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute);"

mysql -u $DB_USER -p$PASSWORD -h$HOSTNAME << EOF >> $TEMPORARY_DIR/tmp.txt 2>&1
use $DATABASE;
$Cron_File_Permission_Check;
$Cronjob_Not_Enabled;
$Cronjob;
$Disk_Alert;
$Latest_Script;
$Mac_Binding;
$Pendrive;
$Video_Directory;
$Software_Watchdog;
$Camera_Detection;
$Motion_Device;
$Latest_Video;
$LCD_LatestScripts;
$Motion_package;
$False_VideoFormat;

EOF

cat $TEMPORARY_DIR/tmp.txt

Attachment="select a.Machine_ID as Machine_ID,m.friendly_name as Location_Name,a.Alert_Name as Alert_Name,l.state as State,a.Status as Status,a.Date_Created as Date_Created from csalerts a, machine m, location l where a.Machine_ID=m.name and m.location_id=l.id and a.Date_Created >= DATE_SUB(NOW(),INTERVAL 50 minute) and m.state='Active' order by a.Alert_Name;"

cat $TEMPORARY_DIR/tmp.txt | tail -n+2 | tr '\t' ',' > $TEMPORARY_DIR/CS_Status.csv

mysql -u $DB_USER -p$PASSWORD -h$HOSTNAME << EOF >> $TEMPORARY_DIR/tmp1.txt 2>&1
use $DATABASE;
$Attachment
EOF

cat $TEMPORARY_DIR/tmp1.txt

cat $TEMPORARY_DIR/tmp1.txt | tail -n+2 | tr '\t' ',' > $TEMPORARY_DIR/CS_attachment.csv

Cron_Permission=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Cron_Permission" -A1 | tail -n1)
Cronjob_Not_Enabled=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Cronjob_Not_Enabled" -A1 | tail -n1)
Cronjob=$(cat $TEMPORARY_DIR/CS_Status.csv | grep "Cronjob" -A1 | grep -v "Cronjob_Not_Enabled" | grep -i "Cronjob" -A1 | tail -n1)
Disk_Alert=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Disk_Alert" -A1 | tail -n1)
Latest_Script=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Latest_Script" -A1 | tail -n1)
Mac_Binding=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Mac_Binding" -A1 | tail -n1)
Pendrive=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Pendrive" -A1 | tail -n1)
Video_Directory=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Video_Directory" -A1 | tail -n1)
Software_Watchdog=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Software_Watchdog" -A1 | tail -n1)
Camera_Detction=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Camera_Detection" -A1 | tail -n1)
Motion_Device=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Motion_Device" -A1 | tail -n1)
Latest_Video=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Latest_Video" -A1 | tail -n1)
LCD_LatestScripts=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "LCD_LatestScripts" -A1 | tail -n1)
Motion_package=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "Motion_package" -A1 | tail -n1)
False_VideoFormat=$(cat $TEMPORARY_DIR/CS_Status.csv | grep -i "False_VideoFormat" -A1 | tail -n1)



echo '<html><body></br></br><p><FONT COLOR=black FACE="Merriweather"SIZE=2><strong>Team Please Find The Summary Of Cameraserver Alert, Detailed Report Has Been Attached Please Have a Check.<strong></p></br></br></br>' >> $TEMPORARY_DIR/csalert.html
echo '<table border=4>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><th colspan="2" width="50%;" align="center" valign="center"&nbsp; bgcolor=#39ac73><FONT COLOR=white FACE="Merriweather"SIZE=2><b>SUMMARY OF CAMERASERVER</b></th></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><th bgcolor=#39ac73><FONT COLOR=white FACE="Merriweather"SIZE=2>Alert_Name</th><th bgcolor=#39ac73><FONT COLOR=white FACE="Merriweather"SIZE=2>Machine_Count</th></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Cron_Permission</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Cron_Permission'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Cronjob_Not_Enabled</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Cronjob_Not_Enabled'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Cronjob</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Cronjob'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Disk_Alert</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Disk_Alert'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Latest_Script</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Latest_Script'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Mac_Binding</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Mac_Binding'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Pendrive</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Pendrive'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Video_Directory</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Video_Directory'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Software_Watchdog</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Software_Watchdog'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Camera_Detction</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Camera_Detction'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Motion_Device</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Motion_Device'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Latest_Video</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Latest_Video'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>LCD_LatestScripts</b></td><td align="center" valign="center" bgcolor=#ffffff>'$LCD_LatestScripts'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>Motion_package</b></td><td align="center" valign="center" bgcolor=#ffffff>'$Motion_package'</td></tr>' >> $TEMPORARY_DIR/csalert.html
echo '<tr><td bgcolor=#ffffff><FONT COLOR=black FACE="Merriweather"><b>False_VideoFormat</b></td><td align="center" valign="center" bgcolor=#ffffff>'$False_VideoFormat'</td></tr>' >> $TEMPORARY_DIR/csalert.html

echo '</table>' >> $TEMPORARY_DIR/csalert.html
echo '<p><br><FONT COLOR=black FACE="Merriweather"SIZE=2><b>Thanks & Regards,</b></br><br><FONT COLOR=black FACE="Merriweather"SIZE=2><b>BBInstant-Techops.</b></br></p>' >> $TEMPORARY_DIR/csalert.html
echo '</body></html>' >> $TEMPORARY_DIR/csalert.html

mutt -e "set content_type=text/html" -s "Cameraserver Alert" bbinstant.techops@bigbasket.com -c surendran.a@bigbasket.com,sunil.kumarb@bigbasket.com -a /tmp/csalert/CS_attachment.csv < /tmp/csalert/csalert.html

rm -rf /tmp/csalert
echo "##########Ending##########"
