#!/bin/bash

# DEFINE AND READ IN PARAMETERS

PROJECT=$1
RUN_TESTS=$2
CURRENT_DIR=$(pwd)

# LOAD THE APPROPRIATE ENVIRONMENT SETTINGS
if ! [ -f $CURRENT_DIR/settings.sh ]; then
    echo "Expected to find a settings file, but did not.  Are you running this from a valid environment directory?"
    exit 1
fi
source $CURRENT_DIR/settings.sh

# SUPPORT BUILDING PROJECT WITH VARIATION OF openmrs-module-foomodule AND foomodule
CODE_DIR=$SOURCE_FOLDER/$PROJECT
if [ "$MODULE_PROJECT_FORMAT" == 'github' ]; then
    CODE_DIR=$SOURCE_FOLDER/openmrs-module-$PROJECT
fi

# VALIDATE THAT THIS SEEMS LIKE A LEGITIMATE PROJECT TO BUILD
if ! [ -f $CODE_DIR/pom.xml ]; then
    echo "Unable to locate a valid source directory at $CODE_DIR.  Expected to find pom.xml but did not."
    exit 1
fi

# UPDATE FROM GITHUB IF NECESSARY
cd $CODE_DIR
git stash
git pull --rebase
git stash pop
if [ "$RUN_TESTS" == "true" ];  then
    mvn clean install
else
    mvn clean install -DskipTests
fi
cd $CURRENT_DIR

if [ -f $CODE_DIR/webapp/target/openmrs.war ]
then
    WEBAPP_DIR=$PWD/tomcat/webapps
    cp $CODE_DIR/webapp/target/openmrs.war $WEBAPP_DIR/openmrs.war
    echo "$PROJECT BUILT AND DEPLOYED TO $WEBAPP_DIR"
else
    MODULE_DIR=$PWD/openmrs/modules
    rm -f $MODULE_DIR/$ARTIFACT_NAME-*.omod
    cp $CODE_DIR/omod/target/*.omod $MODULE_DIR
    echo "$PROJECT MODULE BUILT AND DEPLOYED TO $MODULE_DIR"
fi
