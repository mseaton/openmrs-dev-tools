#!/bin/bash

if [ -z "$1" ]
then
  echo "Please specify the project you wish to build"
  exit 1
fi

PROJECT=$1

echo "Building $1"

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CURRENT_DIR=$(pwd)

# LOAD THE APPROPRIATE ENVIRONMENT SETTINGS
if ! [ -f $CURRENT_DIR/settings.sh ]; then
    echo "Expected to find a settings file, but did not.  Are you running this from a valid environment directory?"
    exit 1
fi
source $CURRENT_DIR/settings.sh
source $SDK_DIR/bin/functions.sh

FROM_DIR="$SOURCE_FOLDER/$PROJECT/omod/src/main/webapp"
TO_DIR="$CURRENT_DIR/tomcat/webapps/openmrs/WEB-INF/view/module/$PROJECT"

if [ ! -d "$FROM_DIR" ]; then
	echo "Cannot find source directory $FROM_DIR"
	exit
fi

if [ ! -d "$TO_DIR" ]; then
	echo "Cannot find target directory $TO_DIR"
	exit
fi

echo "Copying from $FROM_DIR to $TO_DIR"
rsync -av --exclude=*/.svn* $FROM_DIR/* $TO_DIR
