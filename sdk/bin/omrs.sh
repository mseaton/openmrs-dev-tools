#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

case $1 in
initialize)
  $SCRIPT_DIR/initializeEnvironment.sh
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
  if [ -z "$2" ]
    then
      echo "The build argument expects a valid source directory as a second argument"
    else
      $SCRIPT_DIR/build.sh "/home/mseaton/code" "$2"
  fi
  ;;
*)
  echo "USAGE: [initialize, start, stop, log, build]"
  ;;
esac
