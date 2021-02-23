#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

RETURN_CODE=0

PROJECT_DIR=""
REMOTE_HOST=""
SERVER_ID=""

function usage() {
  echo "USAGE:"
  echo "update-distribution --projectDir=/my/local/project/with/pom --remoteHost=mytestserver.org --serverId=myserver"
}

echo "Parsing input arguments"

for i in "$@"
do
case $i in
    --projectDir=*)
      PROJECT_DIR="${i#*=}"
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
    *)
      usage    # unknown option
      exit 1
    ;;
esac
done

if [ -z $PROJECT_DIR ]; then
  usage
  exit 1
fi

if [ -z $SERVER_ID ]; then
  usage
  exit 1
fi

SERVER_DIR=~/openmrs/$SERVER_ID
if [ -z $REMOTE_HOST ]; then
  echo "No remote host specified, deploying to local server"
else
  echo "Deploying to remote server: $REMOTE_HOST"
  SERVER_DIR="$REMOTE_HOST:$SERVER_DIR"
fi

echo "Build the distro"
mvn clean install -f $PROJECT_DIR/pom.xml

echo "Replacing war"
rsync -avzP $PROJECT_DIR/target/distro/web/openmrs.war $SERVER_DIR/openmrs-2.3.3-SNAPSHOT.war

echo "Replacing the modules"
rsync -azP --delete $PROJECT_DIR/target/distro/web/modules $SERVER_DIR

echo "Replacing the owas"
rsync -azP --delete $PROJECT_DIR/target/distro/web/owa $SERVER_DIR

echo "Replacing the config"
rsync -azP --delete $PROJECT_DIR/target/configuration $SERVER_DIR


