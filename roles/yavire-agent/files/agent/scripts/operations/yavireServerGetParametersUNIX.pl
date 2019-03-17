#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireServerGetParameters.pl
#*=========================================================
#* Fecha Creación: [18/05/2016]
#* Autor: Fernando Oliveros
#* Compañia: kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Devuelve los datos de un server
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

$versionYAV = '2.2.0.2_1';
 
#Se añade dos puntos al parametro
$parFileSystem="$ARGV[0]";


# % mem -b


#*===========================================================
#* Cuerpo del programa 
#*===========================================================



   my $osname = $^O;

   if( $osname eq 'linux' ) {
   
      ($os_version) = yavireUnix::getOSVersion(); 
      
      #print "VERSION:      $os_version\n";
      if ( ((index($os_version, "CentOS") != -1) ||  (index($os_version, "Oracle Linux") != -1) ) &&  (index($os_version, "7.") != -1)) {
         
         $swapTotBytes = `free -b| awk 'FNR == 3 {print \$2}'`;
         $swapBytesUsed = `free -b| awk 'FNR == 3 {print \$3}'`;
         $swapBytesFree = `free -b| awk 'FNR == 3 {print \$4}'`;

         
         #print "SOY:      $os_version\n";
      }
      else {
         $swapTotBytes = `free -b| awk 'FNR == 4 {print \$2}'`;
         $swapBytesUsed = `free -b| awk 'FNR == 4 {print \$3}'`;
         $swapBytesFree = `free -b| awk 'FNR == 4 {print \$4}'`;
      }
   
      $memoryTotBytes = `free -b| awk 'FNR == 2 {print \$2}'`;
      $memoryBytesUsed = `free -b| awk 'FNR == 3 {print \$3}'`;
      $memoryBytesFree = `free -b| awk 'FNR == 3 {print \$4}'`;
      $loadavgOneMinute = `cat /proc/loadavg| awk 'FNR == 1 {print \$1}'`;
      $loadavgFiveMinute = `cat /proc/loadavg| awk 'FNR == 1 {print \$2}'`;
      $loadavgFifthteenMinute = `cat /proc/loadavg| awk 'FNR == 1 {print \$3}'`;
      $loadavgThreads = `cat /proc/loadavg| awk 'FNR == 1 {print \$4}'`;
      $numProcesses = `ps -elf | wc -l | awk 'FNR == 1 {print \$1}'`;
      $maxProcesses = `cat /proc/sys/kernel/pid_max | awk 'FNR == 1 {print \$1}'`;
      $numProcRunning = ` ps -e r | wc -l | awk 'FNR == 1 {print \$1}'`;
      $numThreads = `ps -elfT | wc -l | awk 'FNR == 1 {print \$1}'`;
      
   }
   else {
     
   }
   
   print "yavVersion:: $versionYAV | ";
   print "memoryTotBytes:: $memoryTotBytes | ";
   print "memoryBytesUsed:: $memoryBytesUsed | ";
   print "memoryBytesFree:: $memoryBytesFree | ";
   print "swapTotBytes:: $swapTotBytes | ";
   print "swapBytesUsed:: $swapBytesUsed | ";
   print "swapBytesFree:: $swapBytesFree | ";
   print "loadavgOneMinute:: $loadavgOneMinute | ";
   print "loadavgFiveMinute:: $loadavgFiveMinute | ";
   print "loadavgFifthteenMinute:: $loadavgFifthteenMinute | ";
   print "loadavgThreads:: $loadavgThreads | ";
   print "numProcesses:: $numProcesses | ";
   print "maxProcesses:: $maxProcesses | ";
   print "numProcRunning:: $numProcRunning | ";
   print "numThreads:: $numThreads | ";
   



#*===========================================================
#* Fin script: yavireServerGetParameters.pl]
#*===========================================================


