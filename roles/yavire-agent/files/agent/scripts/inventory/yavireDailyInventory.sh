#!/bin/sh
##############################
# Yavire Daily Inventory     #
##############################
#Version 2.2.0.2_6 (9/02/2019)

#set -x


# Directorio datos
DIR_OPEN=/opt/krb/yavire/agent

#Deleting old inventory
cd $DIR_OPEN/inventory/data
rm -R *

sudo $DIR_OPEN/scripts/inventory/yavireUnixServerInventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireUnixMemoryInventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireAgentInventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireFilesystemInventory34.pl
sudo $DIR_OPEN/scripts/inventory/yavireApache2Inventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireUnixWeblogic11Inventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireUnixWeblogic12Inventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireOracleDailyInventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireUnixTomcat6Inventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireUnixTomcat7Inventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireUnixTomcat8Inventory.pl

#$DIR_OPEN/scripts/inventory/yavireJBoss4Inventory34.pl
#$DIR_OPEN/scripts/inventory/yavireTomcat5Inventory34.pl
#$DIR_OPEN/scripts/inventory/yavireTomcat7Inventory34.pl

cd $DIR_OPEN/inventory
#Esperamos 5 minutos
#sleep 300
#tar cf /opt/openweb/webtools/data.tar data
$DIR_OPEN/java/bin/jar cf $DIR_OPEN/webtools/data.jar data



#Estadisticas

#$DIR_OPEN/scripts/openwebGeneraConfEstadisticas.pl $1 &

sudo $DIR_OPEN/scripts/agent/yavireRotaAgentLog.sh
