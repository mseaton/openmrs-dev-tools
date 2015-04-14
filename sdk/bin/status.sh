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
cat $CURRENT_DIR/settings.sh