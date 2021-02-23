#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

RETURN_CODE=0

OPERATION=""
SERVER_ID=""
REMOTE_HOST=""

function usage() {
  echo "USAGE:"
  echo "remote-dev --remoteHost=mytestserver.org --operation=buildDeploy --serverId=myserver"
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

echo "Syncing this folder with the remote server"
syncFolder

echo "Executing $OPERATION on remote server"

case $OPERATION in
    "buildDeploy")
      runCommand "mvn clean install && mvn openmrs-sdk:deploy -DserverId=$SERVER_ID"
    ;;
    *)
      echo "Unknown command"
      exit 1
    ;;
esac

