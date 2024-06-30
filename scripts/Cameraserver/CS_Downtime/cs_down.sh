#!/bin/bash

ALERT_DIR="/root/scripts/Cameraserver/CS_Downtime"
CurrentCS_List="/root/scripts/Cameraserver/Machine_Details"

# Query to fetch the active machine list
#mysql -u mysql_readonly -pR2e5a1d1o2n0l0y6 -h bbinstant-readonly-mysql.cyu5asiuwdao.ap-south-1.rds.amazonaws.com kwik24 -se "select name from machine order by name ASC ;"  2> /dev/null  > $ALERT_DIR/DBActive
mysql -u dashboard_user -ps1u9p0e3r1s9t7a7r -hmysql.staging.aws.bigbasketinstant.com dashboard -se "select distinct m.name from dashboard.location l, dashboard.machine m where m.location_id=l.id and l.v3_api=1 and  l.status=1 and m.state='Active' and m.name not in ('BB Test HydMachine2','BB Test HydMachine3','KW10092C','KW10119WR') group by  l.id, m.name order by m.name ASC ;"  2> /dev/null  > $ALERT_DIR/DBActive
find ${CurrentCS_List} -type f -mmin -60 > ${ALERT_DIR}/rough_extracted.txt
cat ${ALERT_DIR}/rough_extracted.txt |  grep -Eo '.{14}$' | cut -d'_' -f2 > ${ALERT_DIR}/CurrentActive

 
comm -23 <(sort "$ALERT_DIR/DBActive") <(sort "$ALERT_DIR/CurrentActive") >$ALERT_DIR/down

## Fetching CS details.....

db_host="mysql.staging.aws.bigbasketinstant.com"
db_user="dashboard_user"
db_pass="s1u9p0e3r1s9t7a7r"
db_name="dashboard"

input_file="$ALERT_DIR/down"

# Define the query prefix and suffix
query_prefix="select CONCAT(' - ', l.state, ' - ') as State,m.friendly_name as Location from machine m, location l where  m.location_id=l.id and m.name IN ("
query_suffix=")"

while read line; do

  value=$(echo "$line" | awk '{print $1}')
  query="${query_prefix}'${value}'${query_suffix}"

  output=$(mysql -h "$db_host" -u "$db_user" -p"$db_pass" -D "$db_name" -se "$query")
  echo "${line} ${output}" >> "$ALERT_DIR/CS_down"
done < "$input_file"


####################

##Putting into correct FORMAT 
sed -i 's/-\([^\t]*\)\t/-\1/g' $ALERT_DIR/CS_down
sed -i 's/-/\t/1;s/-/\t/1' $ALERT_DIR/CS_down

cp $ALERT_DIR/CS_down $ALERT_DIR/rough

a="$ALERT_DIR/rough"
while IFS= read -r line; do
    printf '%s\n' "$line" | sed -e 's/^/<td bgcolor=#E0FFFF><font FACE="Merriweather">/' | sed -e 's/\t/<\/td><td bgcolor=#FFFFEA><font FACE="Merriweather">/g' | sed -e 's/,/<\/td><td bgcolor=#e8ffe2><font FACE="Merriweather">/g' |sed -e 's/$/<\/td><\/tr><tr>/'
    done < $a > $ALERT_DIR/CS_down

BLR_count=`cat $ALERT_DIR/CS_down | grep -w KA | wc -l`
cat $ALERT_DIR/CS_down | grep -w KA >$ALERT_DIR/blr.txt
cp $ALERT_DIR/blr.txt $ALERT_DIR/blr.html

HYD_count=`cat $ALERT_DIR/CS_down | grep -w TS | wc -l`
cat $ALERT_DIR/CS_down | grep -w TS >$ALERT_DIR/hyd.txt
cp $ALERT_DIR/hyd.txt $ALERT_DIR/hyd.html

MH_count=`cat $ALERT_DIR/CS_down | grep -w MH | wc -l`
cat $ALERT_DIR/CS_down | grep -w MH >$ALERT_DIR/mum.txt
cp $ALERT_DIR/mum.txt $ALERT_DIR/mum.html

NCR_count=`cat $ALERT_DIR/CS_down | egrep -w 'HR|UP|DL' | wc -l`
cat $ALERT_DIR/CS_down | egrep -w 'HR|UP|DL' >$ALERT_DIR/ncr.txt
cp $ALERT_DIR/ncr.txt $ALERT_DIR/ncr.html

TN_count=`cat $ALERT_DIR/CS_down | grep -w TN | wc -l`
cat $ALERT_DIR/CS_down | grep -w TN >$ALERT_DIR/chennai.txt
cp $ALERT_DIR/chennai.txt $ALERT_DIR/chennai.html

DATE=$(TZ='Asia/Kolkata' date '+%d-%m-%Y at %H:%M')
time=$(TZ='Asia/Kolkata' date '+%R.%p')

 
 sed -i '1i <html><body><table border=5>' $ALERT_DIR/*html
 sed -n -i 'p;1a <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Machine <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>City<th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Location</td></tr><tr>' $ALERT_DIR/*html


 sed -i '$a </table></body></html>' $ALERT_DIR/*html



 echo "Sending Machine Downtime Details"

BTo="satyanarayan.biswal@bigbasket.com"
BSubject="Bangalore CS down on `TZ='Asia/Kolkata' date '+%d-%m-%Y'`"
bcount=`cat $ALERT_DIR/blr.txt | wc -l`
bfile=`cat $ALERT_DIR/blr.html`
{ echo "<font face='Cambria' size='4'><b>Hi Team,<br>$bcount Camera Server are down in Bangalore at `TZ='Asia/Kolkata' date '+%R %p'`</b></font>";echo "$bfile"; } | mutt -e "set content_type=text/html" -s "$BSubject" -- "$BTo" 


