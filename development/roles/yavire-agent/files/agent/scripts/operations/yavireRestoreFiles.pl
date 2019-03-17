#!/usr/bin/perl
use POSIX qw(strftime);
#use IO::Compress::Zip qw(:all);


if ($^O =~ /Win/) {
  eval "use List::Util qw(first)";
  eval "use Archive::Zip qw(:ERROR_CODES :CONSTANTS)";
  eval "use File::Copy qw(copy)";
}
 


#* NombreFichero: yavireRestoreFiles.pl
#*=========================================================
#* Fecha Creación: [19/02/2018]
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

$versionYAV = '2.2.0.2_7';

#Se añade dos puntos al parametro
$SourceServerName = "$ARGV[0]"; 
$szSourceDir = "$ARGV[1]";
$szSourceDirWin = "$ARGV[2]";
$szDeployFile = "$ARGV[3]";
$szDirDestiny = "$ARGV[4]"; 
$typePermissions = "$ARGV[5]"; 
$mirror = "$ARGV[6]"; 
$CopyContentDirectory = "$ARGV[7]"; 
$codFileTransfer = "$ARGV[8]"; 
$codOperationFT = "$ARGV[9]"; 

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
print "   yavire Restore Files - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n\n";
print "        Source Server User: $USER_PROCESS\n";
print "        Source Server Name: $SourceServerName\n";
print "        Source Directory: $szSourceDir\n"; 
if ($^O =~ /Win/) {
    print "        Source Directory for Windows: $szSourceDirWin\n"; 
}
print "        Files: $szDeployFile\n";
print "        Target Directory: $szDirDestiny\n";
print "        Permissions Type (755/750): $typePermissions\n";
print "        Mirror: $mirror\n";
print "        Directory content or Directory: $CopyContentDirectory\n";
print "        File Transfer Code: $codFileTransfer\n";
print "        Operation Code: $codOperationFT\n";
print "\n==============================================================================================\n\n";


if ($typePermissions eq 0) {
   #755
   $PERMISOS="u+rwx,g+rx,g-w,o+rx,o-w";
}
else {
   #750
   $PERMISOS="u+rwx,g+rx,g-w,o-rwx";
}




#/************BACKUPS******/

if ($^O =~ /Win/) {
    $dirBackup="$baseAgentDirWin\\backupsFT\\$codFileTransfer\\$codOperationFT"; 
}
else {
    $dirBackup="$baseAgentDirUnix/backupsFT/$codFileTransfer/$codOperationFT"; 
}

#Generamos directorio de restores
if ($^O =~ /Win/) {
   $dirRestore="$baseAgentDirWin\\restores\\$codFileTransfer"; 
}
else {
   $dirRestore="$baseAgentDirUnix/restores/$codFileTransfer"; 
}
   
if (-d $dirRestore) {
   print LOG "The directory  $dirRestore exists\n";
} 
else {
   print "Creating  $dirRestore directory\n";
}
   
   
if ($^O =~ /Win/) {
   system 1, "mkdir $dirRestore";
}
else {
   `mkdir \-p $dirRestore`;
}
    
sleep 4;
   
   
#Si el valor viene con *, son transferencias de directorios y no de ficheros de despliegues
#Si son ficheros, se hace un zip o tar, en caso contrario, una copia del war/ear
if ($szDeployFile eq "*") {
 
   if ($^O =~ /Win/) {
      
      $source = "$dirBackup\\$codFileTransfer-$codOperationFT.zip";
      copy($source,$dirRestore) or print  "yavError: Copy failed";
      
      $obj = Archive::Zip->new();   # new instance
      $status = $obj->read($source);  # read file contents

      if ($status != AZ_OK) {
         print  "\n-----------------------------------------------------------------------------------------------------\n";
         print  "      Restore error:    $dirRestore\n";
         print  "-----------------------------------------------------------------------------------------------------\n\n";
      } else {
         print "$dirRestore\n";
         $obj->extractTree(undef, "$dirRestore\\");    # extract files
         
         unlink "$dirRestore\\$codFileTransfer-$codOperationFT.zip";
         
         print  "\n-----------------------------------------------------------------------------------------------------\n";
         print  "      Restore successfully...\n";
         print  "      Source:    $source\n";
         print  "      Target:    $dirRestore\n";
         print  "-----------------------------------------------------------------------------------------------------\n\n";

         
      } 
   }
   else {
      
      $source = "$dirBackup/$codFileTransfer-$codOperationFT.tar";
      
      print  "\n-----------------------------------------------------------------------------------------------------\n";
      print  "      Backup Directory:  $dirBackup\n";
      print  "      Source:    $source\n";
      print  "      Target:    $dirRestore\n";
      print  "-----------------------------------------------------------------------------------------------------\n\n";
      
     #Copiamos el fichero comprimido al directorio de retstore
     $salida=`cp -p $source $dirRestore 2>&1`;
     
     if ($salida=~ /No such/i) {
          print "\n $salida\n";
     }
     
     #Nos movemos al directorio de restore
     chdir($dirRestore);  
     
     #Descomprimimos el fichero en el directorio de restore 
     $fich_tar="$codFileTransfer-$codOperationFT.tar";
     print "            Executing tar xvf ${fich_tar}\n\n";
        
     `tar xvf "${fich_tar}" 2> /dev/null`;
      
      if ($salida=~ /No such/i) {
             print "\nERROR: $salida\n";
             print LOGS "\nERROR: $salida\n";
      } 
      
     `rm "${fich_tar}" 2> /dev/null`; 
      
       
   }
    
}
else {
    
    if ($^O =~ /Win/) {
       
        $source = "$dirBackup\\$szDeployFile";
        
         print  "\n-----------------------------------------------------------------------------------------------------\n";
         print  "      Restore deploy file...\n";
         print  "      Source:    $source\n";
         print  "      Target:    $target\n";
         print  "-----------------------------------------------------------------------------------------------------\n\n";
        
        copy($source,$dirRestore) or print  "yavError: Copy failed";
    }
    else {
        $source = "$dirBackup/$szDeployFile";
        
        print  "\n-----------------------------------------------------------------------------------------------------\n";
        print  "      Restore deploy file...\n";
        print  "      Source:    $source\n";
        print  "      Target:    $target\n";
        print  "-----------------------------------------------------------------------------------------------------\n\n";
        
        $salida=`cp -p $source $dirRestore 2>&1`;
        if ($salida=~ /No such/i) {
             print "\n $salida\n";
        }
        
    }
    
}
  

#$datelog=yavire21::formatoFechaLog();
print "\n\n==============================================================================================\n";
print "    Finishing yavire restore  Files - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n";

#*===========================================================
#* Fin script: yavireSoftwareTransfer.pl]
#*===========================================================


