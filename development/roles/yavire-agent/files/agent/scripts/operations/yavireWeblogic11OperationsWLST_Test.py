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
owmVersion="2.1.0.0_Test";

def deployClstrLib(szTarget,szPath,szApp):
 progress='null'
 try:
  progress=deploy(appName=szApp,path=szPath,targets=szTarget,libraryModule='true')
    
  state = progress.getState()
  if state == 'completed':
   print 'OK: Deploy of '+szApp+' was successful...'
   stopApplication(appName=szApp,libraryModule='true')
      
  else:
   print 'ERROR: Deploy of '+szApp+' was not successful...'
 except Exception, e:
  print 'Error en funcion deployClstrLib: ',e
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

def deploySrvLib(szTarget,szPath,szApp):
 progress='null'
 try:
  progress=deploy(appName=szApp,path=szPath,targets=szTarget,libraryModule='true')
    
  state = progress.getState()
  if state == 'completed':
   print 'OK: Deploy of '+szApp+' was successful...'
   stopApplication(appName=szApp,libraryModule='true')
      
  else:
   print 'ERROR: Deploy of '+szApp+' was not successful...'
 except Exception, e:
  print 'Error en funcion deployClstrLib: ',e
  print sys.exc_info()[0]
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

def deployClstrApp(szTarget,szPath,szApp):
 progress='null'
 try:
  #editing()
  progress=deploy(appName=szApp,path=szPath,targets=szTarget)
  state = progress.getState()
  if state == 'completed':
   print 'OK: Deploy of '+szApp+' was successful...'
  else:
   print 'ERROR: Deploy of '+szApp+' was not successful...'
 except Exception, e:
  print 'Error en funcion deployClstrApp: ',e
  print sys.exc_info()[0]
  dumpStack()
  #activating()
  return
  
def undeployClstrApp(szTarget,szApp):
 progress='null'
 try:
  progress=undeploy(appName=szApp,targets=szTarget,timeout=0)
  state = progress.getState()
  if state == 'completed':
   print 'OK: Undeploy of '+szApp+' was successful...'
  else:
   print 'ERROR: Undeploy of '+szApp+' was not successful...'
 except Exception, e:
  print 'Error en funcion undeployClstrApp: ',e
  dumpStack()
  return

def deploySrvApp(szTarget,szPath,szApp):
 try:
  deploy(appName=szApp,path=szPath,targets=szTarget)
 except Exception, e:
  print 'Error en funcion deploySrvApp: ',e
  print sys.exc_info()[0]
  dumpStack()
  return
  
def undeploySrvApp(szTarget,szApp):
 try:
  undeploy(appName=szApp,targets=szTarget)
 except Exception, e:
  print 'Error en funcion undeploySrvApp: ',e
  dumpStack()
  return

 
def stopSrv(serverName):
 try:
  shutdown(serverName,"Server",force='true')
  state(serverName)
 except Exception, e:
  print 'Error en funcion stopSrv: ',e
  dumpStack()
  return

def stateSrv(serverName):
 try:
  state(serverName,"Server")
 except Exception, e:
  print 'Error en funcion stateSrv: ',e
  dumpStack()
  return

def startSrv(serverName,block):
 try:
   if block == 'noblock':
     start(serverName,"Server", block='false')
     state(serverName,"Server")
   else:
     start(serverName,"Server", block='true')
     state(serverName,"Server")
  
 except Exception, e:
  print 'Error en funcion startSrv: ',e
  dumpStack()
  return
  
def stopClstr(clstrName):
 try:
  shutdown(clstrName,"Cluster",force='true')
  state(clstrName,"Cluster")
 except Exception, e:
  print 'Error en funcion stopClstr: ',e
  dumpStack()
  return

def stateClstr(clstrName):
 try:
  state(clstrName,"Cluster")
 except Exception, e:
  print 'Error en funcion stateClstr: ',e
  dumpStack()
  return

