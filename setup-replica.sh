docker exec -it mysql-replica mysql -uroot -proot -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='mysql-source', SOURCE_USER='repluser', SOURCE_PASSWORD='repluser', SOURCE_LOG_FILE='mysql-bin.000003', SOURCE_LOG_POS=157; START REPLICA;"

docker exec -ti mysql-replica mysql -uroot -proot -e "SHOW REPLICA STATUS\G"
