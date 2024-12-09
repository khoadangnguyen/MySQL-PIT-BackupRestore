#!/bin/bash

if [ -z "$1" ]; then
  echo "ERROR: No database name provided. Please pass a database name as 1st parameter."
  exit 1
fi
databaseName="$1"

if [ -z "$2" ]; then
  echo "ERROR: No file name provided. Please pass a backup file as 2nd parameter."
  exit 1
fi
fileName="$2"

if [ ! -f "${fileName}" ]; then
  echo "ERROR: File ${fileName} does not exist. Please provide existed backup file as 2nd parameter."
  exit 1
fi

if [ ! -r "${fileName}" ]; then
  echo "ERROR: Cannot read ${fileName}. Please make sure file is readable."
  exit 1
fi

echo "Create database ${databaseName}"
/opt/homebrew/opt/mysql-client/bin/mysql -e "CREATE DATABASE IF NOT EXISTS ${databaseName};"

if [ $? -eq 0 ]; then
  echo "Database ${databaseName} created successfully or already exists"
else
  echo "Failed to create database ${databaseName}"
  exit 1
fi

echo "Restore data from ${fileName} to database ${databaseName}"
/opt/homebrew/opt/mysql-client/bin/mysql "${databaseName}" < "${fileName}"

if [ $? -eq 0 ]; then
  echo "Database ${databaseName} restored successfully from ${fileName}"
else
  echo "Failed to create database ${databaseName}"
  exit 1
fi