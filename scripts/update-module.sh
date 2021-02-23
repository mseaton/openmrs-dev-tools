#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

RETURN_CODE=0

PROJECT_DIR=""
REMOTE_HOST=""
SERVER_ID=""

function usage() {
  echo "USAGE:"
  echo "update-module --projectDir=/my/local/project/with/pom --remoteHost=mytestserver.org --serverId=myserver"
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

echo "Build the module"
mvn clean install -f $PROJECT_DIR/pom.xml

echo "Replacing the module"
rsync -azP $PROJECT_DIR/omod/target/*.omod $SERVER_DIR/modules/
