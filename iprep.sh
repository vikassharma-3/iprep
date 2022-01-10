#author=Vikas Sharma
#email=vikassharma18@gnu.ac.in
VAR1=""
echo "File Name: $1"

xlsx2csv $1 | cut -d ',' -f4 | awk -F ":" '{print $1}' | awk -F "local -> " '{print $NF}'  > ip.txt

while IFS= read -r line;
do
	score=$(curl -X POST https://www.ipvoid.com/ip-blacklist-check/ -H "Content-Type: application/x-www-form-urlencoded" -d "ip=$line" | grep "Blacklist Status" | awk '{gsub("<tr><td>"," ");print}' | awk '{gsub("</td><td><span class=\"label label-danger\">"," ");print}' | awk '{gsub("</td><td><span class=\"label label-success\">"," ");print}' | awk '{gsub("</td><td><span class=\"label label-warning\">"," ");print}' | awk '{gsub("</span></td></tr>","");print}' | awk '{gsub("Blacklist Status","");print}' | xargs)
       echo "$line,$score" >> ipstatus.txt
       r=$(echo $score | awk '{gsub("BLACKLISTED ","");print}' | awk '{gsub("POSSIBLY SAFE ","");print}' | awk -F "/115" '{print $1}')
       if [ "$r" = "$VAR1" ];
       then 
	    echo "$line,None" >> fot.csv
       elif [ $r -lt 4 ] && [ $r -gt 0 ];
       then
            echo "$line,Medium" >> fot.csv
       elif [ $r -gt 3 ];
       then
            echo "$line,High" >> fot.csv
       elif [ "$r" = "0" ];
       then
            echo "$line,Safe" >> fot.csv
       else
            echo "$line,Error" >> fot.csv 
       fi   
done < ip.txt


