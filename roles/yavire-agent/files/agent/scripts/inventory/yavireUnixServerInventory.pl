#!/usr/bin/perl

use Sys::Hostname;
use Socket;

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#use strict;
#use warnings;

#* NombreFichero: yavireUnixServerInventory.pl
#*=========================================================
#* Fecha Creación: [18/07/2015]
#* Autor: Fernando Oliveros
#* Compañia: Kronodata
#* Email: 
#* Web: 
#* Version 2.2.0.2_4
#*=============================================
#* Descripción:
#*    Genera el inventario yavire para un servidor Unix
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

$versionYV="2.2.0.6";
$ficheroInventario="yavireInv_server.data";

($fecha) =  yavireUnix::formatoFechaLog();


$baseAgentDirWin="C:\\krb\\yavire\\agent";
$baseAgentDirUnix="/opt/krb/yavire/agent";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

print "Ejecutando programa yavireUnixServerInventory.pl\n";


# Si es una máquina windows.
# $^O : devuelve el sistema operativo
if ($^O =~ /Win/) {
    $szFichLog="$baseAgentDirWin\\log\\inventory\\yavireWinServerInventory.log"; 
}
else {
    $szFichLog="$baseAgentDirUnix/log/inventory/yavireWinServerInventory.log"; 
}

 
open(LOG,">$szFichLog") || die "problemas abriendo log  $szFicheroLog\n";
print LOG "$fecha: Iniciando programa yavireUnixServerInventory.pl $versionYV\n";

 
if ($^O =~ /Win/) {
     
    ($system_name) = yavire21::getDatosWindows();
    
    ($uuid) = yavire21::geComputerSystemProductData();
    
    # print "HOLA1: $ip_address\n";
    
    ($ip_address) = yavire21::getIPServer();
    
    ( $system_name, $system_type, $system_manufacturer, $system_model, $NumberOfProcessors, $DNSHostName) = yavire21::getHardwareData();
    
    ( $os_version, $os_level, $os_build, $os_manufacturer) = yavire21::getVersionOS();
    
    ( $hw_cpu_vendor, $hw_cpu_model, $hw_cpu_mhz, $hw_cpu_cores, $hw_cpu_threads, $hw_cpu_sockets) = yavire21::getCPUData();
    
    ( $os_totalmem ) = yavire21::getMemoryServer();
    
    ( $os_architecture ) = yavire21::geOSArq();
    
    $dirFichData="$baseAgentDirWin\\inventory\\data\\server\\$system_name\\"; 
    $rutaFicheroInventario="$dirFichData$ficheroInventario"; 
    if (-d $dirFichData) {
       print LOG "El directorio $dirFichData existe\n";
    } 
    else {
       print LOG "Creamos directorio  $dirFichData \n";
       print "$dirFichData\n";
       system 1, "mkdir $dirFichData";
       sleep 5;
   }
}
else {
    
    ($ip_address) = yavireUnix::getIPServer();
    
    ($server_uuid) = yavireUnix::getServerUUID(); 
    
    $maquinaTemp=`uname -n`;
    chomp $maquinaTemp;
    @maquina_troceada = split(/\./, $maquinaTemp);
    $system_name = $maquina_troceada[0];
    
    $dirFichData="$baseAgentDirUnix/inventory/data/server/${server_uuid}/"; 
    $rutaFicheroInventario="$dirFichData$ficheroInventario"; 
   
    #print "DIRECTORIO: ${rutaFicheroInventario}\n";
    
    `mkdir -p "${dirFichData}"` unless (-d "${dirFichData}"); 
          
     ($system_manufacturer) = yavireUnix::getSystemManufacturer();
     
     ($system_model) = yavireUnix::getSystemModel();
     
     ($server_serial) = yavireUnix::getServerSerial();
      
     ($hw_cpu_vendor) = yavireUnix::getCpuVendor();
       
     ($hw_cpu_model) = yavireUnix::getCpuModel();

     ($hw_cpu_mhz) = yavireUnix::getCpuMHZ();
     
     ($NumberOfProcessors) = yavireUnix::getNumberOfProcessors();
       
     ($hw_cpu_cores) = yavireUnix::getCpuCores();
    
     ($hw_cpu_threads) = yavireUnix::getCpuThreads() * $hw_cpu_cores; 
       
     ($server_totalMemory) = yavireUnix::getServerTotalMemory() * 1024; 
     
      ($os_manufacturer) = yavireUnix::getOSManufacturer(); 
     
      ($os_version) = yavireUnix::getOSVersion();   
      
      ($os_level) = yavireUnix::getOSLevel();   
      
      ($os_architecture) = yavireUnix::getOSArchitecture();   
       
      $os_build =  $os_level;
     
      $typeServer = "PHYSICS"; 
       
      chomp $os_version;
      chomp $os_manufacturer;

      $system_manufacturer_tmp = lc $system_manufacturer;

      my $substring = "vmware";
      if ($system_manufacturer_tmp =~ /\Q$substring\E/) {
         print qq("$mystring" contains "$substring"\n);
         $typeServer = "VIRTUAL";
         
         ($hw_cpu_cores) = yavireUnix::getCpuVirtualCores();
         
      }
      
      my $substring = "xen";
      if ($system_manufacturer_tmp =~ /\Q$substring\E/) {
         print qq("$mystring" contains "$substring"\n);
         $typeServer = "VIRTUAL";

         ($hw_cpu_cores) = yavireUnix::getCpuVirtualCores();
      }

}

