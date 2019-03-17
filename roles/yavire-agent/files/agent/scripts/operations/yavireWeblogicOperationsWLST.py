######################################################################

# Redirect stdout to a logfile #

#====================================
# Stop all instances of a Cluster
#====================================
import sys
import time
import datetime
import binascii

from java.io import File
from java.io import FileOutputStream

#Fecha: 2013/11/17 12:44
yavVersion="2.1.0.2_15";


def stopYav(Name,cluster):
 try:
   if cluster == '1':
     shutdown(Name,"Cluster",force='true')
     state(Name,"Cluster")     
   else:
     shutdown(Name,"Server",force='true')
     state(Name)
 except Exception, e:
  print 'Error en funcion stopSrv: ',e
  dumpStack()
  return
  
def startYav(Name,cluster,block):
 try:
   if cluster == '1':
     start(Name,"Cluster")
     state(Name,"Cluster")    
   else:
     if block == 'noblock':
       start(Name,"Server", block='false')
       state(Name,"Server")
     else:
       start(Name,"Server", block='true')
       state(Name,"Server")
 except Exception, e:
  print 'Error en funcion stopSrv: ',e
  dumpStack()
  return


def deployYav(szTarget,szPath,szApp,cluster,isApp):
 progress='null'
 print "Current date and time: " , datetime.datetime.now()
 try:
  #Despliegues en cluster
  if cluster == '1':
   if isApp == '1':
     print 'Deploying Application on cluster ' + szTarget
     progress=deploy(appName=szApp,path=szPath,targets=szTarget)
     state = progress.getState()
     if state == 'completed':
        print 'OK: Deploy of application '+szApp+' was successful...'
     else:
        print 'ERROR: Deploy of application '+szApp+' was not successful...'
   else:
     print 'Deploying Library on cluster ' + szTarget
     progress=deploy(appName=szApp,path=szPath,targets=szTarget,libraryModule='true')
     state = progress.getState()
     if state == 'completed':
        print 'OK: Deploy of '+szApp+' was successful...'
        stopApplication(appName=szApp,libraryModule='true')
     else:
        print 'ERROR: Deploy of library '+szApp+' was not successful...'
  else:
    #Despliegues en instancias
    if isApp == '1':
       print 'Deploying Application on instance'
       progress=deploy(appName=szApp,path=szPath,targets=szTarget)
       state = progress.getState()
       if state == 'completed':
         print 'OK: Deploy of '+szApp+' was successful...'
       else:
         print 'ERROR: Deploy of '+szApp+' was not successful...'
    else:
       print 'Deploying library on instance'
       progress=deploy(appName=szApp,path=szPath,targets=szTarget,libraryModule='true')
       state = progress.getState()
       if state == 'completed':
          print 'OK: Deploy of '+szApp+' was successful...'
          stopApplication(appName=szApp,libraryModule='true')
       else:
          print 'ERROR: Deploy of '+szApp+' was not successful...'
  print "Current date and time: " , datetime.datetime.now()
 except Exception, e:
  print 'Error en funcion deployYav: ',e
  print sys.exc_info()[0]
  dumpStack()
  return
  
def undeployYav(szTarget,szApp,cluster,isApp):
 progress='null'
 print "Current date and time: " , datetime.datetime.now()
 try:
  
  if cluster == '1':
   if isApp == '1':
     print 'Undeploying Application on cluster ' + szTarget
     progress=undeploy(appName=szApp,targets=szTarget,timeout=0)
     state = progress.getState()
     if state == 'completed':
        print 'OK: Undeploy of application '+szApp+' was successful...'
     else:
        print 'ERROR: Undeploy of application '+szApp+' was not successful...'
   else:
     print 'Undeploying Library on cluster ' + szTarget
     progress=deploy(appName=szApp,path=szPath,targets=szTarget,libraryModule='true')
     state = progress.getState()
     if state == 'completed':
        print 'OK: Deploy of '+szApp+' was successful...'
        stopApplication(appName=szApp,libraryModule='true')
     else:
        print 'ERROR: Deploy of library '+szApp+' was not successful...'
  else:
    if isApp == '1':
       print 'Undeploying Application on instance'
       progress=undeploy(appName=szApp,targets=szTarget)
       state = progress.getState()
       if state == 'completed':
         print 'OK: Deploy of '+szApp+' was successful...'
       else:
         print 'ERROR: Deploy of '+szApp+' was not successful...'
    else:
       print 'Undeploying library on instance'
       progress=deploy(appName=szApp,path=szPath,targets=szTarget,libraryModule='true')
       state = progress.getState()
       if state == 'completed':
          print 'OK: Deploy of '+szApp+' was successful...'
          stopApplication(appName=szApp,libraryModule='true')
       else:
          print 'ERROR: Deploy of '+szApp+' was not successful...'
 except Exception, e:
  print 'Error en funcion deployYav: ',e
  print sys.exc_info()[0]
  dumpStack()
  return
  
def undeployClstrLibrary(szTarget,libraryName):
  
  print 'Accediendo a undeployClstrLibrary(libraryName)', libraryName
    
  cd ('Libraries')
  libraries = cmo.getLibraries();
  for library in libraries:
    #print 'Libreria1: ', library.getName()
    values= library.getName().split("#")
    if values[0] == libraryName:
       print '   Libreria encontrada: ',values[0]
       #Buscamos la version
       versions= values[1].split("@")
       print '     libSpecVersion: ',versions[0]
       print '     libImplVersion: ',versions[1]
       undeployClstrLib(szTarget,libraryName,versions[0],versions[1])
  return
 
