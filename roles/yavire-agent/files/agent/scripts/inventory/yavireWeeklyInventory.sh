#!/bin/sh
##############################
# Yavire Weekly Inventory    #
##############################
#Version 2.2.0.2_5 (9/02/2019)

#set -x
#

# Base Directory
DIR_OPEN=/opt/krb/yavire/agent

sudo $DIR_OPEN/scripts/inventory/yavireApacheWeeklyFileInventory.pl 
sudo $DIR_OPEN/scripts/inventory/yavireWeblogic8to12.FileInventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireOracle_FileInventory.pl 
sudo $DIR_OPEN/scripts/inventory/yavireMySQLWeekInventory.pl
sudo $DIR_OPEN/scripts/inventory/yavireJBoss3_0to6.1_FileInventory.pl 
sudo $DIR_OPEN/scripts/inventory/yavireTomcatWeeklyFileInventory.pl 
