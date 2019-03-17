#!/usr/bin/perl
use POSIX qw(strftime);

$yavVersion="2.2.0.2_9";

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
$DIRLOG="/opt/krb/yavire/agent/webtools/operations/commands";
$CLUSTER="$ARGV[16]";
$IS_APP="$ARGV[17]";
$SOFT_VERSION="$ARGV[18]";
$USER_PROCESS=(getpwuid($<))[0];

$FICHLOG="$DIRLOG\/$ID_OPERACION\_$NAME_INSTANCE\_$COMANDO";

print "FICHERO LOG: $FICHLOG\n";
#$FICHLOGTMP="${FICHLOG}_tmp";

# open(LOGSTMP,">$FICHLOGWL") || die "problemas abriendo fichero de log $FICHLOG\n";
# print LOGSTMP "\n";
# close LOGSTMP;


open(LOGS,"+>>$FICHLOG") || die "problemas abriendo fichero de log $FICHLOG\n";

#print LOGS "FICHERO_OWM=";
print LOGS "==============================================================================================\n";
print LOGS "   yavire script for Tomcat Version $yavVersion (";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n\n";
print LOGS "      Command: $COMANDO\n";
print LOGS "      URL: $ADMINURL\n";
print LOGS "      Admin User: $USER_ADMIN\n"; 
print LOGS "      Admin Pass: $PASS_ADMIN\n";
print LOGS "      Instance: $NAME_INSTANCE\n";
print LOGS "      Domain: $DOMINIO_INSTANCIA\n";
print LOGS "      File Deploy: $FICHERO_DESPLIEGUE\n";
print LOGS "      URI: $URI\n";
print LOGS "      Installation User: $USER_INSTANCE\n";
print LOGS "      Instalation Directory: $DIR_BASE\n";
print LOGS "      Log: $FICHLOG\n";
print LOGS "      User Agent: [$USER_PROCESS]\n";
print LOGS "      User Instance: [$USER_INSTANCE}\n";
print LOGS "      Operation ID: [$ID_OPERACION]\n";
print LOGS "\n==============================================================================================\n\n";


if ( $USER_PROCESS eq $USER_INSTANCE) {
  print LOGS "The user agent and the instance is the same\n\n";
  $prefixCommand = "";
} 
else {
   if ( $USER_PROCESS eq "root") {
      print LOGS "The user agent is root. Change to $USER_INSTANCE\n\n";
      $prefixCommand = "su - $USER_INSTANCE ";
   }
   else {
      print LOGS "The user agent and the instance is not the same ...\n\n";
      $prefixCommand = "ssh -l $USER_INSTANCE localhost";
   }
}


$ENV{CATALINA_BASE}="${DIR_BASE}";
$ENV{CATALINA_HOME}="${DIR_BASE}";

print LOGS "CATALINA BASE: $ENV{CATALINA_BASE}\n";
print LOGS "CATALINA HOME: $ENV{CATALINA_HOME}\n";
print LOGS "JAVA HOME: $ENV{JAVA_HOME}\n";
print LOGS "\n==============================================================================================\n\n";

#print LOGS "Ejecutando comando $COMANDO en la instancia $NAME_INSTANCE \n";

$ApacheComm = lc $COMANDO;

