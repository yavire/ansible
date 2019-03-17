#!/usr/bin/perl
#use lib '/opt/krb/yavire/agent/perl/lib/perl5/site_perl/5.8.8';
use lib '/opt/krb/yavire/agent/perl/lib';
use Shell::Source;
use POSIX qw(strftime);

$yavVersion="2.2.0.2_18";

#Parametros:
#   - IP Consola
#   - Puerto Consola
#   - Usuario consola
#   - Password Consola
#   - Comando
#   - Instancia
#   - Operacion bloqueante (block/noblock)
#   - Dominio
#   - FICHERO DE DESPLIEGUE (incluida la ruta)
#   - URI de la aplicacion
#   - Numero de operacion
#   - Usuario de instalacion
#   - Directorio base del dominio
#   - Propiedades del despliegue

$WLHOME="/opt/weblogic/wlserver_10.3";   # Buscarlo
$FPYTHON="/opt/krb/yavire/agent/scripts/operations/yavireWeblogicOperationsWLST.py"; # Fichero python
$ADMINURL="t3://$ARGV[0]${1}:$ARGV[1]";
$USER_ADMIN="$ARGV[2]";
$PASS_ADMIN="$ARGV[3]";
$COMANDO_ORIG="$ARGV[4]";
$NAMEINSTANCIA="$ARGV[5]";
$OP_BLOQ="$ARGV[6]";
$DOMINIO_INSTANCIA="$ARGV[7]";
$FICHERO_DESPLIEGUE="$ARGV[8]";
$URI="$ARGV[9]";
$ID_OPERACION="$ARGV[10]";
$USER_INSTANCE="$ARGV[11]";
$DIR_BASE="$ARGV[12]";
$DEPLOY_PROP="$ARGV[13]";
$SERVIDORES_CLUSTER="$ARGV[14]";
$SUBCOMANDO="$ARGV[15]";
$CLUSTER="$ARGV[16]";
$IS_APP="$ARGV[17]";
$SOFT_VERSION="$ARGV[18]";
$DIRLOG="/opt/krb/yavire/agent/webtools/operations/commands";
$USER_PROCESS=(getpwuid($<))[0];

$FICHLOG="$DIRLOG\/$ID_OPERACION\_$NAMEINSTANCIA\_$COMANDO_ORIG";
$FICHLOGWL="${FICHLOG}_tmp";

open(LOGS,">$FICHLOG") || die "Cannot open the log file: $FICHLOG\n";

#En el parametro comando se elimina lo que esta a la derecha del _ 

my @aComandos = split('_', $COMANDO_ORIG);
$COMANDO=$aComandos[0];


print LOGS "==============================================================================================\n";
print LOGS "   yavire script for Weblogic 12c $yavVersion (";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n\n";
print LOGS "      Command: $COMANDO_ORIG\n";
print LOGS "      SubCommand: $COMANDO\n";
print LOGS "      Block type: $OP_BLOQ\n";
print LOGS "      URL: $ADMINURL\n";
print LOGS "      Admin User: $USER_ADMIN\n"; 
print LOGS "      Admin Pass: $PASS_ADMIN\n";
print LOGS "      Instance: $NAMEINSTANCIA\n";
print LOGS "      Cluster: ($CLUSTER)\n";
print LOGS "      Domain: $DOMINIO_INSTANCIA\n";
print LOGS "      File Deploy: $FICHERO_DESPLIEGUE\n";
print LOGS "      isAPP: $IS_APP\n";
print LOGS "      URI: $URI\n";
print LOGS "      Installation User: $USER_INSTANCE\n";
print LOGS "      Instalation Directory: $DIR_BASE\n";
print LOGS "      User Process: $USER_PROCESS\n";
print LOGS "      Log: $FICHLOG\n";
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

# if ( $USER_PROCESS eq $USER_INSTANCE) {
 # print LOGS "Usuarios iguales\n";
# }
# else {
 # print LOGS "Usuarios distintos, hacemos sudo\n";
# }


#Buscamos el WL_HOME, utilizando el DIR_BASE
$salida=`cat ${DIR_BASE}/bin/setDomainEnv.sh | grep WL_HOME= 2>&1`;
if ($salida=~ /WL_HOME=/) {
   #print "\nSALIDA WL_HOME: $salida\n";
   $salida=~ m/WL_HOME=\"(.*)\"/;
   #print "Mi clave es: $1\n";
   $WLHOME=$1;
   
} else  {		
   print LOGS "\nyavERROR: We have not obtained the WL_HOME\n";
   exit 1;
}

