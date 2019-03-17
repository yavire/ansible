#!/bin/sh

# Version 2.2.0.2_7
# 03/02/2019 

baseAgentDir=/opt/krb/yavire/inventory
export baseAgentDir

LANG=en_US.ISO8859-1
export LANG

JAVA_HOME=$baseAgentDir/java
export JAVA_HOME

PATH=${JAVA_HOME}/bin:${PATH}
export PATH

CLASSPATH=$baseAgentDir/bin:$baseAgentDir/lib/activation.jar:$baseAgentDir/lib/javax.mail.jar:$baseAgentDir/lib/ojdbc8.jar:$baseAgentDir/lib/yavire21.jar:.
export CLASSPATH

cd $baseAgentDir/bin

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory INITDB

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory GETDATA

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory ADDM-SERVERS

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory SERVERS

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory INSTANCES

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory DAILYSTATS

java -DDirBase=$baseAgentDir -DConfFile=/properties/yavire.ini -DInvFile=/nucleus/data/yavireTotalInventory.data yavire.yavireNucleusInventory SENDMAILS
