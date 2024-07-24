#!/bin/bash

install_netstat() {
    sudo apt install net-tools 
}
install_nginx() {
    sudo apt install nginx
}


install_docker() {
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_dependencies() {
    sudo apt update
    sudo apt install -y logrotate
    install_netstat
    install_nginx
    install_docker
}

setup_systemd_service() {
    cat <<EOF | sudo tee /etc/systemd/system/monitoring.service
[Unit]
Description=System Monitoring Service

[Service]
ExecStart=/usr/local/bin/monitoring_script.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    
    sudo systemctl daemon-reload
    sudo systemctl enable monitoring.service
    sudo systemctl start monitoring.service
}


install_dependencies
setup_systemd_service
echo "Setup complete. System monitoring service is now active."
