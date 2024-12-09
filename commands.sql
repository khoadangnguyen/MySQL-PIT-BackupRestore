-- Start MySQL Docker container
docker-compose up

-- Connect MySQL server
/opt/homebrew/opt/mysql-client/bin/mysql -h 127.0.0.1 -P 3306 -u root -p

-- with MySQL Docker container, binary logging is enabled by default
-- Double check if binary logging is enabled
SHOW VARIABLES LIKE 'log_bin';
-- Show the base name and path for the binary log files
SHOW VARIABLES LIKE 'log_bin_basename';
-- Displays a list of all binary log files currently available
SHOW BINARY LOGS;

-- Create database and populate data
CREATE DATABASE world;

USE world;

SOURCE world_mysql_script.sql;

-- List all the table names from the world database
SHOW TABLES;

-- Retrieve all records from the countrylanguage table where the countrycode is ‘CAN’
-- Empty set is returned
SELECT * FROM countrylanguage WHERE countrycode='CAN';

-- Run the update script (world_mysql_update_A.sql) to insert the records
SOURCE world_mysql_update_A.sql;

-- Verify the insertion of Canada-related records
SELECT * FROM countrylanguage WHERE countrycode='CAN';

-- Create a full logical backup of the current state of my world database
-- --flush-logs: Flush the MySQL server log files before starting the dump
-- https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html#option_mysqldump_flush-logs
mysqldump -h 127.0.0.1 -P 3306 --user=root --password --flush-logs --databases world > world_mysql_full_backup.sql

-- Retrieve all records from the city table where the countrycode is ‘CAN’
-- Empty set is returned
SELECT * FROM city WHERE countrycode='CAN';

-- This means Canada related records are currently absent from the table.
-- Run the update script (world_mysql_update_B.sql) to insert the records I was looking for
-- Note: record local time zone before executing so that later I can use it to perform point-in-time recovery
SOURCE world_mysql_update_B.sql;

-- Verify the insertion of Canada-related records
SELECT * FROM city WHERE countrycode='CAN';

-- Stop MySQL Docker container
docker-compose down

-- Remove data from world database folder to simulate data loss
sudo rm -rf ./mysql-data/world

-- Retrieve records from any table of the database
-- No result will be retrieved
mysql -h 127.0.0.1 -P 3306 --user=root --password --execute="SELECT * FROM world.city;"

-- Now start restoring the database
-- Display the binary logs
mysql -h 127.0.0.1 -P 3306 --user=root --password --execute="SHOW BINARY LOGS;"

-- Write the contents of all binary log files listed above to a single file
-- utilizing --start-datetime config
-- https://dev.mysql.com/doc/refman/8.4/en/mysqlbinlog.html#option_mysqlbinlog_start-datetime
mysqlbinlog --start-datetime="yyyy-MM-dd hh:mm:ss" ./mysql-data/binlog.xxxxxx ./mysql-data/binlog.xxxxxy > binlogfile.sql

-- Perform point-in-time recovery
-- Restore the full logical backup of whole world database
mysql -h 127.0.0.1 -P 3306 --user=root --password < world_mysql_full_backup.sql

-- Verify if you have the updates from the update script (world_mysql_update_B.sql),
-- retrieve all the Canada (countrycode=’CAN’) related records from the city table
mysql -h 127.0.0.1 -P 3306 --user=root --password --execute="SELECT * FROM world.city WHERE countrycode='CAN';"

-- Execute the sql file generated from binary log
mysql -h 127.0.0.1 -P 3306 --user=root --password < binlogfile.sql

-- Re-verify if I have the updates from the update script (world_mysql_update_B.sql)
mysql -h 127.0.0.1 -P 3306 --user=root --password --execute="SELECT * FROM world.city WHERE countrycode='CAN';"