#!/usr/bin/perl

use POSIX qw(strftime);

$owmVersion="2.1.0.0_1";

#Parametros:
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
#$FICHLOGTMP="${FICHLOG}_tmp";

# open(LOGSTMP,">$FICHLOGWL") || die "problemas abriendo fichero de log $FICHLOG\n";
# print LOGSTMP "\n";
# close LOGSTMP;


open(LOGS,"+>>$FICHLOG") || die "problemas abriendo fichero de log $FICHLOG\n";

#print LOGS "FICHERO_OWM=";
print LOGS "==============================================================================================\n";
print LOGS "   yavire script for Agente Version $owmVersion (";
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
print LOGS "\n==============================================================================================\n\n";


$ENV{CATALINA_BASE}="${DIR_BASE}";
$ENV{CATALINA_HOME}="${DIR_BASE}";

print LOGS "CATALINA BASE: $ENV{CATALINA_BASE}\n";
print LOGS "CATALINA HOME: $ENV{CATALINA_HOME}\n";
print LOGS "\n==============================================================================================\n\n";

#print LOGS "Ejecutando comando $COMANDO en la instancia $NAME_INSTANCE \n";


for ($COMANDO) {
   if (/AgenteParar/) {
      
      my @output = `/opt/krb/yavire/agent/scripts/agent/yavireStopAgent.sh`;
      chomp(@output); # removes newlines

      my $combined_line;

      foreach my $line(@output){
         $combined_line .= $line; # build a single string with all lines
      }
      
      print LOGS ">HOLA".$combined_line."<";
      
      sleep 5;
      
      
   }
   elsif (/AgenteCleanCache/) {
           
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
                 
            
         my @lines = qx/rm -rf $directoryName/;
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
      print LOGS "ERROR: OPERACION NO DEFINIDA\n";
   }
   
}

print LOGS "$salida\n\n";

print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for Agent Version $owmVersion (";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n";

close LOGS;


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

