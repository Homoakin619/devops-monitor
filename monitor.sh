#!/bin/bash

LOG_FILE="/var/log/system_monitor.log"

setup_logrotate() {
   cat <<EOF | sudo tee /etc/logrotate.d/system_monitor
$LOG_FILE {
    daily
    rotate 7
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl restart monitoring.service > /dev/null
    endscript
}
EOF
}


monitor_activities() {
    while true; do
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "| ****************Logging system activities at $(date) ***************|"n>> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "" >> $LOG_FILE
        echo "" >> $LOG_FILE
        
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "|**************************** Active Ports *****************************|" >> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "" >> $LOG_FILE
        netstat -tuln | grep LISTEN >> $LOG_FILE
        echo "" >> $LOG_FILE
        echo "" >> $LOG_FILE

        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "|***************************** User Logins *****************************|" >> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        last | head -n 10 >> $LOG_FILE

        echo "" >> $LOG_FILE
        echo "" >> $LOG_FILE

        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "|************************** Login Attempts *****************************|" >> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "" >> $LOG_FILE
        grep "Failed password" /var/log/auth.log >> $LOG_FILE
        echo "" >> $LOG_FILE
        echo "" >> $LOG_FILE

        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "|********************* Docker Containers *******************************|" >> $LOG_FILE
        echo "+-----------------------------------------------------------------------+" >> $LOG_FILE
        echo "" >> $LOG_FILE
        docker ps >> $LOG_FILE
        echo "#############################################################################################################" >> $LOG_FILE
        sleep 60
    done
}

setup_logrotate
monitor_activities