def undeployClstrLib(szTarget,szApp, Spec, Impl):
 try:
  #undeploy(appName=szApp,targets=szTarget,libraryModule='true',libSpecVersion='3.0.0', libImplVersion='3.20.2')
  undeploy(appName=szApp,targets=szTarget,libraryModule='true',libSpecVersion=Spec, libImplVersion=Impl)
 except Exception, e:
  print 'Error en funcion undeployClstrLib: ',e
  dumpStack()
  return

def undeploySrvLibrary(szTarget,libraryName):
  
  print 'Accediendo a undeploySrvLibrary(libraryName)', libraryName
  
  cd ('Libraries')
  libraries = cmo.getLibraries();
  for library in libraries:
    values = library.getName().split("#")
    if values[0] == libraryName:
       print '   Libreria encontrada: ',values[0]
       #Buscamos la version
       versions= values[1].split("@")
       print '     libSpecVersion: ',versions[0]
       print '     libImplVersion: ',versions[1]
       undeploySrvLib(szTarget,libraryName,versions[0],versions[1])
  return
  
def undeploySrvLib(szTarget,szApp, Spec, Impl):
 try:
  undeploy(appName=szApp,targets=szTarget,libraryModule='true',libSpecVersion=Spec, libImplVersion=Impl)
 except Exception, e:
  print 'Error en funcion undeploySrvLib: ',e
  dumpStack()
  return

def stateSrv(serverName):
 try:
  state(serverName,"Server")
 except Exception, e:
  print 'Error en funcion stateSrv: ',e
  dumpStack()
  return
 
def stateClstr(clstrName):
 try:
  state(clstrName,"Cluster")
 except Exception, e:
  print 'Error en funcion stateClstr: ',e
  dumpStack()
  return

 
def editing():
 try: 
  print 'Ejecutando comando edit()'
  edit()
  print 'Ejecutando comando startEdit()'
  startEdit()
 except: 
  print 'Error en funcion editing: ',e
  dumpStack()
  return
 
def activating():
 save()
 activate()
 return
 
def finishediting():
  stopEdit(y)
  return
 

def conn(userAdmin, passAdmin, urlAdmin):
 connect(userAdmin, passAdmin, urlAdmin)


#====================================
# Exiting the script
#====================================
def quit():
 #finishediting()
 disconnect()
 exit()


#====================================
# The main script starts here...
#====================================
if __name__ == "main":
 
 print "";
 print "=============================================================================================!!";
 print "   yavire WLST Weblogic Operations Version ",  yavVersion;
 print "\n=============================================================================================!!";
 print "      Admin User: ", sys.argv[1];
 print "      Admin pass: ", sys.argv[2];
 print "      Command: ", sys.argv[3];
 print "      Block: ", sys.argv[9];
 print "      Target: ", sys.argv[4];
 print "      Admin URL: ", sys.argv[5];
 print "      Log: ", sys.argv[6];
 print "      File Deploy: ", sys.argv[7];
 print "      Application/Library/URI: ", sys.argv[8];
 print "      Cluster: ", sys.argv[10];
 print "      isAPP: ", sys.argv[11];
 print "=============================================================================================!!";
 try: 
    conn(sys.argv[1],binascii.unhexlify(sys.argv[2]),sys.argv[5])
 except: 
    print "yavError: We were unable to connect to the admin console";
    print "\n============================================================================================="
    print "   Finishing yavire WLST Weblogic Operations Version ",  yavVersion
    print "\n=============================================================================================";
    exit()
  
 if sys.argv[3]=='Start':
    startYav(sys.argv[4],sys.argv[10],sys.argv[9])
 elif sys.argv[3]=='Stop':
    stopYav(sys.argv[4],sys.argv[10])
 elif sys.argv[3]=='WeblogicEstadoClusterAdmin':
    stateClstr(sys.argv[4])
 elif sys.argv[3]=='Test':
    stateSrv(sys.argv[4])
 elif sys.argv[3]=='Deploy':
    editing()
    activating() 
    deployYav(sys.argv[4],sys.argv[7],sys.argv[8],sys.argv[10],sys.argv[11])
 elif sys.argv[3]=='Undeploy':
    editing()
    activating()
    for app in cmo.getAppDeployments():
       currAppName = app.getName()
       if currAppName == sys.argv[8] :
          print 'Eliminando aplicacion en el cluster'
          undeployYav(sys.argv[4],sys.argv[8],sys.argv[10],sys.argv[11])
          print "Current date and time: " , datetime.datetime.now()
 # #elif sys.argv[3]=='WeblogicUndeployClusterLib':
    # editing()
    # activating()
    # print 'Eliminando libreria ', sys.argv[8]
    # undeployClstrLibrary(sys.argv[4],sys.argv[8])
    # print 'Finalizado el undeploy de la libreria ', sys.argv[8]
 # #elif sys.argv[3]=='WeblogicUndeployServerLib':
    # print 'Eliminando libreria en la instancia'
    # editing()
    # activating()
    # undeploySrvLibrary(sys.argv[4],sys.argv[8])
    # print 'Finalizado el undeploy de la libreria'
 else:
    print sys.argv[3]
    
 disconnect()
 print "\n=============================================================================================";
 print "   Finishing yavire WLST Weblogic Operations Version ",  yavVersion
 print "\n=============================================================================================";
 exit()
 
 


