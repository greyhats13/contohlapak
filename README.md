##Answers
Everything is automated using bash.sh
Contohlapak is open on port 9090 with MySQL Redis and LoadBalanced Enabled using nginx
and the IP address 35.197.146.80 is pointed to contohlapak.blast.co.id.
You can access the endpoint using https://contohlapak.blast.co.id/db
without using port because it is proxied using Nginx

## Bash Script
```bash
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
# sudo docker build -t greyhats13/contohlapak:latest . --no-cache
sudo docker-compose build --no-cache
sudo docker-compose up -d
sudo docker exec -i mysql mysql -uroot -ppass < tables.sql
#For generating certificate before add server listen 443
# sudo docker-compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d contohlapak.blast.co.id
```

##Docker Compose
Here is the yaml file using version: 3.1. Docker compose will run 7 containers.
```yaml
version: '3.1'

services:
  mysql:
    container_name: mysql
    restart: always
    image: mysql
    volumes:
      - mysql_data:/var/lib/mysql
    restart: always
    ports:
      - 3306:3306
    networks:
      - contohlapak_network
    environment:
      MYSQL_DATABASE: contohlapak
      MYSQL_ROOT_PASSWORD: pass
  redis:
    container_name: redis
    image: redis
    restart: always
    ports:
      - 6379:6379
    networks:
      - contohlapak_network
  phpmyadmin:
    container_name: phpmyadmin
    restart: always
    image: phpmyadmin/phpmyadmin
    ports:
      - "8081:80"
    networks:
      - contohlapak_network
    depends_on:
      - mysql
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      PMA_USER: root
      PMA_PASSWORD: pass
  contohlapak:
    container_name: contohlapak
    restart: always
    # image: greyhats13/contohlapak:latest
    build:
      dockerfile: Dockerfile
      context: .
    # ports:
    #   - 9090:9090
    networks:
      - contohlapak_network
    environment:
      - MYSQL_ENABLED=true
      - REDIS_ENABLED=true
      - LOAD_BALANCED=true
      - LISTEN_PORT=9090
      - MYSQL_ADDR=mysql:3306
      - MYSQL_USER=root
      - MYSQL_PASS=pass
      - MYSQL_ROOT_PASSWORD=pass
      - MYSQL_DB=contohlapak
      - REDIS_ADDR=redis:6379
      # - HEADER_AUTH_KEY=X-CONTOHLAPAK-AUTH
    depends_on:
      - mysql
      - redis
      - phpmyadmin
  nginx:
    container_name: nginx
    image: nginx:latest
    # build:
    #   dockerfile: Dockerfile-nginx
    #   context: .
    networks:
      - contohlapak_network
    ports:
      - 80:80
      - 443:443
    restart: always
    volumes:
      - ./nginx/conf/:/etc/nginx/conf.d/:ro
      - ./certbot/www:/var/www/certbot/:ro
      - ./certbot/conf/:/etc/nginx/ssl/:ro
    depends_on: 
      - contohlapak
  certbot:
    container_name: cerbot
    image: certbot/certbot
    networks:
      - contohlapak_network
    volumes:
      - ./certbot/www/:/var/www/certbot/:rw
      - ./certbot/conf/:/etc/letsencrypt/:rw
networks:
  contohlapak_network:
    driver: bridge
volumes:
  mysql_data:
    driver: local
```
All the containers is communicating using contohlapak_networks
* Mysql container run port 3306
* MySQL is using volume mysql_data:/var/lib/mysql to make the data inside MyQL to be persistent
* Redis running in port 6379
* PhpMyAdmin running in port 8081, must be accessed without https in port 8081 http://contohlapak.blast.co.id:8081
* Contohlapak is running in port 9090 but have been proxied using https with Nginx
* Contohlapak is using environment variables from docker-compose
* Contohlapak is depend on mysql and redis container
* Contohlapak images is build using Dockerfile
```Dockerfile
FROM golang:buster

RUN mkdir /app
WORKDIR /app
COPY contohlapak .

EXPOSE 9090

ENTRYPOINT ["/app/contohlapak"]
```
The dockerfile is quite simple from golang Linux amd64 architecture. It was simple because we build the images from Golang binary.

* Nginx is running in port 80 and 443.
* Nginx as load balancing will redirect http to https
* Nginx using certificate that is generated by Certbot
* Nginx is using default.conf that will be copied to /etc/nginx/conf.d/ with read only mode

* Certbot is the container that will generate SSL certificate for contohlapak.blast.co.id
* THe certificate will be stored in certbot directory.
* After certificate is issue, then I added the server listener for 443 in Nginx and proxypass to http://contohlapak:9090


## Overview
Contohlapak is a simple Go application that, when run, serves a web server at
port 80. Its behavior can be modified by supplying environment variables or by
running it on the same folder as a `.env` file.

### Basic Endpoints
All responses from the application is JSON.
* `GET /healthz` will return a simple 200 OK if the application is running.
* `GET /metrics` will return a prometheus metrics page.

### MySQL Endpoints
* `GET /db` will return all entries in the `lapak` table.
* `POST /db` will insert an entry to the `lapak` table given a JSON request body
   with the following schema:
   ```json
   {
     "name": "lapak01",
     "owner": "budi",
     "products_sold": 10
   }
   ```

### Redis Endpoints
* `GET /cache` will retrieve the value of a stored key. The `key` attribute is
   required.
* `GET /cache/list` will retrieve all keys in the cache.
* `POST /cache` will store a new key-value pair into the cache. The `key` and
  `value` attribute is required.

## Configuration
All configuration is done via environment variables, which can be supplied 
normally or by placing an `.env` file in the folder where the application is
located (see `.env.sample` file given for example). 

### Basic
* `LISTEN_PORT` changes the port which the application will listen in for
  requests. Defaults to 8080 if not specified.

### Feature Toggles
The application currently supports three features that can be enabled or disabled
by setting specific environment variables:
* MySQL (`MYSQL_ENABLED`)
* Redis (`REDIS_ENABLED`)
* Load Balancing (`LOAD_BALANCED`)

In order to enable the feature, the value of those variables must be set to `true`.

### Redis-specific
* `REDIS_ADDRESS` defines the redis address which the application will connect
  to.

### MySQL-specific
* `MYSQL_ADDRESS` defines the address of the mysql instance
* `MYSQL_USER` defines the username used to authenticate into the mysql instance
* `MYSQL_PASS` defines the password used to authenticate into the mysql instance
* `MYSQL_DB` defines the name of the database the application will connect to.
  **The database schema needs to be initialized manually.**
* MySQL Schema:
  ```mysql
  CREATE TABLE IF NOT EXISTS lapak (
    id INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY(id),
    lapak_name VARCHAR(256) NOT NULL,
    lapak_owner VARCHAR(256) NOT NULL,
    products_sold INT NOT NULL
  ); 
  ```
## Build Instructions
* You need Go installed to compile the program. It can be downloaded here:
  ```https://golang.org/dl/```
* The program can then be compiled by running the following command:
  ```
   GOOS=linux GOARCH=amd64 go build -o contohlapak app/main.go
  ```
* An executable should appear on the current directory, it can then be run:
  ```
  ./contohlapak
  ```
