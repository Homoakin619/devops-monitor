# Server Information Retrieval Script (devopsfetch) Documentation 


## Prerequisites
- Root or sudo access: Required for installing dependencies, setting up log rotation, and accessing certain system logs.
- Bash shell: Ensure your system has a Bash shell available.
- You need to have docker installed to be able to use the docker retrieval flags
- You need to have netstat installed
- You also need to have nginx install to enjoy the nginx capabilities of this script

### Docker Installation
To install docker run the following commands in your terminal if you are on ubuntu, or refer to the docker Documentation on how to install docker
```json
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
```

### netstat Installation
```json
sudo apt-get update
sudo apt install net-tools 
```

### nginx Installation
```json
sudo apt-get update
sudo apt install nginx
```

## How to use this script
- make the script executable
- In your terminal run `chmod +x devopsfetch.sh`
- Now you can use the script by running `./devopsfetch.sh flag <parameter>`


## Flags Documentation

** Below are the flags and how to use them **
1. Ports:
   - Display all active ports and services `(-p or --port)`.
   - Provide detailed information about a specific port `(-p <port_number>)`.
2. Docker:
   - List all Docker images and containers `(-d or --docker)`.
   - Provide detailed information about a specific container `(-d <container_name>)`.
3. Nginx:
   - Display all Nginx domains and their ports `(-n or --nginx)`.
   - Provide detailed configuration information for a specific domain `(-n <domain>)`.
4. Users:
   - List all users and their last login times `(-u or --users)`.
   - Provide detailed information about a specific user `(-u <username>)`.
5. Time Range:
   - Display activities within a specified time range `(-t or --time)`.