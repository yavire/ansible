#!/usr/bin/perl
#use lib '/opt/krb/yavire/agent/perl/lib/perl5/site_perl/5.8.8';
#use Shell::Source;

use POSIX qw(strftime);

$owmVersion="2.1.0.0_1";

#* NombreFichero: yavireJbossUnix.pl
#*=========================================================
#* Fecha Creación: [17/03/2014]
#* Autor: Fernando Oliveros
#* Compañia: kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Operaciones sobre JBoss 4
#*
#*=============================================
#*
#*
#*=============================================
#* Parametros:
#*      N/A
#*
#*=============================================
#* Historial
#*=============================================
#* Date: [DD/MM/AAAA]
#* Problema:
#* Solucion:
#*
#*=============================================
#

#*===========================================================
#* Funciones del programa 
#*===========================================================

sub comprobarSSH {
   
   if ( $prefixCommand eq "") {
      
      print LOGS "El usuario del agente yavire y el de la instancia es el mismo. Verificacion OK\n\n";
           
   }  
   else {
      
      print LOGS "Los usuarios del agente yavire y el de la instancia son distintos. Se procede a verificar conexion SSH ...\n\n";
       # my @output = `${prefixCommand} "which perl"`;
      my @output = qx(${prefixCommand} "which perl");
      
      print LOGS "Paso1\n";
      
      foreach $file (@output){
         print LOGS "Linea: $file\n";
      }
      
      print LOGS "Paso2\n";
      
   }
   
}


sub arrancarJBoss {
	
      print LOGS "Ejecutando arranque de la instancia $NAME_INSTANCE \n";
      
      $ejecutarParada=1;
      
      if ($scriptArranque eq "undefined") {
         print LOGS "Comando: $prefixCommand ${DIR_BASE}/bin/run.sh -b 0.0.0.0 & \n\n";
         $salida=system("${prefixCommand} ${DIR_BASE}/bin/run.sh -b 0.0.0.0 &");
      
      }
      else {
         
         #Comprobamos que el script exista
         @aScriptsAndParameters = split(' ', $scriptArranque);
         $scriptName=$aScriptsAndParameters[0];
         
         if (-e $scriptName) {
            print LOGS "Comando: $prefixCommand ${scriptArranque} & \n\n";
            $salida=system("${prefixCommand} ${scriptArranque} &");
         } 
         else {
            
            print LOGS "OWM_ERROR: el script particular de arranque $scriptName no existe!!\n\n";
            
            $ejecutarParada=0;
            
         }
               
      }
      
      
      if ($ejecutarParada eq 1) {
               
         #Esperamos que se borre el server.log 
         sleep 10;
         
         if (-d $directorioLogJboss) {
            
            $cadenaOK = "Started in";
            $encontreCadenaOK = 0;
            
            chdir($directorioLogJboss);
            print LOGS "Estamos en el subdirectorio $directorioLogJboss\n\n";
            
            for( $a = 1; $a < 30; $a = $a + 1 ){
               
               $salidaGrep=`fgrep  '$cadenaOK' $directorioLogJboss/server.log`;
                
               if (index($salidaGrep, $cadenaOK) != -1) {
                  print LOGS "El fichero $directorioLogJboss/server.log contiene la cadena  $cadenaOK\n";
                  print LOGS "Cadena de arranque: $salidaGrep \n";
                  $encontreCadenaOK = 1;
                  last;
               } 
        
               sleep 5;
            }
            
            if ($encontreCadenaOK eq 0) {
               print LOGS "OWM_WARNING: Revise la salida del servidor, no se ha localizado la cadena \"$cadenaOK\" en $directorioLogJboss/server.log \n";
            }
            
         }
         else {
            print LOGS "OWM_WARNING: No existe el directorio del log del jboss - $directorioLogJboss\n";
         }
      }
        
        
}



