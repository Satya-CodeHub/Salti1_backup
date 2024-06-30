#!/bin/bash

Master_Path="/root/scripts/CS_DOWNTIME"
Latest_CSList="/root/scripts/Cameraserver/Machine_Details"
sudo rm /root/scripts/CS_DOWNTIME/final_CSdown
#ReadOnly DB Credentials
RDB_HOSTNAME="bbinstant-readonly-mysql.cyu5asiuwdao.ap-south-1.rds.amazonaws.com"
RDB_USERNAME="mysql_readonly"
RDB_PASSWORD="R2e5a1d1o2n0l0y6"
RDB_NAME="kwik24"

#Dashboard DB Credentials
DB_HOSTNAME="mysql.staging.aws.bigbasketinstant.com"
DB_USERNAME="dashboard_user"
DB_PASSWORD="s1u9p0e3r1s9t7a7r"
DB_NAME="dashboard"


#mysql -u mysql_readonly -pR2e5a1d1o2n0l0y6 -h bbinstant-readonly-mysql.cyu5asiuwdao.ap-south-1.rds.amazonaws.com kwik24 -se "select distinct m.name from kwik24.location l, kwik24.machine m, kwik24.refill_order ro where ro.location_id=l.id and m.location_id=l.id and l.v3_api=1 and ro.status='complete' and m.state='Active' group by  l.id, m.name,l.city,l.segment having date(max(ro.complete_time)) > subdate(curdate(),21);"  2> /dev/null > /root/scripts/CS_DOWNTIME/Active_CS
#mysql -u mysql_readonly -pR2e5a1d1o2n0l0y6 -h bbinstant-readonly-mysql.cyu5asiuwdao.ap-south-1.rds.amazonaws.com kwik24 -se "select name , friendly_name from machine order by name ASC ;"  2> /dev/null | awk '{print $1}' | egrep -v "_" | grep "KW" | sed -e "s/KW/BB_KW/g;s/H/H_CS/g;s/WR/WR_VS/g;s/C/C_VS/g" > machines_all
sudo sed -e "s/KW/BB_KW/g;s/H/H_CS/g;" ${Master_Path}/Active_CS1 > ${Master_Path}/Active_CS

#To get the list of CS  where the data  got updated in last 15  hours
sudo find /root/scripts/Cameraserver/Machine_Details -type f -mmin -1200 | awk -F/ '{print $NF}' > ${Master_Path}/Latest_CS

#Compare & filter out CS present in Active_CS but not in Latest_CS
sudo grep -Fxvf ${Master_Path}/Latest_CS ${Master_Path}/Active_CS > ${Master_Path}/Missing_CS

#Get the last modified time  of Missing_CS
sudo xargs -a ${Master_Path}/Missing_CS -I {} stat -c "%Y %n" /root/scripts/Cameraserver/Machine_Details/{} | awk '{print $2, strftime("%d-%b-%Y", $1)}' | awk -F/ '{print $NF}' > ${Master_Path}/Last_modified

sudo cat ${Master_Path}/Last_modified | sed -e "s/BB_KW/KW/g;s/H_CS/H/g" > ${Master_Path}/Formatted_Last_modified


#Fetch the Machine and location details of the down CS

input_file="/root/scripts/CS_DOWNTIME/Formatted_Last_modified"

query_prefix="select l.city as CITY,m.friendly_name as LOCATION from machine m, location l where  m.location_id=l.id and m.name IN ("
query_suffix=")"

while read line; do

  value=$(echo "$line" | awk '{print $1}')

  query="${query_prefix}'${value}'${query_suffix}"

  output=$(mysql -h "$DB_HOSTNAME" -u "$DB_USERNAME" -p"$DB_PASSWORD" -D "$DB_NAME" -se "$query")
  echo "${line} ${output}" >> "/root/scripts/CS_DOWNTIME/final_CSdown"
  done < "$input_file"

sudo awk '{sub(/ /,"\t");sub(/ /,"\t");print}' /root/scripts/CS_DOWNTIME/final_CSdown > /root/scripts/CS_DOWNTIME/formatted_final_CSdown

sudo sort -t$'\t' -k2.9,2.12n -k2.4,2.6M -k2.1,2.2n  -k1,1n /root/scripts/CS_DOWNTIME/formatted_final_CSdown > /root/scripts/CS_DOWNTIME/final_CSdown



