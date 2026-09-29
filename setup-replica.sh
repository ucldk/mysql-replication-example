#!/bin/bash

SOURCE_STATUS=$(docker exec mysql-source mysql -uroot -proot -N -B -e "SHOW MASTER STATUS" 2>/dev/null)
SOURCE_LOG_FILE=$(echo "$SOURCE_STATUS" | cut -f1)
SOURCE_LOG_POS=$(echo "$SOURCE_STATUS" | cut -f2)

if [ -z "$SOURCE_LOG_FILE" ] || [ -z "$SOURCE_LOG_POS" ]; then
  echo "Could not read binary log file and position from mysql-source" >&2
  exit 1
fi

docker exec mysql-replica mysql -uroot -proot -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='mysql-source', SOURCE_USER='repluser', SOURCE_PASSWORD='repluser', SOURCE_LOG_FILE='$SOURCE_LOG_FILE', SOURCE_LOG_POS=$SOURCE_LOG_POS; START REPLICA;"

docker exec mysql-replica mysql -uroot -proot -e "SHOW REPLICA STATUS\G"
