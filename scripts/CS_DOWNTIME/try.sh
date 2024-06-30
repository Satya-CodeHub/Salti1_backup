#!/bin/bash

ALERT_DIR="/root/scripts/CS_DOWNTIME"

vlo_file="$ALERT_DIR/vlo"

# Copy the content of the file named `klo` to a new file named `vlo`
sudo cp "$ALERT_DIR/klo" "$ALERT_DIR/vlo"

# Process each line of the file and format it as an HTML table
while IFS= read -r line; do
    printf '%s\n' "$line" |sudo sed -e 's/^/<td bgcolor=#E0FFFF><font FACE="Merriweather">/' |sudo sed -e 's/\t/<\/td><td bgcolor=#FFFFEA><font FACE="Merriweather">/g' |sudo  sed -e 's/\t/<\/td><td bgcolor=#FFFFEA><font FACE="Merriweather">/g' | sudo sed -e 's/$/<\/td><\/tr><tr>/'
done < "$vlo_file" > "$ALERT_DIR/klo"

# Create an HTML file with header and footer
sudo cp "$ALERT_DIR/klo" "$ALERT_DIR/klo.html"
sudo sed -i '1i <html><body><table border=5>' "$ALERT_DIR/klo.html"
sudo sed -n -i 'p;1a <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Machine <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Last_Accessed <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>City <th bgcolor=navy><FONT COLOR=white FACE="Merriweather"SIZE=2>Location </td></tr><tr>' "$ALERT_DIR/klo.html"
sudo sed -i '$a </table></body></html>' "$ALERT_DIR/klo.html"

# Perform summarization based on city and store it in a variable
#city_summary=$(awk '{ count[$3]++; } END { total=0; for (city in count) { print "<tr><td bgcolor=#E0FFFF style=\"text-align:center;\"><font FACE=\"Merriweather\">" city "</td><td bgcolor=#C7FFFF style=\"text-align:center;\"><font FACE=\"Merriweather\">" count[city] "</td></tr>"; total+=count[city]; } print "<tr><td bgcolor=#E0FFFF style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>Total</b></td><td bgcolor=#FFFFEA style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>" total "</b></td></tr>"; }' "$vlo_file")
city_summary=$(awk '{ count[$3]++; } END { total=0; for (city in count) { print "<tr><td bgcolor=#FFFFEA style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>" city "</b></td><td bgcolor=#FFFFEA style=\"text-align:center;\"><font FACE=\"Merriweather\"><b>" count[city] "</b></td></tr>"; total+=count[city]; } print "<tr><td bgcolor=#a5d732 style=\"text-align:center;\"><font FACE=\"Merriweather\"><strong>Total</b></td><td bgcolor=#a5d732 style=\"text-align:center;\"><font FACE=\"Merriweather\"><strong>" total "</b></td></tr>"; }' "$vlo_file")



# Email Notification
(
echo "To:satyanarayan.biswal@bigbasket.com"

echo "Subject: CameraServer Down Alert on `TZ='Asia/Kolkata' date  '+%d-%m-%Y'`"
echo "Content-Type: text/html"
ncount=`cat $ALERT_DIR/klo | wc -l`

# Include a header and summary of the vlo file based on city in the email body
#echo -e "<html><body></br></br><font FACE=\"Merriweather\"><b>Hi Team\n $ncount CS are currently down. Please look into it</b></br></br></br>"
#echo -e "<html><body></br></br><font FACE=\"Merriweather\"><b>Hi Team\n $ncount CS are currently down. Please look into it</b></br></br></br>"

#echo -e "<b>Below is the summary of CS down city-wise:</b></br><table border=5><tr><th bgcolor=navy><FONT COLOR=white FACE=\"Merriweather\"SIZE=2>City <th bgcolor=navy><FONT COLOR=white FACE=\"Merriweather\"SIZE=2>Count</th></tr><tr>$city_summary</table></br></br>"
echo -e "<html><body></br></br><font FACE=\"Merriweather\"><b>Hi Team\n $ncount CS are currently down. Please look into it</b></br></br></br><br>"

echo -e "<b>Below is the summary of CS down city-wise:</b></br><table border=5><tr><th bgcolor=orange><FONT COLOR=black FACE=\"Merriweather\"SIZE=2>City <th bgcolor=orange><FONT COLOR=black FACE=\"Merriweather\"SIZE=2>Count</th></tr><tr>$city_summary</table></br></br>"

# Include a header and summary of the vlo file based on location in the email body
echo -e "<b>Below is the details of CS down machine-wise:</b></br></br></br>"

# Include the HTML-formatted table content
nfile=$(cat "$ALERT_DIR/klo.html")
echo "$nfile"
) | /usr/sbin/sendmail -F "bbinstanttech" -t
