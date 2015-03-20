#!/bin/bash

# RECORD DIRECTORY THAT THIS SCRIPT IS RUN FROM, AS ALL OTHER INSTALLATION ARTIFACTS WILL BE CONSIDERED RELATIVE TO IT
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

read -e -p "Base directory:  " -i "$(pwd)" BASE_DIR
read -e -p "Name of environment (eg. zlemr, mirebalais):  " ENV_NAME
read -e -p "Tomcat HTTP port:  " -i "8080" TOMCAT_HTTP_PORT
read -e -p "Tomcat Shutdown port:  " -i "8005" TOMCAT_SHUTDOWN_PORT
read -e -p "Tomcat Debug port:  " -i "5000" DEBUG_PORT

echo "Initializing new environment at: $BASE_DIR/$ENV_NAME"
cd $BASE_DIR
mkdir $ENV_NAME
cd $ENV_NAME
ENV_DIR=$BASE_DIR/$ENV_NAME

# CREATE HELPER FUNCTIONS

replaceStringInFile() {
  local OLD_STR=$1
  local NEW_STR=$2
  local FILE_NAME=$3
  sed -i -e "s|$OLD_STR|$NEW_STR|g" $FILE_NAME
}

installFileFromTemplate() {
  local FILE_NAME=$1
  local DESTINATION_DIR=$2
  local DESTINATION_FILE=$DESTINATION_DIR/$FILE_NAME
  echo "Installing $FILE_NAME at $DESTINATION_FILE"
  cp $SCRIPT_DIR/../templates/$FILE_NAME $DESTINATION_DIR
  replaceStringInFile "<ENV_DIR>" "$ENV_DIR" "$DESTINATION_FILE"
  replaceStringInFile "<ENV_NAME>" "$ENV_NAME" "$DESTINATION_FILE"
  replaceStringInFile "<TOMCAT_SHUTDOWN_PORT>" "$TOMCAT_SHUTDOWN_PORT" "$DESTINATION_FILE"
  replaceStringInFile "<TOMCAT_HTTP_PORT>" "$TOMCAT_HTTP_PORT" "$DESTINATION_FILE"
  replaceStringInFile "<DEBUG_PORT>" "$DEBUG_PORT" "$DESTINATION_FILE"
}

createDatabase() {
  local DB_NAME=$1
  echo "Creating a new database named $DB_NAME"
  mysql -u root -proot -e "create database $DB_NAME default charset utf8; grant all privileges on $DB_NAME.* to openmrs; use $DB_NAME;"
  mysql -u openmrs -popenmrs $DB_NAME < $SCRIPT_DIR/../databases/openmrs-1.9.sql
}

# INSTALL TOMCAT

echo "Installing tomcat with ports for http: $TOMCAT_HTTP_PORT, shutdown: $TOMCAT_SHUTDOWN_PORT, debug: $DEBUG_PORT"
tomcat7-instance-create tomcat
installFileFromTemplate server.xml $ENV_DIR/tomcat/conf
installFileFromTemplate setenv.sh $ENV_DIR/tomcat/bin
installFileFromTemplate startup.sh $ENV_DIR/tomcat/bin
installFileFromTemplate shutdown.sh $ENV_DIR/tomcat/bin

# INSTALL MYSQL

echo "Starting Database Setup"
DB_NAME="openmrs_$ENV_NAME"

if mysql -u root -proot -e "use $DB_NAME" ; then
  while true; do
    read -p "A database named $DB_NAME already exists.  Do you wish to drop and re-create it? " -i "y" RECREATE_DB
    case $RECREATE_DB in
        [Yy]* )
          echo "Dropping existing $DB_NAME database"
          mysql -u root -proot -e "drop database $DB_NAME;"
          createDatabase $DB_NAME
          break;;
        [Nn]* )
          break;;
        * )
        echo "Please answer yes or no.";;
    esac
  done
else
  createDatabase $DB_NAME
fi

# INSTALL OPENMRS

cd $ENV_DIR
mkdir openmrs
installFileFromTemplate openmrs-runtime.properties $ENV_DIR
installFileFromTemplate feature_toggles.properties $ENV_DIR

# TODO: Generalize this to pull war for this environment via a configuration file
echo "Installing WAR file"
$SCRIPT_DIR/build.sh /home/mseaton/code openmrs-1.9.x
