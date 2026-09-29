#!/bin/bash

docker exec mysql-source mysql -uroot -proot -e "CREATE USER IF NOT EXISTS 'repluser'@'%' IDENTIFIED BY 'repluser'; GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%'; FLUSH PRIVILEGES;"

docker exec mysql-source mysql -uroot -proot -e "SHOW MASTER STATUS\G"
