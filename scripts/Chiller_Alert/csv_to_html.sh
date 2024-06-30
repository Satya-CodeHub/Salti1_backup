#!/bin/bash

IFS=$','
first=1
echo "<html><body></br></br><p><strong> Team Below Are The Locations Where Machine Temperature Is Not Proper Chiller Alert Triggred, Please Have a Check Immeditely.</strong></p></br></br></br>"
echo "<html><body></br></br><p>Temprature Threshold Lower_Limit=<strong>18700</strong></p></br></br></br>"
echo "<html><body></br></br><p>Temprature Threshold Upper_Limit=<strong>23000</strong></p></br></br></br>"
echo '<table border=1 cellspacing=1 cellpadding=1>'
while read -r Machine_ID Machine_Name State Temprature; do
    [[ $first == 1 ]] && element=th || element=td
    first=0
    echo "<tr>"
    echo "<$element>$Machine_ID</$element><$element>$Machine_Name</$element><$element>$State</$element><$element>$Temprature</$element>"
    echo "</tr>"
done < $1
echo '</table></body></html>'