sub pararJBoss {
   
      print LOGS "Ejecutando parada de la instancia $NAME_INSTANCE \n";
      
      comprobarSSH();
      
      print LOGS "ps -ef |grep $USER_INSTANCE | grep $DIR_BASE |grep -v grep | grep Dprogram.name | awk '{print \$2}'\n";
      my $process_chk_command = `ps -ef |grep $USER_INSTANCE | grep $DIR_BASE |grep -v grep | grep Dprogram.name | awk '{print \$2}'`;
      
      print LOGS "\nProcessID $process_chk_command \n";
      
      if ($process_chk_command ne "") {
         print LOGS "Parando proceso del Jboss: $prefixCommand kill -15  $process_chk_command \n\n";
         
         $salidaPS=`$prefixCommand kill -15  $process_chk_command`;
         print LOGS "$salidaPS";
         
         #Buscamos en el log que aparezca la palabra Shutdown complete
         if (-d $directorioLogJboss) {
         
            $cadenaOK = "Shutdown complete";
            $encontreCadenaOK = 0;
            
            chdir($directorioLogJboss);
            print LOGS "Estamos en el subdirectorio $directorioLogJboss\n\n";
            
            for( $a = 1; $a < 30; $a = $a + 1 ){
               
               $salidaGrep=`tail -10 $directorioLogJboss/server.log |grep '$cadenaOK' `;
                
               if (index($salidaGrep, $cadenaOK) != -1) {
                  print LOGS "El fichero $directorioLogJboss/server.log contiene la cadena  $cadenaOK\n";
                  print LOGS "Cadena de shutdown: $salidaGrep \n";
                  $encontreCadenaOK = 1;
                  last;
               } 
        
               sleep 1;
            }
            
            if ($encontreCadenaOK eq 0) {
               
               print LOGS "No se ha localizado la cadena \"$cadenaOK\" en $directorioLogJboss/server.log \n";
               
               if ($process_chk_command ne "") {
                  print LOGS "Forzamos la parada del proceso $process_chk_command\n";
                  $salidaPS=`$prefixCommand kill -9  $process_chk_command`;
               }
            }
            
         }
         else {
            print LOGS "OWM_WARNING: No existe el directorio del log del jboss - $directorioLogJboss\n";
         }         
                  
      
      }
      else {
         
         print LOGS "OWM_WARNING: No se ha encontrado el proceso\n";
         
      }
  
   
   
}


#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

#Parametros:
#   - Comando a ejecutar (stop/start/restart)
#   - Propietario de la instancia
#   - Directorio base del tomcat
#   - Nombre de la instancia
#   - Numero de operacion

$ADMINURL="t3://$ARGV[0]${1}:$ARGV[1]";
$USER_ADMIN="$ARGV[2]";
$PASS_ADMIN="$ARGV[3]";
$COMANDO="$ARGV[4]";
$NAME_INSTANCE="$ARGV[5]";
$TIPO_INSTANCIA="$ARGV[6]";
$DOMINIO_INSTANCIA="$ARGV[7]";
$FICHERO_DESPLIEGUE="$ARGV[8]";
$URI="$ARGV[9]";
$ID_OPERACION="$ARGV[10]";
$USER_INSTANCE="$ARGV[11]";
$DIR_BASE="$ARGV[12]";
$DEPLOY_PROP="$ARGV[13]";
$SERVIDORES_CLUSTER="$ARGV[14]";
$SUBCOMANDO="$ARGV[15]";
$DIRLOG="/opt/krb/yavire/agent/webtools/operaciones/comandos";
$USER_PROCESS=(getpwuid($<))[0];
$FICHLOG="$DIRLOG\/$ID_OPERACION\_$NAME_INSTANCE\_$COMANDO";


@aScripts = split('@', $SUBCOMANDO);
$scriptArranque=$aScripts[0];
$scriptParada=$aScripts[1];


#*===========================================================
#* Cuerpo del programa 
#*===========================================================

open(LOGS,"+>>$FICHLOG") || die "problemas abriendo fichero de log $FICHLOG\n";

print LOGS "==============================================================================================\n";
print LOGS "   yavire script for JBoss - Version $owmVersion\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n\n";
print LOGS "      Command: $COMANDO\n";
print LOGS "      Script particular de arranque: $scriptArranque\n";
print LOGS "      Script particular de parada: $scriptParada\n";
#print LOGS "      URL: $ADMINURL\n";
#print LOGS "      Admin User: $USER_ADMIN\n"; 
#print LOGS "      Admin Pass: $PASS_ADMIN\n";
print LOGS "      Instance: $NAME_INSTANCE\n";
print LOGS "      Domain: $DOMINIO_INSTANCIA\n";
print LOGS "      File Deploy: $FICHERO_DESPLIEGUE\n";
print LOGS "      URI: $URI\n";
print LOGS "      Installation User: $USER_INSTANCE\n";
print LOGS "      yavire Agent User: " . (getpwuid($<))[0] . "\n";
print LOGS "      Instalation Directory: $DIR_BASE\n";
print LOGS "      Log: $FICHLOG\n";
print LOGS "      Id. Operation : $ID_OPERACION\n";
print LOGS "\n==============================================================================================\n\n";

