#!/usr/bin/perl
use POSIX qw(strftime);
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
binmode STDIN, ":utf8";
#use IO::Compress::Zip qw(:all);


if ($^O =~ /Win/) {
  eval "use List::Util qw(first)";
  eval "use Archive::Zip qw(:ERROR_CODES :CONSTANTS)";
  eval "use File::Copy qw(copy)";
}
 


#* NombreFichero: yavireSaveFTMappings.pl
#*=========================================================
#* Fecha Creación: [27/02/2018]
#* Autor: Fernando Oliveros
#* Compañia: Yavire
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*   Almacena las variables de mapping
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

$versionYAV = '2.2.0.2_6';

#Se añade dos puntos al parametro
$SourceServerName = "$ARGV[0]"; 
$szMappings = "$ARGV[1]";
$codFileTransfer = "$ARGV[2]"; 


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
print "   yavire save FT Mappings - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n\n";
print "        Source Server User: $USER_PROCESS\n";
print "        Source Server Name: $SourceServerName\n";
print "        File Transfer Code: $codFileTransfer\n";
print "\n==============================================================================================\n\n";


#Generamos directorio de Mappings
if ($^O =~ /Win/) {
   $dirMapping="$baseAgentDirWin\\mappingsFT\\$codFileTransfer\\$codOperationFT"; 
}
else {
   $dirMapping="$baseAgentDirUnix/mappingsFT/$codFileTransfer/$codOperationFT/"; 
}
   
if (-d $dirMapping) {
   print LOG "The directory  $dirMapping exists\n";
} 
else {
   print "Creating  $dirMapping directory\n";
   
   
   if ($^O =~ /Win/) {
      system 1, "mkdir $dirMapping";
   }
   else {
      `mkdir \-p $dirMapping`;
   }
       
   sleep 4;
   
   
} 

$outputFT="{*";

$file="yavFTMapping.txt";

if ($^O =~ /Win/) {
   $fileAndDir="$dirMapping\\$file"; 
}
else {
   $fileAndDir="$dirMapping/$file"; 
}


open(my $fh, "> :encoding(UTF-8)", $fileAndDir) or die "Could not open file '$fileAndDir' $!";
print $fh "$szMappings\n";
close $fh;
print "done\n";
print "$szMappings\n";



#$datelog=yavire21::formatoFechaLog();
print "\n\n==============================================================================================\n";
print "    Finishing yavire ave FT Mappings - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n";

#*===========================================================
#* Fin script: yavireSaveFTMappings.pl]
#*===========================================================


