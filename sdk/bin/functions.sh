#!/bin/bash

# Returns 0 if first argument exists in any of the subsequent arguments 2-N
# Returns 1 if first argument is not found
function containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# Reads user input from the command line.
# Arguments:
#   1. Variable name to set
#   2. Question to ask
#   3. Default value
# Usage:
#   readInput WEATHER "How is the weather?" "Sunny"
function readInput() {
    local result
    read -e -p "$2:  " -i "$3" result
    eval $1="'$result'"
}

# Reads user input from the command line when one of a set of coded values is allowed.
# Arguments:
#   1. Variable name to set
#   2. Question to ask
#   3. Default value
#   4-N. Other allowed values
# Usage:
#   readCodedInput WEATHER "How is the weather?" "Sunny", "Snowy", "Rainy", "Windy"
function readProjectFormatInput() {
    local result
    read -e -p "$2:  " -i "$3" result
    while [ "$result" != "moduleid" ] && [ "$result" != "github" ]; do
        read -e -p "Please specify either 'moduleid' or 'github':  " result
    done
    eval $1="'$result'"
}

# Reads user input from the command line when the path of a folder is expected, promting user if they want to create the folder if it does not yet exist
# Arguments:
#   1. Variable name to set
#   2. Question to ask
#   3. Default value
# Usage:
#   readFolderInput INSTALL_DIR "What is the installation directory?" "$HOME"
function readFolderInput() {
    read -e -p "$2:  " -i "$3" result
    if ! [ -d "$result" ]; then
        while true; do
            read -e -p "Specified directory $result does not exist.  Do you wish to create it?  " -i "y" CREATE_FOLDER
            case CREATE_FOLDER in
                [Yy]* )
                  mkdir $result
                  break;;
                [Nn]* )
                  echo "Exiting installation"
                  exit 1;;
                * )
                echo "Please answer yes or no.";;
            esac
        done
    fi
    eval $1="'$result'"
}

# Reads user input for the name a new environment, validating that it does not yet exist
# Arguments:
#   1. Variable name to set
#   2. Base folder to check for existing environments
# Usage:
#   readEnvironment ENV_NAME "Name of environment?"
function readEnvironment() {
    read -e -p "Name of environment (eg. zlemr, mirebalais):  " result
    while [ -d "$2/$result" ]; do
        read -e -p "This environment already exists, enter a new name:  " result
    done
    eval $1="'$result'"
}

# Replace all occurrances of arg 1 with arg 2 in file at path arg 3
# Argument 1: The text you wish to replace
# Argument 2: The text you wish to replace with
# Argument 3, the filename you wish to replace within
replaceStringInFile() {
  local OLD_STR=$1
  local NEW_STR=$2
  local FILE_NAME=$3
  sed -i -e "s|$OLD_STR|$NEW_STR|g" $FILE_NAME
}

# This function can only be run if the context of environment variables being set
# For file at path arg1, copy to path at arg2, replacing all occurrances of <VARIABLE> with the value of that variable
installFileFromTemplate() {
  local FILE_NAME=$1
  local DESTINATION_DIR=$2
  local DESTINATION_FILE=$DESTINATION_DIR/$FILE_NAME
  echo "Installing $FILE_NAME at $DESTINATION_FILE"
  cp $SDK_DIR/templates/$FILE_NAME $DESTINATION_DIR/$FILE_NAME
  replaceStringInFile "<SDK_DIR>" "$SDK_DIR" "$DESTINATION_FILE"
  replaceStringInFile "<BASE_DIR>" "$BASE_DIR" "$DESTINATION_FILE"
  replaceStringInFile "<ENV_DIR>" "$ENV_DIR" "$DESTINATION_FILE"
  replaceStringInFile "<ENV_NAME>" "$ENV_NAME" "$DESTINATION_FILE"
  replaceStringInFile "<DB_NAME>" "$DB_NAME" "$DESTINATION_FILE"
  replaceStringInFile "<SOURCE_FOLDER>" "$SOURCE_FOLDER" "$DESTINATION_FILE"
  replaceStringInFile "<CORE_PROJECT>" "$CORE_PROJECT" "$DESTINATION_FILE"
  replaceStringInFile "<DISTRIBUTION_MODULE>" "$DISTRIBUTION_MODULE" "$DESTINATION_FILE"
  replaceStringInFile "<MODULE_PROJECT_FORMAT>" "$MODULE_PROJECT_FORMAT" "$DESTINATION_FILE"
  replaceStringInFile "<TOMCAT_HTTP_PORT>" "$TOMCAT_HTTP_PORT" "$DESTINATION_FILE"
  replaceStringInFile "<TOMCAT_SHUTDOWN_PORT>" "$TOMCAT_SHUTDOWN_PORT" "$DESTINATION_FILE"
  replaceStringInFile "<DEBUG_PORT>" "$DEBUG_PORT" "$DESTINATION_FILE"
}

# Creates a new database with name passed in as arg1, and initializes this with base 1.9 schema, and user admin/Admin123
createDatabase() {
  local DB_NAME=$1
  echo "Creating a new database named $DB_NAME"
  mysql -u root -proot -e "create database $DB_NAME default charset utf8; grant all privileges on $DB_NAME.* to openmrs; use $DB_NAME;"
  mysql -u openmrs -popenmrs $DB_NAME < $SDK_DIR/databases/openmrs-1.9.sql
}

gitCurrentBranch() {
    echo $(git rev-parse --abbrev-ref HEAD)
}

gitStatus() {
    local REMOTE_REV=$(git rev-parse @{u})
    local BASE_REV=$(git merge-base @ @{u})
    local MY_REV=$(git rev-parse @)
    local MY_STATUS=$(git status --porcelain)

    if [ $MY_REV = $REMOTE_REV ]; then
        if [ -z "$MY_STATUS" ]; then
            echo "NO_CHANGES"
        else
            echo "NEED_TO_COMMIT"
        fi
    elif [ $MINE = $BASE ]; then
        echo "NEED_TO_PULL"
    elif [ $REMOTE = $BASE ]; then
        echo "NEED_TO_PUSH"
    else
        echo "DIVERGED"
    fi
}
