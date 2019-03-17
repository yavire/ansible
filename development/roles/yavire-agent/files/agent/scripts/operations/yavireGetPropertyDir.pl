#!/usr/bin/perl
use POSIX qw(strftime);
#use IO::Compress::Zip qw(:all);


if ($^O =~ /Win/) {
  eval "use List::Util qw(first)";
  eval "use Archive::Zip qw(:ERROR_CODES :CONSTANTS)";
  eval "use File::Copy qw(copy)";
  eval "use Win32::API";
  eval "use Win32::OLE qw(in with)";
  
}
 


#* NombreFichero: yavireGetPropertyDir.pl
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

$versionYAV = '2.2.0.2_2';

#Se añade dos puntos al parametro
$szDirectory = "$ARGV[0]"; 

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
print "   yavire get Directory Property - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n\n";
print "        Source Server User: $USER_PROCESS\n";
print "        Directory: $szDirectory\n";
print "\n==============================================================================================\n\n";

 if ($^O =~ /Win/) {
     # use Win32::OLE;
     
     # # ( $os_version, $os_level, $os_build) = getVersionOS();
     
 
    
     # # my $Filepath = $_[0];
     # # my $Filename = $_[1];
     
     # # $Filepath =~ s/\//\\/g;
     
     # # print "FilePath: $Filepath\n";
     # # print "Filename: $Filename\n";

     # my $objShell = Win32::OLE->new("Shell.Application"); 
     # my $objFolder=$objShell->Namespace($Filepath);

     # my $attributes = $objFolder->ParseName($Filename);

     # $Fileowner=$objFolder->GetDetailsOf($attributes, 10);

     # print "Info : Owner of the file is $Fileowner";  

 }
 else {
    
    if (-d $szDirectory) {
      $Uid = (stat($szDirectory))[4];
      $UserName = ( getpwuid( $Uid ))[0];
   } else {
      $UserName = "Dir Error ";
   }
    
    
 }

print "<Owner>$UserName<\/Owner>";

#$datelog=yavire21::formatoFechaLog();
print "\n\n==============================================================================================\n";
print "    Finishing get Directory Property - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n";

#*===========================================================
#* Fin script: yavireGetPropertyDir.pl]
#*===========================================================