def startClstr(clstrName):
 try:
  start(clstrName,"Cluster")
  state(clstrName,"Cluster")
 except Exception, e:
  print 'Error en funcion startClstr: ',e
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
 print "   yavire WLST Weblogic Operations Version ",  owmVersion;
 print "\n=============================================================================================!!";
 print "      Admin User: ", sys.argv[1];
 print "      Admin pass: ", sys.argv[2];
 print "      Command: ", sys.argv[3];
 print "      Block: ", sys.argv[9];
 print "      Target: ", sys.argv[4];
 print "      Admin URL: ", sys.argv[5];
 print "      Log: ", sys.argv[6];
 print "      File Deploy: ", sys.argv[7];
 print "      Application/Library: ", sys.argv[8];
 print "=============================================================================================!!";
 try: 
    conn(sys.argv[1],binascii.unhexlify(sys.argv[2]),sys.argv[5])
 except: 
    print "ERROR: No hemos podido conectar a la consola de administracion";
    print "\n============================================================================================="
    print "   Finishing yavire WLST Weblogic Operations Version ",  owmVersion
    print "\n=============================================================================================";
    exit()
  
 if sys.argv[3]=='WeblogicReiniciarClusterAdmin':
    print 'Reiniciando cluster'
    # stopClstr(sys.argv[4])
    # startClstr(sys.argv[4])
 elif sys.argv[3]=='WeblogicArrancarClusterAdmin':
    print 'Arrancando cluster'
    # startClstr(sys.argv[4])
 elif sys.argv[3]=='WeblogicPararClusterAdmin':
    print 'Parando cluster'
    # stopClstr(sys.argv[4])
 elif sys.argv[3]=='WeblogicEstadoClusterAdmin':
    stateClstr(sys.argv[4])
 elif sys.argv[3]=='WeblogicReiniciarServerAdmin':
    print 'Reiniciando servidor'
    # stopSrv(sys.argv[4])
    # startSrv(sys.argv[4],sys.argv[9])
 elif sys.argv[3]=='WeblogicArrancarServerAdmin':
    print 'Arrancando servidor'
    # startSrv(sys.argv[4],sys.argv[9])
 elif sys.argv[3]=='WeblogicPararServerAdmin':
    print 'Parando servidor'
    # stopSrv(sys.argv[4])
 elif sys.argv[3]=='testServer':
    stateSrv(sys.argv[4])
 elif sys.argv[3]=='WeblogicDeployClusterApp':
    print 'Desplegando aplicacion en cluster'
    print "Current date and time: " , datetime.datetime.now()
    # deployClstrApp(sys.argv[4],sys.argv[7],sys.argv[8])
    print 'Finalizado el despliegue'
    print "Current date and time: " , datetime.datetime.now()
 elif sys.argv[3]=='WeblogicUndeployClusterApp':
    editing()
    activating() 
    for app in cmo.getAppDeployments():
       currAppName = app.getName()
       if currAppName == sys.argv[8] :
          print 'Eliminando aplicacion en el cluster'
          # undeployClstrApp(sys.argv[4],sys.argv[8])
          print "Current date and time: " , datetime.datetime.now()
 elif sys.argv[3]=='WeblogicDeployServerApp':
    print 'Desplegando aplicacion en el servidor'
    # deploySrvApp(sys.argv[4],sys.argv[7],sys.argv[8])
    print 'Finalizado el despliegue de la aplicacion'
 elif sys.argv[3]=='WeblogicUndeployServerApp':
    for app in cmo.getAppDeployments():
       currAppName = app.getName()
       if currAppName == sys.argv[8] :
          print 'Eliminando aplicacion en el servidor'
          # undeploySrvApp(sys.argv[4],sys.argv[8])
          print "Current date and time: " , datetime.datetime.now()
 elif sys.argv[3]=='WeblogicDeployClusterLib':
    print 'Desplegando Libreria en el cluster'
    # deployClstrLib(sys.argv[4],sys.argv[7],sys.argv[8])
    print 'Finalizado el despliegue de la libreria'
 elif sys.argv[3]=='WeblogicUndeployClusterLib':
    editing()
    activating()
    print 'Eliminando libreria ', sys.argv[8]
    # undeployClstrLibrary(sys.argv[4],sys.argv[8])
    print 'Finalizado el undeploy de la libreria ', sys.argv[8]
 elif sys.argv[3]=='WeblogicDeployServerLib':
    print 'Desplegando libreria en la instancia'
    # deploySrvLib(sys.argv[4],sys.argv[7],sys.argv[8])
    print 'Finalizado el despliegue de la libreria'
 elif sys.argv[3]=='WeblogicUndeployServerLib':
    print 'Eliminando libreria en la instancia'
    editing()
    activating()
    # undeploySrvLibrary(sys.argv[4],sys.argv[8])
    print 'Finalizado el undeploy de la libreria'
 else:
    print sys.argv[3]
    
 disconnect()
 print "\n=============================================================================================";
 print "   Finishing yavire WLST Weblogic Operations Version ",  owmVersion
 print "\n=============================================================================================";
 exit()
 
 


