#!/bin/bash

if [ -z "$1" ]
then
  echo "Please specify the project you wish to build"
  exit 1
fi

# DEFINE AND READ IN PARAMETERS
CURRENT_DIR=$(pwd)
PROJECT=$1

echo "Building $1"

# Supported additional arguments include:
# test - if specified, will include running tests (default is to skip tests)
# distribution - if specified, will run with distribution profile and deploy new version of all modules in distribution
# force - if a build and update should be forced even if no changes are detected

TEST="f"
DISTRIBUTION="f"
FORCE_BUILD="f"

for arg in "${@:2}"; do
    if [ $arg == "test" ]; then
        TEST="t"
    elif [ $arg == "distribution" ]; then
        DISTRIBUTION="t"
        FORCE_BUILD="t"
    elif [ $arg == "force" ]; then
        FORCE_BUILD="t"
    else
        "Echo unknown argument of $arg specified"
    fi
done

# LOAD THE APPROPRIATE ENVIRONMENT SETTINGS
if ! [ -f $CURRENT_DIR/settings.sh ]; then
    echo "Expected to find a settings file, but did not.  Are you running this from a valid environment directory?"
    exit 1
fi
source $CURRENT_DIR/settings.sh
source $SDK_DIR/bin/functions.sh

# SUPPORT BUILDING PROJECT WITH VARIATION OF openmrs-module-foomodule AND foomodule
CODE_DIR=$SOURCE_FOLDER/$PROJECT
if [ "$MODULE_PROJECT_FORMAT" == 'github' ]; then
    CODE_DIR=$SOURCE_FOLDER/openmrs-module-$PROJECT
fi

# VALIDATE THAT THIS SEEMS LIKE A LEGITIMATE PROJECT TO BUILD
if ! [ -d $CODE_DIR/.git ]; then
    echo "This is not a git project.  Exiting build."
    exit 1
fi

# VALIDATE THAT THIS SEEMS LIKE A LEGITIMATE PROJECT TO BUILD
if ! [ -f $CODE_DIR/pom.xml ]; then
    echo "Unable to locate a valid source directory at $CODE_DIR.  Expected to find pom.xml but did not."
    exit 1
fi

# DETERMINE BUILD IS EVEN NECESSARY

cd $CODE_DIR

PERFORM_BUILD='f'
GIT_STATUS=$(gitStatus)

if [ $GIT_STATUS != 'NO_CHANGES' ]; then
    echo "Building code: git reports $GIT_STATUS"
    PERFORM_BUILD='t'
else
    if [ ! -d $CODE_DIR/webapp/target ] && [ ! -d $CODE_DIR/omod/target ]; then
        echo "Building code: no existing built artifact is found"
        PERFORM_BUILD='t'
    else
        if [ $FORCE_BUILD == 't' ]; then
            echo "Building code: forced"
            PERFORM_BUILD='t'
        fi
    fi
fi

if [ $PERFORM_BUILD == 't' ]; then

    # UPDATE FROM GITHUB IF NECESSARY

    git stash
    git pull --rebase
    git stash pop

    # BUILD WITH MAVEN
    MVN_CMD="mvn clean install"
    if [ "$TEST" != "t" ];  then
        MVN_CMD="$MVN_CMD -DskipTests"
    fi
    if [ "$DISTRIBUTION" == "t" ];  then
        MVN_CMD="$MVN_CMD -Pdistribution"
    fi
    eval "$MVN_CMD"

else
    echo "Code up-to-date and existing build artifact found.  Deploying existing artifact."
fi

cd $CURRENT_DIR

if [ -f $CODE_DIR/webapp/target/openmrs.war ]
then
    WEBAPP_DIR=$PWD/tomcat/webapps
    cp $CODE_DIR/webapp/target/openmrs.war $WEBAPP_DIR/openmrs.war
    echo "$PROJECT BUILT AND DEPLOYED TO $WEBAPP_DIR"
else
    MODULE_DIR=$PWD/openmrs/modules
    if [ "$DISTRIBUTION" == "t" ];  then
        rm -f $MODULE_DIR/*.omod
        cp $CODE_DIR/distro/target/distro/*.omod $MODULE_DIR
        echo "$PROJECT DISTRIBUTION BUILT AND DEPLOYED TO $MODULE_DIR"
    else
        rm -f $MODULE_DIR/$PROJECT-*.omod
        cp $CODE_DIR/omod/target/*.omod $MODULE_DIR
        echo "$PROJECT MODULE BUILT AND DEPLOYED TO $MODULE_DIR"
    fi
fi
