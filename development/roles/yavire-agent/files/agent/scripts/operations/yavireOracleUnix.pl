#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

$yavVersion="2.1.0.2_16";

#* NombreFichero: yavireOracleUnix.pl
#*=========================================================
#* Fecha Creación: [31/03/2014]
#* Autor: Fernando Oliveros
#* Compañia: kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Operaciones sobre Oracle 12/11/10
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


#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

$ADMINURL="t3://$ARGV[0]${1}:$ARGV[1]";
$USER_ADMIN="$ARGV[2]";
$PASS_ADMIN="$ARGV[3]";
$COMANDO="$ARGV[4]";
$NAME_INSTANCE="$ARGV[5]";
$TIPO_INSTANCIA="$ARGV[6]";
$DOMINIO_INSTANCIA="$ARGV[7]";
$DIRECTORIO_FICH_SQL="$ARGV[8]";
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
$restore = "$ARGV[19]"; 

$DIRLOG="/opt/krb/yavire/agent/webtools/operations/commands";
$USER_PROCESS=(getpwuid($<))[0];
$FICHLOG="$DIRLOG\/$ID_OPERACION\_$NAME_INSTANCE\_$COMANDO";



#*===========================================================
#* Cuerpo del programa 
#*===========================================================

open(LOGS,"+>>$FICHLOG") || die "Cannot open the log file: $FICHLOG\n";

$fecha=yavireUnix::formatoFechaLog();

print LOGS "==============================================================================================\n";
print LOGS "   yavire script for Oracle - Version $yavVersion [$fecha]\n";
print LOGS "\n==============================================================================================\n\n";
print LOGS "      Command: $COMANDO\n";
#print LOGS "      URL: $ADMINURL\n";
print LOGS "      Database User: $USER_ADMIN\n"; 
# print LOGS "      Admin Pass: $PASS_ADMIN\n";
print LOGS "      Instance: $NAME_INSTANCE\n";
#print LOGS "      SQL Directory Files: $DIRECTORIO_FICH_SQL\n";
print LOGS "      TNS: $URI\n";
print LOGS "      Installation User: $USER_INSTANCE\n";
print LOGS "      yavire agent User: " . (getpwuid($<))[0] . "\n";
print LOGS "      Instalation Directory: $DIR_BASE\n";
print LOGS "      User Process: $USER_PROCESS\n";
print LOGS "      Restore: $restore\n";
print LOGS "      Log: $FICHLOG\n";
print LOGS "      Id. Operation : $ID_OPERACION\n";
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

$ENV{LD_LIBRARY_PATH}="/opt/krb/yavire/agent/sqlclient";

print LOGS "LD_LIBRARY_PATH: $ENV{LD_LIBRARY_PATH}\n\n";

$sqlplus="$ENV{LD_LIBRARY_PATH}/sqlplus -L -S ";

my $connect_string = "$USER_ADMIN\/$PASS_ADMIN\@'$URI'";
my $connect_stringShow = "$USER_ADMIN\/*********\@'$URI'";

my $substr="ORA-";

