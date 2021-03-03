#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

RETURN_CODE=0

OPERATION=""
SERVER_ID=""
REMOTE_HOST=""
BUILD_ARGS=""

function usage() {
  echo "USAGE:"
  echo "remote-dev --remoteHost=mytestserver.org --operation=buildDeploy --buildArgs=-DskipTests --serverId=myserver"
}

function syncFolder() {
  FOLDER=$(pwd)
  ssh $REMOTE_HOST "mkdir -p $FOLDER"
  rsync -azP --delete ${FOLDER}/ ${REMOTE_HOST}:${FOLDER}/
}

function runCommand() {
  FOLDER=$(pwd)
  ssh $REMOTE_HOST "cd $FOLDER && $@"
}

function mvnBuild() {
  runCommand "mvn clean install $BUILD_ARGS"
}

function deployModule() {
  runCommand "mvn openmrs-sdk:deploy -DserverId=$SERVER_ID -DbatchAnswers=y"
}

function deployConfig() {
  runCommand "mvn clean compile -DserverId=$SERVER_ID"
}

function deployDistro() {
  runCommand "mvn clean install && mvn openmrs-sdk:deploy -DserverId=$SERVER_ID -Ddistro=api/src/main/resources/openmrs-distro.properties -U"
}

function createServer() {
  runCommand "mvn openmrs-sdk:setup -DserverId=$SERVER_ID -Ddistro=org.openmrs.module:mirebalais:1.3.0-SNAPSHOT -DjavaHome=/usr/lib/jvm/java-8-openjdk-amd64 -DbatchAnswers='8080,5000,MySQL 5.6 in SDK docker container (requires pre-installed Docker)'"
}

echo "Parsing input arguments"

for i in "$@"
do
case $i in
    --operation=*)
      OPERATION="${i#*=}"
      shift # past argument=value
    ;;
    --serverId=*)
      SERVER_ID="${i#*=}"
      shift # past argument=value
    ;;
    --remoteHost=*)
      REMOTE_HOST="${i#*=}"
      shift # past argument=value
    ;;
    --buildArgs=*)
      BUILD_ARGS="${i#*=}"
      shift # past argument=value
    ;;
    *)
      usage    # unknown option
      exit 1
    ;;
esac
done

if [ -z $REMOTE_HOST ]; then
  usage
  exit 1
fi

if [ -z $OPERATION ]; then
  usage
  exit 1
fi

if [ -z $SERVER_ID ]; then
  usage
  exit 1
fi

echo "Executing $OPERATION on remote server"

case $OPERATION in
    "mvnBuild")
      syncFolder
      mvnBuild
    ;;
    "deployModule")
      syncFolder
      mvnBuild
      deployModule
    ;;
    "deployConfig")
      if [[ -d '../openmrs-config-pihemr' ]]; then
        (cd "../openmrs-config-pihemr" && syncFolder)
        mvnBuild "-f ../openmrs-config-pihemr/pom.xml"
      fi
      syncFolder
      mvnBuild
      deployConfig
    ;;
    "updateDistro")
      syncFolder
      mvnBuild
      deployDistro
    ;;
    "createServer")
      createServer
    ;;
    *)
      echo "Unknown command"
      exit 1
    ;;
esac

