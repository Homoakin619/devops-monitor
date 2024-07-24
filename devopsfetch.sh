#!/bin/bash

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "-h, --help                        Display help message"
    echo "-p, --port                        List all active ports and services"
    echo "-p <port>                         Display details about a port"
    echo "-d, --docker                      List all docker images and containers"
    echo "-d <container_name>               Display information about specified container"
    echo "-n, --nginx                       List all docker images and containers"
    echo "-n <domain>                       Display information about specified domain"
    echo "-u, --users                       List all docker images and containers"
    echo "-u <username>                     Display information about specified container"
    echo "-t, --time                        Display activities within a specified time range"
}

display_port_details() {
    local PORT=$1

    echo '+-------------------------------------------+'
    echo "| ****** Port Process Information ********* |"
    echo '+-------------------------------------------+'
    ss -tulnp | grep ":$PORT"

    echo ""
    echo '+-------------------------------------------+'
    echo "| ***** Process and Service Details ******* |"
    echo '+-------------------------------------------+'
    sudo lsof -i :"$PORT"

    echo ""
    echo '+-------------------------------------------+'
    echo "| ***** Network Connections Details ******* |"
    echo '+-------------------------------------------+'
    sudo netstat -tulnp | grep ":$PORT"

}

list_all_open_ports() {
    
    echo -e "\n\033[1;34mActive Ports and Services:\033[0m"
    printf "%-25s %-12s %-20s\n" "   USER   " "   PORT   " "   SERVICE   "
    echo "------------------------------------------------------------"

    sudo netstat -tuln | grep LISTEN | while read -r line; do
        PROTOCOL=$(echo $line | awk '{print $1}')
        IP_PORT=$(echo $line | awk '{print $4}')
        PORT=$(echo $IP_PORT | awk -F: '{print $NF}')
        SERVICE=$(grep -w $PORT /etc/services | awk '{print $1}' | head -n 1 )
        if [[ -z $SERVICE ]]; then
            SERVICE="unknown"
        fi
        sudo lsof -i :"$PORT" | awk 'NR>1 {print $3}' | while read -r USER; do
            printf "%-25s %-12s %-20s\n" "|   "$USER"   " "   $PORT  " "   $SERVICE   "
        done
        
    done
}



list_docker_images_and_containers () {
    echo '+--------------------------------------------------------+'
    echo '| ################# DOCKER CONTAINERS "################# |'
    echo '+--------------------------------------------------------+'
    sudo docker container list
    echo ''
    echo '+--------------------------------------------------------+'
    echo '| ################### DOCKER IMAGES "################### |'
    echo '+--------------------------------------------------------+'
    sudo docker images -a
}

show_container_details() {
    sudo docker inspect $1
}




show_user_details() {
    local username=$1
    
    group_id=$(id -u $username)
    user_id=$(id -u $username)
    groups=$(groups $username | awk -F ':' '{print $2}')
    user_group_id=$(id -u $username)
    user_home=$(getent passwd "$username" | cut -d: -f6)
    user_shell=$(getent passwd "$username" | cut -d: -f7)

    echo '--------------------------------------------------------'
    echo "| Showing Details for $username"
    echo '---------------------------------------------------------'

    printf "%-15s %-40s\n" "User Id:" "$user_id"
    printf "%-15s %-40s\n" "Group Id:" "$group_id"
    printf "%-15s %-40s\n" "User Groups:" "$groups"
    printf "%-15s %-40s\n" "User Home Directory:" "$user_home"
    printf "%-15s %-40s\n" "User Shell:" "$user_shell"
}


show_domain_details(){

    local domain=$1
    
    echo '--------------------------------------------------------'
    echo "| Showing Details for $domain"
    echo '---------------------------------------------------------'
    if [ -z "$domain" ]; then
        echo "Please provide a domain."
        exit 1
    fi

    sudo nginx -T 2>/dev/null | awk '
    $0 ~ /server_name.*'"$domain"'/, /}/ {
        if ($0 ~ /server_name/ && $0 ~ /'"$domain"'/) { capture=1 }
        if (capture) { print }
        if ($0 ~ /}/) { capture=0 }
    }'

}

list_users_and_login_times() {
    last | awk '
    BEGIN {
        print "+---------------------------------------------------------+"
        printf "%-20s %-25s %-20s\n", "| Username", "Login Date", "Login Time |"
        print "+---------------------------------------------------------+"

    }
    /^[a-zA-Z]/ && $1 != "reboot" && $1 != "wtmp" {
        if (!seen[$1]++) {
            printf "%-20s %-25s %-20s\n", $1, $4" "$5" "$6, $7
        }
    }'
}


list_activities_by_time_range() {
    local start_date="$1"
    local end_date="$2"

    echo '---------------------------------------------------------------------------'
    echo "|******** "Showing Logs from $start_date to ${end_date:-$start_date}" *******"
    echo '----------------------------------------------------------------------------'
    if [ -z "$end_date" ]; then
        journalctl --since "$start_date" --until "$end_date"
    else
        journalctl --since "$start_date"
    fi   
}


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--port)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                PORT_VALUE="$2";
                shift
            else
                LIST_ALL_PORTS=true
            fi
            ;;
        -d|--docker)
            
            if [[ -z "$2" ]]; then
                LIST_CONTAINERS=true
            else
                CONTAINER_NAME="$2";
                shift
            fi;
            ;;
        -n|--nginx)
            if [[ -z "$2" ]]; then
                NGINX_CONFIG=true
            else 
                NGINX_DOMAIN="$2"
                shift
            fi
            ;;
        -u|--users)
            if [[ -z $2 ]]; then
                LIST_USERS=true
            else
                
                USERNAME=$2
                shift
            fi
            ;;
        -t|--time)
            if [[ -n "$2" && "$2" != -* ]]; then
                START_DATE=$2
                shift
                if [[ -n "$2" && "$2" != -* ]]; then
                    END_DATE=$2
                    shift
                fi
            else
                usage
            fi
            ;;
                
        *)
            echo "Invalid flag passed"
            usage
            exit 1
    esac
    shift
done


if [[ -n "$PORT_VALUE" ]]; then
    display_port_details $PORT_VALUE
elif [[ "$LIST_ALL_PORTS" == true ]]; then
    list_all_open_ports
elif [[ "$LIST_CONTAINERS" == true ]]; then
    list_docker_images_and_containers
elif [[ -n "$CONTAINER_NAME" ]]; then
    show_container_details $CONTAINER_NAME
elif [[ -n "$START_DATE" ]]; then
    list_activities_by_time_range $START_DATE $END_DATE
elif [[ "$NGINX_CONFIG" == true ]]; then
    list_nginx_vhosts
elif [[ "$LIST_USERS" == true ]]; then
    list_users_and_login_times
elif [[ -n "$USERNAME" ]]; then
    show_user_details $USERNAME
elif [[ -n "$NGINX_DOMAIN" ]]; then
    show_domain_details $NGINX_DOMAIN
else
    usage
    exit 1;
fi