  CREATE TABLE IF NOT EXISTS contohlapak.lapak (
    id INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY(id),
    lapak_name VARCHAR(256) NOT NULL,
    lapak_owner VARCHAR(256) NOT NULL,
    products_sold INT NOT NULL
  ); 