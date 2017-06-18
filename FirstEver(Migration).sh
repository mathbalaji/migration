#!/bin/bash
#Script to automate the EOD Process for Migration Testing
#Script written by Balaji
clear
read -p "Only root can run this script. Other users running this script may endup getting errors - Are you root? (Yy/Nn)?" choice
while true
do
    case $choice in
        [yY]* )
            echo "Hello root"
            echo "Script initiated... Please wait while we modify the database values for you..."
            echo ""
            rm -rf /var/user/data/VM/EOD/*
            read -p "EOD for 24 hours store? [Yy/nN] (Y for 24 hours and N for non-24 Hours): " value
            while true
            do
                case $value in
                    [yY]* )
                        echo "Updating for 24 hours store"
                        echo ""
                        su -c "db2 -tx 'connect to cdb';db2 -tvf '/home/user/mig/update24.sql'" - db2usr1
                        su -c "db2 terminate" - db2usr1
                        echo "Updates done... ..."
                        break ;;
					[nN]* )
                        echo "Updating for non-24 hours store"
                        echo ""
                        su -c "db2 -tx 'connect to cdb'; db2 -tvf '/home/user/mig/update.sql'" - db2usr1 > /dev/null
                        echo "Updates done... ... Start and End timings are as follows:"
                        echo ""
                        su -c "db2 -tx 'connect to cdb'; db2 -tvf '/home/user/mig/select.sql'" - db2usr1 > /home/user/mig/text.txt
                        echo "Following are START and END times respectively, separated by 1 "
                        echo ""
                        awk -F "-" '{ print $1 }' /home/user/mig/text.txt | awk -F " " '{print $1 }' | awk -F "Database" '{ print $1 }' | awk -F "SQL" '{ print $1 }'
| awk -F "Local" '{ print $1 }' | awk -F "SELECT" '{ print $1 }' | awk -F "ASPV_VALUE" '{ print $1 }' | awk "NF > 0"
                        su -c "db2 terminate" - db2usr1 >/dev/null
                        echo ""
                        read -p "Enter the Immediate Restart Start Time: [Format - 04:00 or 18:00]: " starttime
                        read -p "Enter the Immediate Restart End Time: [Format - 10:00 or 23:00]: " endtime
                        cat /home/user/mig/timeupdt.txt | sed s/STARTVAL/$starttime/g | sed s/ENDVAL/$endtime/g > /home/user/mig/TimeUpdt.sql
                        echo ""
                        echo "Updating Start and End Timings... ..."
                        su -c "db2 -tx 'connect to cdb'; db2 -tvf '/home/user/mig/TimeUpdt.sql'" - db2usr1 > /dev/null
                        su -c "db2 terminate" - db2usr1 >/dev/null
                        echo ""
                        echo "Updates done. Here's the updated values: "
                        su -c "db2 -tx 'connect to cdb'; db2 -tvf '/home/user/mig/select.sql'" - db2usr1 > /home/user/mig/text.txt
                        echo "Following are START and END times respectively, separated by 1 "
                        echo ""
                        awk -F "-" '{ print $1 }' /home/user/mig/text.txt | awk -F " " '{print $1 }' | awk -F "Database" '{ print $1 }' | awk -F "SQL" '{ print $1 }'
| awk -F "Local" '{ print $1 }' | awk -F "SELECT" '{ print $1 }' | awk -F "ASPV_VALUE" '{ print $1 }' | awk "NF > 0"
                        su -c "db2 terminate" - db2usr1 >/dev/null
						break ;;
                esac
            done
        break ;;
            [nN]* )
                exit ;;
    esac
done
