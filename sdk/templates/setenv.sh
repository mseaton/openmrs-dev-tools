#!/bin/sh

export CATALINA_HOME="/usr/share/tomcat7"
export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"
export JAVA_OPTS="-Xmx2048m -Xms1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:NewSize=128m"
export CATALINA_OPTS="-agentlib:jdwp=transport=dt_socket,address=<DEBUG_PORT>,server=y,suspend=n"