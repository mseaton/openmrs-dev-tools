#!/bin/sh

echo "Starting OpenMRS"

if [ -d $TOMCAT_HOME/work ];
then
   echo "Clearing work directory"
   rm -fR $TOMCAT_HOME/work
fi

if [ -d $TOMCAT_HOME/temp ];
then
   echo "Clearing temp directory"
   rm -fR $TOMCAT_HOME/temp/*
fi

if [ -d $TOMCAT_HOME/logs ];
then
   echo "Removing old logs"
   rm -fR $TOMCAT_HOME/logs/*
fi

export CATALINA_BASE="<ENV_DIR>/tomcat"

/usr/share/tomcat7/bin/startup.sh

tail -f $CATALINA_BASE/logs/catalina.out
