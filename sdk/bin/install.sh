#!/bin/bash

# RECORD DIRECTORY THAT THIS SCRIPT IS RUN FROM, AS ALL OTHER INSTALLATION ARTIFACTS WILL BE CONSIDERED RELATIVE TO IT
SDK_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..
source $SDK_DIR/bin/functions.sh

# READ INPUT VARIABLES FROM USER

readFolderInput         BASE_DIR                "Installation directory" "$(pwd)"
readEnvironment         ENV_NAME                $BASE_DIR
readInput               DB_NAME                 "Database name" "openmrs_$ENV_NAME"
readFolderInput         SOURCE_FOLDER           "Source folder" "$HOME/code"
readInput               CORE_PROJECT            "Core Project" "openmrs-1.9.x"
readProjectFormatInput  MODULE_PROJECT_FORMAT   "Module project format (github, moduleid)" "moduleid" "github"
readInput               DISTRIBUTION_MODULE     "Distribution Module ID"
readInput               TOMCAT_HTTP_PORT        "Tomcat HTTP port" "8080"
readInput               TOMCAT_SHUTDOWN_PORT    "Tomcat Shutdown port" "8005"
readInput               DEBUG_PORT              "Tomcat Debug port" "5000"

# START INSTALLATION

ENV_DIR=$BASE_DIR/$ENV_NAME
echo "Initializing new environment at: $ENV_DIR"
mkdir $ENV_DIR
cd $ENV_DIR

# SAVE CONFIGURATION

installFileFromTemplate settings.sh $ENV_DIR

# INSTALL TOMCAT

echo "Installing tomcat with ports for http: $TOMCAT_HTTP_PORT, shutdown: $TOMCAT_SHUTDOWN_PORT, debug: $DEBUG_PORT"
tomcat7-instance-create tomcat
installFileFromTemplate server.xml $ENV_DIR/tomcat/conf
installFileFromTemplate setenv.sh $ENV_DIR/tomcat/bin
installFileFromTemplate startup.sh $ENV_DIR/tomcat/bin
installFileFromTemplate shutdown.sh $ENV_DIR/tomcat/bin

# INSTALL MYSQL

echo "Starting Database Setup"

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
        [Qq]* )
          exit 1;;
        * )
        echo "Please answer yes, no, or quit.";;
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
mkdir $ENV_DIR/openmrs/modules

echo "Installing WAR file"
$SDK_DIR/bin/build.sh "$CORE_PROJECT"

if [ $DISTRIBUTION_MODULE ]; then
    echo "Installing '$DISTRIBUTION_MODULE' distribution"
    $SDK_DIR/bin/build.sh "$DISTRIBUTION_MODULE" "distribution"
fi

echo "$ENV_NAME INSTALLATION COMPLETED."