print LOGS "Weblogic Home: $WLHOME\n\n";

#@envvar = `csh -c " source $WLHOME/server/bin/setWLSEnv.sh  ; env"`;

my $csh = Shell::Source->new(shell => "sh", file => "$WLHOME/server/bin/setWLSEnv.sh");
$csh->inherit;

#print STDERR $csh->output;
#print $csh->shell;

#print "WEBLOGIC-CLASSPATH: $ENV{WEBLOGIC_CLASSPATH}\n";
#print "JAVA-HOME: $ENV{JAVA_HOME}\n";

for ($COMANDO) {
   if ((/Deploy/) or (/Undeploy/) or (/Stop/) or (/Start/)) {
      
      `$ENV{JAVA_HOME}/bin/java -cp $ENV{WEBLOGIC_CLASSPATH} weblogic.WLST $FPYTHON $USER_ADMIN $PASS_ADMIN $COMANDO $NAMEINSTANCIA $ADMINURL $FICHLOG $FICHERO_DESPLIEGUE $URI $OP_BLOQ $CLUSTER $IS_APP >> $FICHLOGWL`;
      
      sleep 10;
            
   }
   elsif (/CleanCache/)  {
      
      open(LOGSWL,">$FICHLOGWL") || die "Problems opening log file: $FICHLOGWL\n";
      print LOGSWL "\n";
      close LOGSWL; 
      
      #my @values = split('@', $DEPLOY_PROP, 2);

      #Borramos temporales...
      #if ($values[0] ==  1) {
         print LOGS "Delete temporary files\n";
          $directoryName="${DIR_BASE}\/servers\/${NAMEINSTANCIA}\/tmp";
            
            if (-d $directoryName) {
               # directorio tmp existe
               
               chdir($directoryName);
               
               print LOGS "Occupied directory space $directoryName\n";
               my @lines = qx/du -sh */;
               foreach my $linea (@lines) {
                  print LOGS "$linea\n";
               }
               
               print LOGS "Number of files in  $directoryName\n";
               my @lines = qx/find . -type f | wc -l/;
               foreach my $linea (@lines) {
                  print LOGS "$linea\n";
               }
               
               print LOGS "Delete the directory $directoryName\n";
               my @lines = qx/ls -l/;
               foreach my $linea (@lines) {
                  print LOGS "$linea\n";
               }
            
               #my @lines = qx/rm -rf */;
               my @lines = qx/ find . ! -name "*.lok" -exec rm -r {} \\;/;
               foreach my $linea (@lines) {
                  print LOGS "$linea\n";
               }
            }
            elsif (-e $directoryName) {
               # Ruta tmp existe, pero no es un directorio
               print LOGS "Path $directoryName doesn't exist, but it's not a directory\n"
            }
            else {
                print LOGS "Path $directoryName doesn't exist\n"
            }
            
         #my @servidores = split('@', $SERVIDORES_CLUSTER);
         #foreach my $val (@servidores) {
           
           
         #}
            
      #} else {
      #   print "No borramos temporales\n";
      #}
            
           
   }
   elsif ((/WeblogicEstadoClusterAdmin/) or (/testServer/)) {
      print LOGS "TEST DEL  CLUSTER\n";
    
      `$ENV{JAVA_HOME}/bin/java -cp $ENV{WEBLOGIC_CLASSPATH} weblogic.WLST $FPYTHON $USER_ADMIN $PASS_ADMIN $COMANDO $NAMEINSTANCIA $ADMINURL $FICHLOG $FICHERO_DESPLIEGUE $URI $OP_BLOQ >> $FICHLOGWL`;
   }
   else {
      print LOGS "yavError: UNDEFINED OPERATION $COMANDO\n";
  }     
} 


print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for Weblogic11 Version $yavVersion (";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n";

close LOGS;

#OPEN FILE A.txt FOR APPENDING (CHECK FOR FAILURES)
open ( FOO, ">>", $FICHLOG ) 
    or die "Could not open file $FICHLOG $!";

#OPEN FILE B.txt for READING (CHECK FOR FAILURES)
open ( BAR, "<", $FICHLOGWL ) 
    or die "Could not open file $FICHLOGWL $!";

#READ EACH LINE OF FILE B.txt (BAR) and add it to FILE A.txt (FOO)
while ( my $line = <BAR> ) {
  print FOO $line;
}

close FOO;
close BAR;

