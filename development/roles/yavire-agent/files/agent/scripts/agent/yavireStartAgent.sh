#!/bin/sh

#set -x

#yavVersion="2.2.0.2_1"

#######################
# PROGRAMA PRINCIPAL  #
######################

    
   # set the environment
   CATALINA_HOME=/opt/krb/yavire/agent/yavire-agent
   export CATALINA_HOME 
   
   CATALINA_BASE=$CATALINA_HOME
   export CATALINA_BASE
   
   JAVA_HOME=$JAKARTA/java
   export JAVA_HOME
   
   JAVA_OPTS="-Dyavire21 -Duser.timezone=Europe/Madrid"
   export JAVA_OPTS
   
   LANG=es_ES.ISO8859-1
   export LANG
   
   $CATALINA_BASE/bin/catalina.sh start
   