for ($COMANDO) {
   if (/Deploy/) {
          
      if (-d $DIRECTORIO_FICH_SQL) {
         
         
         opendir (my $DIR, "$DIRECTORIO_FICH_SQL") || die "Error while opening $DIRECTORIO_FICH_SQL: $!\n";
         
         my $iSQLDirEmpty  = 1;
         
         foreach my $file(sort readdir $DIR) {
            
            # Only files
            next unless (-f "$DIRECTORIO_FICH_SQL/$file");
            
            # Use a regular expression to find files ending in .sql
            next unless ($file =~ m/.sql$/);
            
            $fileOK = 0;
            
            if ($restore eq 0) {
                if ($file =~ /^\d/) {
                   if ($file !~ /restore/) {
                      $fileOK = 1;
                   }
                }
               
            }
            else {
               #Si es un restore, sfiltarmos por los que contengas restore y comiencen por un número
               if ($file =~ /^\d/) {
                   if ($file =~ /restore/) {
                      $fileOK = 1;
                   }
                }
            }
            
            my $iTieneErrores = 0;
            $iSQLDirEmpty  = 0;
            
            #print LOGS"$file\n";
            
            my $dbFileToExecute = "$DIRECTORIO_FICH_SQL/$file";
            
            if ($fileOK eq 1) {
            
               print LOGS "\n----------------------------------------------------------------------------------------------------------------------\n";
               print LOGS "           Executing $dbFileToExecute\n\n";
               print LOGS "           Directory: $DIRECTORIO_FICH_SQL\n";
               print LOGS "----------------------------------------------------------------------------------------------------------------------\n\n";
            
            
               $comandoSQL="exit | ${sqlplus} ${connect_string} \@$dbFileToExecute";
               $comandoSQLShow="exit | ${sqlplus} ${connect_stringShow} \@$dbFileToExecute";
               print LOGS "Command to execute:  $comandoSQLShow\n";     
               
               my @lines = qx/${comandoSQL}/;
                  
               foreach my $linea (@lines) {
                  print LOGS "$linea";
                  
                  if (index($linea, $substr) != -1) {
                     #print LOGS "CHUNGO: $linea contiene $substr\n";
                     $iTieneErrores = 1;
                  }  
                  
               }
              
               print LOGS "\n\n----------------------------------------------------------------------------------------------------------------------\n"; 
               
               if ($iTieneErrores eq 1) {
                   print LOGS "           $dbFileToExecute has finished with errors. System stops execution\n";
                   last;
               }
               else {
                   
                   print LOGS "           $dbFileToExecute has finished successfully\n";   
               }
               
               print LOGS "----------------------------------------------------------------------------------------------------------------------\n\n";
               
            }
            else {
               
                if ($restore eq 0) {
                   
                  
                   if ($file !~ /restore/) {
                      print LOGS "\n----------------------------------------------------------------------------------------------------------------------\n";
                      print LOGS "           File  $file\n\n";
                      print LOGS "           File doesn't start with a number\n";
                   }
                   print LOGS "----------------------------------------------------------------------------------------------------------------------\n\n";
                   
                  
                }
                else {
                   
                   print LOGS "\n----------------------------------------------------------------------------------------------------------------------\n";
                   print LOGS "           File  $file\n\n";
                
                   print LOGS "           File doesn't start with a number and doesn't contain the word restore\n";
                   print LOGS "----------------------------------------------------------------------------------------------------------------------\n\n";
                }
               

               
            }
            
         }

         closedir($DIR);
         
         if ($iSQLDirEmpty eq 1) {
            print LOGS " yavWarning: Directory $DIRECTORIO_FICH_SQL has not sql files.\n"; 
         }
         

      }
      else {
         print LOGS  "yavError: Directory $DIRECTORIO_FICH_SQL doesn't exist.\n";   
         
      }
   
   }
   elsif (/Test/)  {
       
        print LOGS "\n----------------------------------------------------------------------------------------------------------------------\n";
            print LOGS "    Executing SQL Test\n\n";
            print LOGS "        SQL Test: $DIRECTORIO_FICH_SQL\n\n";
            print LOGS "----------------------------------------------------------------------------------------------------------------------\n\n";
            


            $comandoSQL="exit | echo \"$DIRECTORIO_FICH_SQL;\" | ${sqlplus} ${connect_string}";
            #print LOGS "Command to execute:  $comandoSQL\n";     
            
            my @lines = qx/${comandoSQL}/;
               
            foreach my $linea (@lines) {
               print LOGS "$linea";
               
               if (index($linea, $substr) != -1) {

                  $iTieneErrores = 1;
               }  
               
            }
           
            print LOGS "\n\n----------------------------------------------------------------------------------------------------------------------\n"; 
            
            if ($iTieneErrores eq 1) {
                print LOGS "           SQL Test has finished with errors.\n";   
            }
            else {
                
                print LOGS "           SQL Test has finished successfully\n";   
            }
            
            print LOGS "----------------------------------------------------------------------------------------------------------------------\n\n";
            
   }
   else {
      print LOGS "yavError: UNDEFINED COMMAND $COMANDO\n";
  }     
} 
      
print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for Oracle Version $yavVersion [$fecha]\n";
print LOGS "\n==============================================================================================\n";

close LOGS;
#*===========================================================
#* Fin script: openWebOracleUnix.pl]
#*===========================================================




