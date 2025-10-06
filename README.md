## Files

### `source-config.cnf`

```ini
[mysqld]
server-id=1
log_bin=mysql-bin
binlog_format=ROW
binlog_do_db=testdb
```

- `[mysqld]`: This section contains settings for the MySQL server daemon.
- `server-id=1`: This sets a unique identifier for the MySQL server. In a replication setup, each server must have a different `server-id`, and it should be a positive integer
- `log_bin=mysql-bin`: This enables binary logging and specifies the base name for the binary log files. Binary logs are essential for replication as they record all changes to the database
- `binlog_format=ROW`: This sets the binary logging format to "ROW", which means that changes are logged at the row level. This is often preferred for replication because it provides more detailed information about changes
- `binlog_do_db=testdb`: This specifies that only changes to the database named `testdb` should be logged in the binary log. This is useful for limiting replication to specific databases
    - Multiple databases can be specified by using multiple `binlog_do_db` lines

### `replica-config.cnf`

```ini
[mysqld]
server-id=2
relay-log=mysql-relay-bin
log_bin=mysql-bin
binlog_format=ROW
replicate-do-db=testdb
```

- `[mysqld]`: This section contains settings for the MySQL server daemon.
- `server-id=2`: Same as source description above, but it must be different from the source's `server-id` or other replicas
- `relay-log=mysql-relay-bin`: This specifies the base name for the relay log files. Relay logs are used by the replica to store changes received from the source before applying them to its own database
- `log_bin=mysql-bin`: Same as source description above
- `binlog_format=ROW`: Same as source description above
- `replicate-do-db=testdb`: This specifies that only changes to the database named `testdb` should be replicated from the source. This is useful for limiting replication to specific databases
    - Multiple databases can be specified by using multiple `replicate-do-db` lines

### `setup-source.sh`

```bash
#!/bin/bash

docker exec -ti mysql-source mysql -uroot -proot -e "CREATE USER 'repluser'@'%' IDENTIFIED BY 'repluser'; GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%'; FLUSH PRIVILEGES;"

docker exec -ti mysql-source mysql -uroot -proot -e "SHOW MASTER STATUS\G"
```

### `setup-replica.sh`

```bash
#!/bin/bash

docker exec -it mysql-replica mysql -uroot -proot -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='mysql-source', SOURCE_USER='repluser', SOURCE_PASSWORD='repluser', SOURCE_LOG_FILE='mysql-bin.000003', SOURCE_LOG_POS=157; START REPLICA;"

docker exec -ti mysql-replica mysql -uroot -proot -e "SHOW REPLICA STATUS\G"
```

### `setup-source.sh`

En runner fil til at opsætte nødvendige konfigurationer på source serveren.

Opgaverne er splittet op så de er mere læsbare

```sql
CREATE USER 'repluser'@'%' IDENTIFIED WITH mysql_native_password BY 'repluser';
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%';
FLUSH PRIVILEGES;
```

- Creates a user named `repluser` with the password `repluser`
- This user gets the `REPLICATION SLAVE` privilege, which is necessary for replication
- `FLUSH PRIVILEGES;` reloads the privilege tables to ensure that the new user and privileges take effect immediately

```sql
SHOW MASTER STATUS\G
```

- Displays the current status of the binary log on the source server
    - The `\G` at the end formats the output vertically for better readability

### `setup-replica.sh`

```sql
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql-source',
  SOURCE_USER='repluser',
  SOURCE_PASSWORD='repluser',
  SOURCE_LOG_FILE='mysql-bin.000003',
  SOURCE_LOG_POS=157;
```

- Configures the replica to connect to the source server
    - `SOURCE_HOST`: The hostname or IP address of the source server
    - `SOURCE_USER`: The username that the replica will use to connect to the source server
    - `SOURCE_PASSWORD`: The password for the replication USER
    - `SOURCE_LOG_FILE`: The name of the binary log file from which the replica should start reading, typically obtained from the `SHOW MASTER STATUS` command on the source server
    - `SOURCE_LOG_POS`: The position within the binary log file from which to start reading, also obtained from the `SHOW MASTER STATUS` command on the source server