#-- print username



if ( $USER_PROCESS eq $USER_INSTANCE) {
  print LOGS "El usuario del agente yavire y el de la instancia es el mismo\n\n";
  $prefixCommand = "";
} 
else {
 print LOGS "Los usuarios del agente yavire y el de la instancia son distintos ...\n\n";
 $prefixCommand = "ssh -l $USER_INSTANCE localhost";
}

$ENV{CATALINA_BASE}="${DIR_BASE}";
$ENV{CATALINA_HOME}="${DIR_BASE}";

#Calculamos el directorio de logs
@aInstancia = split('-', $NAME_INSTANCE);
$dirInstancia = $aInstancia[0];
$directorioLogJboss = "${DIR_BASE}/server/${dirInstancia}/log";


for ($COMANDO) {
   
   if (/JBossTestSSH/) {

      comprobarSSH();
      
   }
   elsif (/JBossArrancar/) {

      arrancarJBoss();
      
   }
   elsif (/JBossParar/) {

      pararJBoss();
      
   }
   elsif (/JBossReiniciar/) {

      print LOGS "Ejecutando reinicio de la instancia $NAME_INSTANCE \n";
      
      pararJBoss();
      
      arrancarJBoss();
      
     
   }
   elsif (/JBossBorrarCache/) {

      print LOGS "Ejecutando borrado de cache de la instancia $NAME_INSTANCE \n\n";
      
      #Calculamos el directorio de temporales
      my @aInstancia = split('-', $NAME_INSTANCE);
      my $dirInstancia = $aInstancia[0];
      
      my $directoryName = "${DIR_BASE}/server/${dirInstancia}/tmp";

      if (-d $directoryName) {

         # directorio tmp existe
               
         chdir($directoryName);
               
         print LOGS "Espacio ocupado del directorio $directoryName\n";
         my @lines = qx/du -su */;
         
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
               
         print LOGS "Borramos  el directorio $directoryName\n";
         my @lines = qx/ls -l/;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
         
         print LOGS "$prefixCommand rm -rf  $directoryName/*\n";   
         $salidaRM=`$prefixCommand rm -rf $directoryName/*`;
                 
      }
      elsif (-e $directoryName) {
         # Ruta tmp existe, pero no es un directorio
         print LOGS "Ruta $directoryName existe, pero no es un directorio\n"
      }
      else {
         print LOGS "Ruta $directoryName no existe\n"
      }
      
      $directoryName = "${DIR_BASE}/server/${dirInstancia}/work";

      if (-d $directoryName) {

         # directorio tmp existe
               
         chdir($directoryName);
               
         print LOGS "Espacio ocupado del directorio $directoryName\n";
         my @lines = qx/du -sh */;
         
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
               
         print LOGS "Borramos  el directorio $directoryName\n";
         my @lines = qx/ls -l/;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
            
         print LOGS "$prefixCommand rm -rf  $directoryName/*\n";   
         $salidaRM=`$prefixCommand rm -rf $directoryName/*`;
         
      }
      elsif (-e $directoryName) {
         # Ruta tmp existe, pero no es un directorio
         print LOGS "Ruta $directoryName existe, pero no es un directorio\n"
      }
      else {
         print LOGS "Ruta $directoryName no existe\n"
      }
      
      sleep 5;
     
   }
   elsif (/JBossDump/) {

   
      print LOGS "Generando dump de la instancia $NAME_INSTANCE \n";
      
      sleep 5;
     
   }
   else {
      print LOGS "ERROR: OPERACION NO DEFINIDA\n";
   }
   
}


#print LOGS "$salida\n\n";

print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for JBoss Version $owmVersion\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n";

close LOGS;


#*===========================================================
#* Fin script: yavireJbossUnix.pl]
#*===========================================================




