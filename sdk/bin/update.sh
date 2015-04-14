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

# Iterate over modules, update all code from github, and rebuild if necessary. This is to bring codebase all up to date
for moduleFile in $CURRENT_DIR/openmrs/modules/*
do
    moduleAndVersion=$(basename $moduleFile)
    dashIndex=$(expr index "$moduleAndVersion" '-')
    moduleId=${moduleAndVersion:0:dashIndex-1}
    echo "Updating $moduleId"
    $SCRIPT_DIR/build.sh "$moduleId" "nodeploy"
done

# Update distribution if there is one
if [ $DISTRIBUTION_MODULE ]; then
    echo "Updating distribution modules"
    $SDK_DIR/bin/build.sh $DISTRIBUTION_MODULE "distribution"
fi
