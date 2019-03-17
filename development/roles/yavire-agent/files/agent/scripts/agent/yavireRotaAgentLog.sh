#!/bin/sh
# Script de Rotado de logs del agente 
# Rota todos los ficheros cada dia
# Se queda con 7 dias 
# Se ejecuta a las 24:00 horas desde el cron
#

#set -x

#versionYV="2.1.0.0_1"

JAKARTA=/opt/krb/yavire/agent
FBACKUP=5  ## Numero de ficheros de backup
DATE=`date +"%Y-%m-%d.txt"`

###################################################
rotatedir()
{
 cd $1
 echo "directorio actual:"`pwd`
 
   for file in `ls |cut -d'.' -f1 |grep -v yavire-agent |sort -u`
   do
     rotatefile $file
   done
   
 echo "Sale rotatedir directorio actual:"`pwd`
}
##################################################
rotatefile()
{
 
 if [ $1 = "catalina" ]
 then
     #echo "Rotado de catalina.out ..."
     ROTFILE="$1.$DATE"
     cp $1.out $ROTFILE
     
     /bin/cp /dev/null $1.out
     
 fi

 NUMFILE=`ls |grep $1 |wc -l` # Numero de ficheros en logs
 if [ $NUMFILE -gt $FBACKUP ]
 then
     DELFILE=$(($NUMFILE - $FBACKUP))
     rm -f `ls |grep $1 |head -$DELFILE`
 fi
}

######################
# PROGRAMA PRINCIPAL #
######################


rotatedir /opt/krb/yavire/agent/yavire-agent/logs


