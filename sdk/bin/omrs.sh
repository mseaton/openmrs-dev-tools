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
  if [ -z "$2" ]
    then
      echo "The build argument expects a valid project source directory as a second argument"
    else
      $SCRIPT_DIR/build.sh "$2"
  fi
  ;;
*)
  echo "USAGE: [install, start, stop, log, build]"
  ;;
esac
