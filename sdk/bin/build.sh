#!/bin/bash

CURRENT_DIR=$(pwd)

BASE_DIR=$1
ARTIFACT_NAME=$2

CODE_DIR=$BASE_DIR/$ARTIFACT_NAME

if [ -d $CODE_DIR ];
then
  cd $CODE_DIR
  git stash
  git pull --rebase
  git stash pop
  mvn clean install -DskipTests
  cd $CURRENT_DIR
else
   echo "Unable to find code at $CODE_DIR"
fi

if [ -f $CODE_DIR/webapp/target/openmrs.war ]
  then
    WEBAPP_DIR=$PWD/tomcat/webapps
    cp $CODE_DIR/webapp/target/openmrs.war $WEBAPP_DIR/openmrs.war
    echo "$ARTIFACT_NAME BUILT AND DEPLOYED TO $WEBAPP_DIR"
  else
    MODULE_DIR=$PWD/openmrs/modules
    rm -f $MODULE_DIR/$ARTIFACT_NAME-*.omod
    cp $CODE_DIR/omod/target/*.omod $MODULE_DIR
    echo "$ARTIFACT_NAME MODULE BUILT AND DEPLOYED TO $MODULE_DIR"
fi
