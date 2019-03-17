#!/usr/bin/perl
use POSIX qw(strftime);

$yavVersion="2.2.0.2_2";

#Parametros:
#   - Comando a ejecutar (stop/start/restart)
#   - Propietario de la instancia
#   - Directorio base del apache
#   - Nombre de la instancia
#   - Numero de operacion

$ADMINURL="t3://$ARGV[0]${1}:$ARGV[1]";
$USER_ADMIN="$ARGV[2]";
$PASS_ADMIN="$ARGV[3]";
$COMANDO="$ARGV[4]";
$NAME_INSTANCE="$ARGV[5]";
$TIPO_INSTANCIA="$ARGV[6]";
$EXEC_NAME="$ARGV[7]";
$FICHERO_DESPLIEGUE="$ARGV[8]";
$URI="$ARGV[9]";
$ID_OPERACION="$ARGV[10]";
$USER_INSTANCE="$ARGV[11]";
#$DIR_BASE="$ARGV[12]";
$FILE_CONF="$ARGV[12]";
$DEPLOY_PROP="$ARGV[13]";
$SERVIDORES_CLUSTER="$ARGV[14]";
$SUBCOMANDO="$ARGV[15]";
$CLUSTER="$ARGV[16]";
$IS_APP="$ARGV[17]";
$SOFT_VERSION="$ARGV[18]";
$DIRLOG="/opt/krb/yavire/agent/webtools/operations/commands";

$USER_PROCESS=(getpwuid($<))[0];

$FICHLOG="$DIRLOG\/$ID_OPERACION\_$NAME_INSTANCE\_$COMANDO";

open(LOGS,"+>>$FICHLOG") || die "problemas abriendo fichero de log $FICHLOG\n";

print LOGS "==============================================================================================\n";
print LOGS "   yavire script for Apache Version $yavVersion\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n\n";
print LOGS "      Command: $COMANDO\n";
print LOGS "      URL: $ADMINURL\n";
print LOGS "      Admin User: $USER_ADMIN\n"; 
#print LOGS "      Admin Pass: $PASS_ADMIN\n";
print LOGS "      Instance: $NAME_INSTANCE\n";
print LOGS "      Executable: $EXEC_NAME\n";
print LOGS "      File Deploy: $FICHERO_DESPLIEGUE\n";
print LOGS "      URI: $URI\n";
print LOGS "      Installation User: $USER_INSTANCE\n";
print LOGS "      Configuration File: $FILE_CONF\n";
print LOGS "      Apache Version: $SOFT_VERSION\n";
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

$ApacheComm = lc $COMANDO;


for ($COMANDO) {
   if ((/Start/) or (/Stop/) or (/Restart/)) {
      
          #print LOGS "Command to execute: $prefixCommand ${DIR_BASE}/bin/apachectl start\n";
      print LOGS "Command to execute: $prefixCommand ${EXEC_NAME} -f  ${FILE_CONF} -k ${ApacheComm}\n";

      #my @output = `$prefixCommand ${DIR_BASE}/bin/apachectl start`;
      my @output = `$prefixCommand ${EXEC_NAME} -f  ${FILE_CONF} -k ${ApacheComm}`;
      chomp(@output); # removes newlines

      my $combined_line;

      foreach my $line(@output){
         $combined_line .= $line; # build a single string with all lines
      }
  
      print LOGS "\n>".$combined_line."<";
      
      sleep 5;
      
   }
   else {
      print LOGS "yavError: UNDEFINED OPERATION $COMANDO\n";
   }
   
}

print LOGS "$salida\n\n";

print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for Apache Version $yavVersion\n";
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


