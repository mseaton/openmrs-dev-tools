#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CURRENT_DIR=$(pwd)

# LOAD THE APPROPRIATE ENVIRONMENT SETTINGS
if ! [ -f $CURRENT_DIR/settings.sh ]; then
    echo "Expected to find a settings file, but did not.  Are you running this from a valid environment directory?"
    exit 1
fi
source $CURRENT_DIR/settings.sh
source $SDK_DIR/bin/functions.sh

echo "##### ENVIRONMENT SETTINGS #####"
echo ""
echo "Environment Name:  $ENV_NAME"
echo "Database Name: $DB_NAME"
echo "Distribution: $DISTRIBUTION_NAME"
if [ $DISTRIBUTION_MODULE ]; then
    echo "Distribution Module: $DISTRIBUTION_MODULE"
fi
echo ""
echo "Source for Core: $SOURCE_FOLDER/$CORE_PROJECT"
if [ $MODULE_PROJECT_FORMAT == "moduleid" ]; then
    echo "Source for Modules: $SOURCE_FOLDER/<moduleId>"
else
    echo "Source for Modules: $SOURCE_FOLDER/openmrs-module-<moduleId>"
fi
echo ""
echo "HTTP Port: $TOMCAT_HTTP_PORT"
echo "Shutdown Port: $TOMCAT_SHUTDOWN_PORT"
echo "Debug Port: $DEBUG_PORT"
echo ""
echo "##### TOMCAT STATUS #####"
echo ""
TOMCAT_PS=$(tomcatProcess)
if [ $TOMCAT_PS ]; then
    echo "Started.  Pid: $TOMCAT_PS"
else
    echo "Stopped."
fi
echo ""
