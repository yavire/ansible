#!/usr/bin/perl
use POSIX qw(strftime);
#use IO::Compress::Zip qw(:all);


if ($^O =~ /Win/) {
  eval "use List::Util qw(first)";
  eval "use Archive::Zip qw(:ERROR_CODES :CONSTANTS)";
  eval "use File::Copy qw(copy)";
}
 


#* NombreFichero: yavireGetConfVariables.pl
#*=========================================================
#* Fecha Creación: [25/02/2018]
#* Autor: Fernando Oliveros
#* Compañia: Yavire
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Backup de Ficheros
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

$versionYAV = '2.2.0.2_3';

#Se añade dos puntos al parametro
$SourceServerName = "$ARGV[0]"; 
$szSourceDir = "$ARGV[1]";

$baseAgentDirWin="C:\\krb\\yavire\\agent";
$baseAgentDirUnix="/opt/krb/yavire/agent";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

#$datelog="DDDDDD";
#$datelog=yavire21::formatoFechaLog();

if ($^O =~ /Win/) {
    $USER_PROCESS = $ENV{USERNAME};
}
else {
   $USER_PROCESS=(getpwuid($<))[0];
}

print "\n==============================================================================================\n";
print "   yavire get configuration variables - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n\n";
print "        Source Server User: $USER_PROCESS\n";
print "        Source Server Name: $SourceServerName\n";
print "        Source Directory: $szSourceDir\n"; 
print "\n==============================================================================================\n\n";

$outputFT="{*";

opendir(DIR, $szSourceDir) or die $!;

$fileVars="{*";

while (my $file = readdir(DIR)) {

    # Use a regular expression to ignore files beginning with a period
    next if ($file =~ m/^\./);

    print "$file\n";
        
    if ($^O =~ /Win/) {
       $fileAndDir="$szSourceDir\\$file"; 
    }
    else {
       $fileAndDir="$szSourceDir/$file"; 
    }
       
     
    #open my $in, "<:encoding(utf8)", $fileAndDir or die "$fileAndDir $!";
    open(FICH,"<$fileAndDir")  || die "Error to open file $fileAndDir\n";
    $i = 1;
    while (my $line = <FICH>) {
        chomp $line;
        
         print "Hello($i): $line\n";
         
         
         my @tokens=split (/{%/,$line);
            
         my $size = @tokens;
         print "TAMANNO: $size\n";
       
         if ($size > 2) {
            #Tenemos mas de una variable en la linea
            for ($m = 0; $m <= $#tokens; $m++) {
               my $line2Tmp="$tokens[$m]";
               print "Hola4: $line2Tmp\n";
               
                if ( $line2Tmp =~ /(.+)%}/s ) { 
                   print "Found |$1| between titles.\n";
                   $outputFT .= "$file,$1;";
                }
               
          
          
            }
                
         }
         else {
            
           if ( $line =~ /{%(.+)%}/s ) { 
              #print "Found |$1| between titles.\n";
              $outputFT .= "$file,$1;";
           }
         }
         $i++;
        # ...
    }
    close FICH;
   

}

closedir(DIR);

$outputFT .= "*}";

print "$outputFT\n";

sleep(2);


#$datelog=yavire21::formatoFechaLog();
print "\n\n==============================================================================================\n";
print "    Finishing yavire get configuration variables - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n";

#*===========================================================
#* Fin script: yavireSoftwareTransfer.pl]
#*===========================================================


