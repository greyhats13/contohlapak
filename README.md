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
