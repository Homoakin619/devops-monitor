# System Monitoring Scripts Installation and Configuration Guide
## Introduction
This guide provides detailed instructions on installing and configuring the system monitoring scripts. These scripts log various system activities, such as open ports, user logins, and running Docker containers. The logs are stored in a centralized log file with automated log rotation.

## Prerequisites
- Root or sudo access: Required for installing dependencies, setting up log rotation, and accessing certain system logs.
- Bash shell: Ensure your system has a Bash shell available.

## Script Overview
This script logs various system activities, including open ports, user logins, and Docker containers. Also sets up automated log rotation for the generated logs.

## Installation and Configuration
- Clone the repository
- Make the install `setup_monitor.sh`  and `monitor.sh` files executable by running
  `chmod +x setup_monitor.sh` and `chmod +x monitor.sh`
- Execute `./setup_monitor.sh`
- Execute `./monitor.sh`
- The `setup_monitor.sh` sets up a systemd service for our monitor while the `monitor.sh` does the basic setup of the monitor.

In this script we use `logrotate` to log system activities to a log file which you can customize as you want. Look into the `monitor.sh` file to customize the logger Configuration as you want.

## Customization
**monitor.sh**

`LOG_FILE="/var/log/system_monitor.log"` Edit this line to fit the directory where you want your logs to be saved

```json
  setup_logrotate() {
   cat <<EOF | sudo tee /etc/logrotate.d/system_monitor
$LOG_FILE {
    daily  // indicates that the log file should be rotated daily

  //This indicates that up to 7 rotated log files should be kept. Older logs beyond this number will be deleted
    rotate 7   

// This directive tells logrotate to proceed without error if the log file is missing. Without this directive, logrotate might generate an error if the log file doesn't exist
    
    missingok  
   
    // This specifies that log rotation should not occur if the log file is empty. This prevents the creation of unnecessary rotated files 
   
    notifempty 

    // This directive specifies the permissions and ownership of new log files created during rotation
    // 0640 sets the file permissions (owner can read/write, group can read, others have no access).
    // root root specifies that the file owner and group will be set to root
    
    create 0640 root root 


    postrotate
    // this restarts the service
        systemctl restart monitoring.service > /dev/null
    endscript
}
EOF
}
```



