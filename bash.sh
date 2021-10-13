#!/bin/sh
sudo apt-get update
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
#run docker compose
sudo docker build -t contohlapak .
sudo docker-compose down
sudo docker-compose up -d
mysql -u root -ppass -P 3306 -H mysql < tables.sql
./contohlapak
