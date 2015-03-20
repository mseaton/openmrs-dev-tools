#!/bin/bash

echo "Stopping OpenMRS"

export CATALINA_BASE="<ENV_DIR>/tomcat"
/usr/share/tomcat7/bin/shutdown.sh

# Kill off the Tomcat process if necessary
ps ax | awk '/java/ && /tomcat/ && !/awk/ {print $1}' | xargs kill

echo "OpenMRS stopped"
