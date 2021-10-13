#!/bin/sh
sudo apt-get update
git pull
#Install docker on ubuntu
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg -y
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
#Install docker-compose
sudo apt-get -y install docker-compose
#disable docker-compose
sudo docker-compose down
#run docker compose
sudo docker build -t greyhats13/contohlapak:latest . --no-cache
sudo docker-compose up
# sudo docker exec -i mysql mysql -uroot -ppass < tables.sql
