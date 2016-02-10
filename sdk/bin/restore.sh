#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CURRENT_DIR=$(pwd)

SETTINGS_FILE=$CURRENT_DIR/settings.sh

# LOAD THE APPROPRIATE ENVIRONMENT SETTINGS
if ! [ -f $SETTINGS_FILE ]; then
    echo "Expected to find a settings file, but did not.  Are you running this from a valid environment directory?"
    exit 1
fi
source $SETTINGS_FILE
source $SDK_DIR/bin/functions.sh

# Read in / update backup settings

readInput BU_SERVER "Backup Server" "$BACKUP_SERVER"
readInput BU_FOLDER "Backup Folder" "$BACKUP_FOLDER"
readInput BU_FILENAME "Backup Filename" "$BACKUP_FILE"


replaceStringInFile "<BACKUP_SERVER>" "$BU_SERVER" "$SETTINGS_FILE"
replaceStringInFile "<BACKUP_FOLDER>" "$BU_FOLDER" "$SETTINGS_FILE"
replaceStringInFile "<BACKUP_FILE>" "$BU_FILENAME" "$SETTINGS_FILE"
replaceStringInFile "BACKUP_SERVER=$BACKUP_SERVER" "BACKUP_SERVER=$BU_SERVER" "$SETTINGS_FILE"
replaceStringInFile "BACKUP_FOLDER=$BACKUP_FOLDER" "BACKUP_FOLDER=$BU_FOLDER" "$SETTINGS_FILE"
replaceStringInFile "BACKUP_FILE=$BACKUP_FILE" "BACKUP_FILE=$BU_FILENAME" "$SETTINGS_FILE"


WORKING_DIR=$BASE_DIR/temp
rm -fR $WORKING_DIR
mkdir $WORKING_DIR
cd $WORKING_DIR

# Get backup
scp $BU_SERVER:$BU_FOLDER/$BU_FILENAME .

# Extract to openmrs.sql
7za x -so $BU_FILENAME | tar xf -
mv *.sql openmrs.sql

# Drop existing DB

if mysql -u root -proot -e "use $DB_NAME" ; then
  mysql -u root -proot -e "drop database $DB_NAME;"
fi

# Source new DB
mysql -u root -proot -e "create database $DB_NAME default charset utf8; grant all privileges on $DB_NAME.* to openmrs; use $DB_NAME; source openmrs.sql;"

# Remove artifacts
rm -fR $WORKING_DIR