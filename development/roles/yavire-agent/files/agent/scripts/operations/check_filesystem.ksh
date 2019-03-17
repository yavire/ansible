#!/bin/ksh


################################################
# Script que se encarga de actualizar Openweb  #
################################################

#set -x

if [ $# -ne 1 ]
then
     echo "No ha especificado el Filesystem"
fi

OS=`uname -s`

case $MACHINE in
 SunOS)
     OCUPACION_TMP=`/usr/xpg4/bin/df -kP $1 | grep -v Mounted`
      ;;
 *)
     OCUPACION_TMP=`df -kP $1 | grep -v Mounted` 
     ;;
esac

PORC=`echo $OCUPACION_TMP | awk '{print $5}'`
ASSIGN=`echo $OCUPACION_TMP | awk '{print $2}'` 
#ASSIGN=${ASSIGN}%1024
ASSIGN=$(($ASSIGN/1024))
FREE=`echo $OCUPACION_TMP | awk '{print $4}'`
#FREE=${FREE}%1024
FREE=$(($FREE/1024))

echo "% Espacio Asignado: $ASSIGN (MB) % Espacio Libre: $FREE (MB) % Porcentaje Ocupado: $PORC"


