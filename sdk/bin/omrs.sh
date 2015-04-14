#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

case $1 in
install)
  $SCRIPT_DIR/install.sh
  ;;
start)
  ./tomcat/bin/startup.sh
  ;;
stop)
  ./tomcat/bin/shutdown.sh
  ;;
log)
  tail -f ./tomcat/logs/catalina.out
  ;;
build)
  $SCRIPT_DIR/build.sh "${@:2}"
  ;;
test)
  $SCRIPT_DIR/build.sh "${@:2}" "test" "force"
  ;;
distribution)
  $SCRIPT_DIR/build.sh "${@:2}" "distribution" "force"
  ;;
update)
  $SCRIPT_DIR/update.sh
  ;;
*)
  echo "USAGE:"
  echo ""
  echo "  install: Installs a new environment into the directory of your choice."
  echo ""
  echo "  The following arguments should be run from a particular environment as your working directory:"
  echo ""
  echo "    start: Starts up tomcat and tails the log file"
  echo "    stop:  Stops tomcat and terminates the process if needed"
  echo "    log:   Tails the log file"
  echo ""
  echo "    The following arguments all build the artifact you specify (provided as the second argument), "
  echo "    and update the relevant module(s) and/or war with the new versions"
  echo ""
  echo "    build <projectName>: Performs a mvn clean install -DskipTests."
  echo "    update: Refreshes modules from distribution if appropriate, then performs a build on every module in the modules folder"
  echo ""
  echo "    Note: This will not build if no changes are detected and an existing artifact is "
  echo "    found unless you pass an additional 'force' parameter to it"
  echo ""
  echo "    test <projectName>:   Performs a mvn clean install"
  echo ""
  echo "    distribution <projectName>: Performs a mvn clean install -DskipTests -Pdistribution"
  echo ""
  ;;
esac
