@ECHO OFF

rem yavire Version 2.1.0.2_2 - start Inventory nucleus
rem Date: 2017/12/15

set "baseAgentDirWin=C:\krb\yavire\inventory"

set JAVA_HOME=%baseAgentDirWin%\java

set LANG=en_US.ISO8859-1
set PATH=%JAVA_HOME%\bin
set CLASSPATH=%baseAgentDirWin%\bin;%baseAgentDirWin%\lib\yavire21.jar;%baseAgentDirWin%\lib\ojdbc8.jar;%baseAgentDirWin%\lib\javax.mail.jar.;

cd %baseAgentDirWin%\bin\yavire

echo %PATH%
echo =========
echo %CLASSPATH%
echo ========

%PATH%\java -version
%PATH%\java -DDirBase=%baseAgentDirWin% -DConfFile=\properties\yavire.ini -DInvFile=\nucleus\data\yavireTotalInventory.data yavire.yavireNucleusInventory INITDB

%PATH%\java -DDirBase=%baseAgentDirWin% -DConfFile=\properties\yavire.ini -DInvFile=\nucleus\data\yavireTotalInventory.data yavire.yavireNucleusInventory GETDATA

%PATH%\java -DDirBase=%baseAgentDirWin% -DConfFile=\properties\yavire.ini -DInvFile=\nucleus\data\yavireTotalInventory.data yavire.yavireNucleusInventory SERVERS

%PATH%\java -DDirBase=%baseAgentDirWin% -DConfFile=\properties\yavire.ini -DInvFile=\nucleus\data\yavireTotalInventory.data yavire.yavireNucleusInventory INSTANCES



