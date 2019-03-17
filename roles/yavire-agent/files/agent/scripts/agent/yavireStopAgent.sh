#!/bin/sh

#set -x

#yvVersion="2.1.0.2_1"

JAKARTA=/opt/krb/yavire/agent
declare -i ESPERA=5
declare -i STEP=0
declare -i TOTALESPERA=1
SERVER=yavire21

#######################
# PROGRAMA PRINCIPAL  #
######################

    #SERVER=openweb
    DOMINIO=admin
    
    
    # set the environment
    CATALINA_HOME=/opt/krb/yavire/agent/yavire-agent
    export CATALINA_HOME 
   
    CATALINA_BASE=$CATALINA_HOME
    export CATALINA_BASE
   
   JAVA_HOME=$JAKARTA/java
   export JAVA_HOME
    
   cd $CATALINA_BASE

   
   $CATALINA_BASE/bin/catalina.sh stop
      

   PID_COUNT=`ps -ef |grep "\-D$SERVER " |grep yavire-agent |grep -v grep |grep -v tail |wc -l`
   while [ $PID_COUNT -gt 0 ]
        do
          sleep $ESPERA
          STEP=${STEP}+1
          TOTALESPERA=${STEP}*${ESPERA}
          echo "Tiempo de Espera..... $TOTALESPERA segundos"
          if [ $STEP -ge 12 ]
          then
              PROCESSWEB=`ps -ef |grep "\-D$SERVER " |grep yavire-agent |grep -v grep | awk '{print $2}'`
              for PROCESS in $PROCESSWEB
              do
                echo "Eliminando proceso colgado del agente ... $PROCESS"
                
                kill -9 $PROCESS
               
                sleep $ESPERA
              done
          fi
          PID_COUNT=`ps -ef |grep "\-D$SERVER " |grep yavire-agent |grep -v grep |grep -v tail |wc -l`
          echo "Numero de Procesos... $PID_COUNT"
   done
   
