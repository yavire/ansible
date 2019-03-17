#!/usr/bin/perl


#* NombreFichero: yavireFileSystemOccupation.pl
#*=========================================================
#* Fecha Creación: [17/03/2014]
#* Autor: Fernando Oliveros
#* Compañia: kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Devuelve la ocupación de un FileSystem
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

$versionYAV = '2.2.0.1_4';
 
#Se añade dos puntos al parametro
$parFileSystem="$ARGV[0]";

# $parametroDF="df -kP ${parFileSystem}";

# print "Parametro: $parametroDF\n";

# % df -kP /opt/admweb
# Filesystem    1024-blocks      Used Available Capacity Mounted on
# /dev/admweb       1048576    425328    623248      41% /opt/admweb

# $ df -kP /
# Filesystem         1024-blocks      Used Available Capacity Mounted on
# /dev/mapper/VolGroup00-LogVol00  15236080   3706856  10742792      26% /

#*===========================================================
#* Cuerpo del programa 
#*===========================================================



   my $osname = $^O;

   if( $osname eq 'linux' ) {
   
      $fsAssign = `df -kP $parFileSystem | grep '$parFileSystem' | awk '{print \$2}'`; #Capacity
      $fsUsed = `df -kP $parFileSystem | grep '$parFileSystem' | awk '{print \$3}'`; #Used
      $fsAvailable = `df -kP $parFileSystem | grep '$parFileSystem' | awk '{print \$4}'`; #Available
      $fsCapacity = `df -kP $parFileSystem | grep '$parFileSystem' | awk '{print \$5}'`; #Porcentaje
   
   }
   else {
      $fsAssign = `df $parFileSystem | grep '$parFileSystem' | awk '{print \$1}'`;
      $fsUsed = `df $parFileSystem | grep '$parFileSystem' | awk '{print \$2}'`;
      $fsAvailable = `df $parFileSystem | grep '$parFileSystem' | awk '{print \$3}'`;
      $fsCapacity = `df $parFileSystem | grep '$parFileSystem' | awk '{print \$4}'`;

   }
   
   print "yavVersion:: $versionOW | ";
   print "fsAssign:: $fsAssign | ";
   print "fsUsed:: $fsUsed | ";
   print "fsAvailable:: $fsAvailable | ";
   print "fsCapacity:: $fsCapacity | ";
   



#*===========================================================
#* Fin script: yavireFileSystemOccupation.pl]
#*===========================================================