final_cs="$Master_Path/final_CSdownbkp"

cp "$Master_Path/final_CSdown" "$Master_Path/final_CSdownbkp"

# Process each line of the file and format it as an HTML table
while IFS= read -r line; do
    printf '%s\n' "$line" | sed -e 's/^/<td bgcolor=#E0FFFF><font FACE="Merriweather">/' | sed -e 's/\t/<\/td><td bgcolor=#FFFFEA><font FACE="Merriweather">/g' |  sed -e 's/\t/<\/td><td bgcolor=#FFFFEA><font FACE="Merriweather">/g' | sed -e 's/$/<\/td><\/tr><tr>/'
done < "$final_cs" > "$Master_Path/final_CSdown"

# Create an HTML file
cp "$Master_Path/final_CSdown" "$Master_Path/final_CSdown.html"
sed -i '1i <html><body><table border=5>' "$Master_Path/final_CSdown.html"
sed -n -i 'p;1a <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Machine <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Last_Accessed <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>City <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Location </td></tr><tr>' "$Master_Path/final_CSdown.html"
sed -i '$a </table></body></html>' "$Master_Path/final_CSdown.html"

#city_summary=$(awk '{ count[$3]++; } END { total=0; for (city in count) { print "<tr><td bgcolor=#E0FFFF style=\"text-align:center;\"><font FACE=\"Merriweather\">" city "</td><td bgcolor=#C7FFFF style=\"text-align:center;\"><font FACE=\"Merriweather\">" count[city] "</td></tr>"; total+=count[city]; } print "<tr><td bgcolor=#E0FFFF style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>Total</b></td><td bgcolor=#FFFFEA style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>" total "</b></td></tr>"; }' "$final_cs")
city_summary=$(awk '{ count[$3]++; } END { total=0; for (city in count) { print "<tr><td bgcolor=#FFFFEA style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>" city "</b></td><td bgcolor=#FFFFEA style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>" count[city] "</b></td></tr>"; total+=count[city]; } print "<tr><td bgcolor=#a5d732 style=\"text-align:center;\"><font FACE=\"Merriweather\"><strong>Total</b></td><td bgcolor=#a5d732 style=\"text-align:center;\"><font FACE=\"Merriweather\"><strong>" total "</b></td></tr>"; }' "$final_cs")

# Email Notification
(
echo "To:satyanarayan.biswal@bigbasket.com"

echo "Subject: CameraServer Down Alert on `TZ='Asia/Kolkata' date  '+%d-%m-%Y'`"
echo "Content-Type: text/html"
ncount=`cat $Master_Path/final_CSdown | wc -l`

#echo -e "<html><body></br></br><font FACE=\"Merriweather\"><b>Hi Team\n $ncount CS are currently down. Please look into it</b></br></br></br>"
#echo -e "<html><body></br></br><font FACE=\"Merriweather\"><b>Hi Team\n $ncount CS are currently down. Please look into it</b></br></br></br>"

#echo -e "<b>Below is the summary of CS down city-wise:</b></br><table border=5><tr><th bgcolor=navy><FONT COLOR=white FACE=\"Merriweather\"SIZE=2>City <th bgcolor=navy><FONT COLOR=white FACE=\"Merriweather\"SIZE=2>Count</th></tr><tr>$city_summary</table></br></br>"
echo -e "<html><body></br></br><font FACE=\"Merriweather\"><b>Hi Team\n $ncount CS are currently down. Please look into it</b></br></br></br><br>"

echo -e "<b>Below is the summary of CS down city-wise:</b></br><table border=5><tr><th bgcolor=orange><FONT COLOR=black FACE=\"Merriweather\"SIZE=2>City <th bgcolor=orange><FONT COLOR=black FACE=\"Merriweather\"SIZE=2>Count</th></tr><tr>$city_summary</table></br></br>"

echo -e "<b>Below is the details of CS down machine-wise:</b></br></br></br>"

# Include the HTML-formatted table content
nfile=$(cat "$Master_Path/final_CSdown.html")
echo "$nfile"
) | /usr/sbin/sendmail -F "bbinstanttech" -t
#rm /root/scripts/CS_DOWNTIME/final_CSdown
