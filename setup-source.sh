docker exec -ti mysql-source mysql -uroot -proot -e "CREATE USER 'repluser'@'%' IDENTIFIED BY 'repluser'; GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%'; FLUSH PRIVILEGES;"

docker exec -ti mysql-source mysql -uroot -proot -e "SHOW MASTER STATUS\G"