#Si el uuid contiene ec2, son instancias de AWS

my $substring = "ec2";
if (lc($server_uuid) =~ /\Q$substring\E/) {
     print qq("$mystring" contains "$substring"\n);
     $aws_region=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`;
     print "$aws_region\n";
      
     $aws_public_ip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`;
      print "Hola: $aws_public_ip\n";
      
      $aws_instance_type=`curl http://169.254.169.254/latest/meta-data/instance-type`;
      print "$aws_instance_type\n";
      
      $aws_instance_id=`curl http://169.254.169.254/latest/meta-data/instance-id`;
      print "$aws_instance_id\n";
      
      $ip_address=`curl http://169.254.169.254/latest/meta-data/local-ipv4`;
      print "$aws_instance_id\n";
      
      $system_name = $aws_instance_id;

}
else {
   
     $aws_region="None";
     $aws_public_ip="None";
     $aws_instance_type="None";
     $aws_instance_id="None";
}

open(INVENTARIO_INST,">$rutaFicheroInventario") || die "problemas abriendo fichero de inventario inst $rutaFicheroInventario\n";
print INVENTARIO_INST "versionYAV= ${versionYV} \%\% serverType=  ${typeServer} \%\% serverUUID= ${server_uuid} \%\% serverName= ${system_name} \%\% serverIP= ${ip_address} \%\% serverVendor= ${system_manufacturer} \%\% serverModel= ${system_model} \%\%  serverSerial= ${server_serial} \%\% cpuVendor= ${hw_cpu_vendor} \%\%  cpuModel= ${hw_cpu_model} \%\% cpuMhz= ${hw_cpu_mhz} \%\% cpuSockets= ${NumberOfProcessors} \%\% cpuCores= ${hw_cpu_cores} \%\% cpuThreads= ${hw_cpu_threads} \%\% serverMemory= ${server_totalMemory} \%\% osType= $^O  \%\% osVendor= ${os_manufacturer}  \%\%  osVersion= ${os_version} \%\% osLevel= ${os_level} \%\% osBuild= ${os_build} \%\% osArq= ${os_architecture} \%\% awsPublicIP= ${aws_public_ip} \%\%  awsInstanceType= ${aws_instance_type} \%\% awsRegion= ${aws_region} \%\% awsInstanceId= ${aws_instance_id} \%\%\n";	
close INVENTARIO_INST;

($fecha) =  yavireUnix::formatoFechaLog();

print LOG "$fecha: Finalizando yavireWinServerInventory.pl $versionYV\n";
close LOG;

exit 0;

#*===========================================================
#* Fin script: yavireWinServerInventory.pl]
#*===========================================================
