#!/bin/bash
sudo yum update
sudo yum -y install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
# Get the latest version number of Docker Compose from GitHub
latest_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)

# Download Docker Compose binary
sudo curl -L "https://github.com/docker/compose/releases/download/${latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# grant permissions
sudo chmod +x /usr/local/bin/docker-compose