for ($COMANDO) {
   if ((/Start/) or (/Stop/)) {
      
      $ENV{'JAVA_OPTS'} = '';
      $java_opts = $ENV{'JAVA_OPTS'};
      print LOGS "JAVA_OPTS=$java_opts\n";
      
      print LOGS "Command to execute: $prefixCommand ${DIR_BASE}/bin/catalina.sh ${ApacheComm}\n";
          
      my @output = `${prefixCommand} ${DIR_BASE}/bin/catalina.sh ${ApacheComm}`;
      chomp(@output); # removes newlines

      my $combined_line;

      foreach my $line(@output){
         $combined_line .= $line; # build a single string with all lines
      }
  
      print LOGS "\n>".$combined_line."<";
      
      sleep 5;
      
      #$salida=`"${DIR_BASE}"/bin/catalina.sh start >> $FICHLOGWL`;
      
   }
   elsif (/Restart/) {
      print LOGS "Ejecutando stop de la instancia $NAME_INSTANCE \n";
      print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . "\n";
   
      my @lines = qx/$DIR_BASE\/bin\/catalina.sh stop > $FICHLOG 2>&1/;
      foreach my $linea (@lines) {
         print LOGS "$linea\n";
      }
        
      print LOGS "Ejecutando start de la instancia $NAME_INSTANCE \n";
      print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . "\n";
   
      my @linesStart = qx/$DIR_BASE\/bin\/catalina.sh start > ${FICHLOG} 2>&1/;
      foreach my $linea (@linesStart) {
         print LOGS "$linea\n";
      }   
   }
   elsif (/Undeploy/) {
      print LOGS "Ejecutando despliegue de la instancia $NAME_INSTANCE \n";
      print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . "\n";
      
      $UNDEPLOY="wget --http-user=admweb --http-passwd=iwsadmin http://127.0.0.1:9010/manager/html/undeploy?path=/psv10";
      #$UNDEPLOY="wget  http://admweb:iwsadmin\@10.98.69.117:9010/manager/html/undeploy?path=/psv10";
      #$UNDEPLOY="wget http://admweb:iwsadmin\@10.98.69.117:9010/manager/list -O - -q";
      
      
      print  $UNDEPLOY;
      
      print  "\nPaso1\n";
      my @lines = qx/${UNDEPLOY}/;
      
      print  "Paso2\n";

      
      foreach my $linea (@lines) {
          print LOGS "$linea\n";
      }
      
      print  "Paso3\n";
      
     
         
   }
   elsif (/DeleteAppBase/) {
      print LOGS "Borrando appBase de la instancia $NAME_INSTANCE \n";
      print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . "\n";
      
           
     $directoryName = &getAppBase($DOMINIO_INSTANCIA, $URI);
     print LOGS "Directorio NAME: $directoryName  \n";
          
                
      if (-d $directoryName) {
         # directorio localhost existe
         
         chdir($directoryName);
         print LOGS "Borramos  el directorio $directoryName\n";
         #my @lines = qx/ls -l  $directoryName/;
         my @lines = qx/ls -l /;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
                 
            
         my @lines = qx/rm -rf */;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
         
         
      }
      elsif (-e $directoryName) {
         # Ruta localhost existe, pero no es un directorio
         print LOGS "ERROR: Ruta $directoryName existe, pero no es un directorio\n"
      }
      else {
         print LOGS "ERROR: Ruta $directoryName no existe\n"
      }
     
         
   }
   elsif (/DecompressWAR/) {
      print LOGS "Borrando appBase de la instancia $NAME_INSTANCE \n";
      print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . "\n";
      
           
     $directoryName = &getAppBase($DOMINIO_INSTANCIA, $URI);
     print LOGS "Directorio NAME: $directoryName  \n";
     
     $directoryAssemble = &getDirWar($DOMINIO_INSTANCIA, $URI);
     print LOGS "Directorio WAR: $directoryAssemble  \n";
    
      
                
      if (-d $directoryName) {
         # directorio localhost existe
         
         chdir($directoryName);
         
         
         print LOGS "Creamos el directorio de despliegue $URI\n";
         
         my @lines = qx/mkdir $URI/;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
         
         print LOGS "Copiamos el war $URI\n";
         
         my @lines = qx/cp $directoryAssemble\/$URI.war $directoryName\/$URI/;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
          
         print LOGS "Descomprimimos el war $URI\n";
         
         $directoryWAR = "$directoryName/$URI";
         
         chdir($directoryWAR);
         
         print LOGS "Estamos en el directorio  $directoryWAR\n";
         
         my @lines = qx/ls -l /;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
         
         print LOGS "Descomprimimos \n";
          
         my @lines = qx/\/opt\/krb\/yavire\/agent\/java\/bin\/jar xf $URI.war/;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
         
         print LOGS "Borramos el war \n";
         
         my @lines = qx/rm  $URI.war /;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         } 
            
         
         
      }
      elsif (-e $directoryName) {
         # Ruta localhost existe, pero no es un directorio
         print LOGS "ERROR: Ruta $directoryName existe, pero no es un directorio\n"
      }
      else {
         print LOGS "ERROR: Ruta $directoryName no existe\n"
      }
     
         
   }
   elsif (/CleanCache/) {
           
      $directoryName="${DIR_BASE}\/work\/Catalina\/localhost";
      
                
      if (-d $directoryName) {
         # directorio localhost existe
         
         chdir($directoryName);
         print LOGS "Borramos  el directorio $directoryName\n";
         #my @lines = qx/ls -l  $directoryName/;
         my @lines = qx/ls -l /;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
                 
            
         #my @lines = qx/rm -rf $directoryName/;
         my @lines = qx/rm -rf */;
         foreach my $linea (@lines) {
            print LOGS "$linea\n";
         }
      }
      elsif (-e $directoryName) {
         # Ruta localhost existe, pero no es un directorio
         print LOGS "Ruta $directoryName existe, pero no es un directorio\n"
      }
      else {
         print LOGS "Ruta $directoryName no existe\n"
      }
      
      
   }
   else {
       print LOGS "yavError: UNDEFINED OPERATION $COMANDO\n";
   }
   
}

