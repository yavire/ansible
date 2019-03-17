#!/bin/sh
#############################################################
# Script que se levantar automaticamente el agente Yavire   #
#############################################################
#Version 2.1.0.0_1

#set -x

i=`ps -fea | grep Dyavire21 | grep -v grep`
if [[ -z $i ]]
then
   /opt/krb/yavire/agent/scripts/agent/yavireStartAgent.sh
fi


