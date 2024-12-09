#!/bin/sh

# Check if database name is provided
databaseName=""
if [ -z "$1" ]; then
  echo "ERROR: No database name was provided. Please pass a database name as 1st parameter."
  exit 1
else
  databaseName="$1"
  echo "Back up database name: $databaseName"
fi

dir=$(pwd)
# Check if directory is provided
if [ -z "$2" ]; then
  echo "No directory is specified. Use current directory: $dir"
else
  dir="$2"
  echo "Use directory: $dir"
fi

if [ ! -d "$dir" ]; then
  echo "ERROR: Directory does not exist. Please enter existing directory."
  exit 1
fi

if [ ! -w "$dir" ]; then
  echo "ERROR: Directory is not writable. Please make sure directory is writeable."
  exit 1
fi

timestamp=$(date +%Y%m%d%H%M%S)
sql_file="${dir}/${databaseName}_${timestamp}.sql"
echo "Backup to: $sql_file"

/opt/homebrew/opt/mysql-client/bin/mysqldump "$databaseName" > "$sql_file"

if [ $? -eq 0 ]; then
    echo "Backup successful!"
else
    echo "Backup failed!"
fi