print LOGS "$salida\n\n";

print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for Tomcat Version $yavVersion (";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n";

close LOGS;

# #OPEN FILE A.txt FOR APPENDING (CHECK FOR FAILURES)
# open ( FOO, ">>", $FICHLOG ) 
    # or die "Could not open file $FICHLOG $!";

# #OPEN FILE B.txt for READING (CHECK FOR FAILURES)
# open ( BAR, "<", $FICHLOGWL ) 
    # or die "Could not open file $FICHLOGWL $!";

# #READ EACH LINE OF FILE B.txt (BAR) and add it to FILE A.txt (FOO)
# while ( my $line = <BAR> ) {
  # print FOO $line;
# }

# close FOO;
# close BAR;

#==========================================================================================================
# Function definition
#==========================================================================================================

sub getAppBase{
   # get total number of arguments passed.
   local($dominio) = $_[0];
   local($uri) = $_[1];
   local($appBase) = "";
   
   # print LOGS "Entrando en getAppBase\n";
   # print LOGS "$dominio\n";
   # print LOGS "$uri\n";
   
   #TEMPORAL hasta que se lea del fichero 
   for ( $dominio) {
      if (/integracionGNF/) {
         $appBase="/soflib00/intgnf/$uri/webapps";
      }
      elsif (/produccionGNF/) {
         $appBase="/soflib00/prognf/$uri/webapps";
      } 
      else {
         print LOGS "ERROR: OPERACION NO DEFINIDA\n";
      }
         
   }
   
   #print LOGS "Saliendo de getAppBase ($appBase)\n ";
   
   return $appBase;
}


#==========================================================================================================
# Function definition
#==========================================================================================================

sub getDirWar{
   # get total number of arguments passed.
   local($dominio) = $_[0];
   local($uri) = $_[1];
   local($dirWar) = "";
   
   # print LOGS "Entrando en getAppBase\n";
   # print LOGS "$dominio\n";
   # print LOGS "$uri\n";
   
   #TEMPORAL hasta que se lea del fichero 
   for ( $dominio) {
      if (/integracionGNF/) {
         $dirWar="/soflib00/intgnf/$uri/assemble";
      }
      elsif (/produccionGNF/) {
         $dirWar="/soflib00/prognf/$uri/assemble";
      } 
      else {
         print LOGS "ERROR: OPERACION NO DEFINIDA\n";
      }
         
   }
   
   #print LOGS "Saliendo de getAppBase ($appBase)\n ";
   
   return $dirWar;
}

#==========================================================================================================
# End function definition
#==========================================================================================================

