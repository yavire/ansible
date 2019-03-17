#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireFilesystemInventory34.pl
#*=========================================================
#* Fecha Creación: [24/03/2015]
#* Autor: Fernando Oliveros
#* Compañia: Yavire
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Inventario detallado de los filesystems
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
#* Date: [dd/mm/aaaa]
#*
#*=============================================
#

#*===========================================================
#* Funciones del programa 
#*===========================================================


sub list_instance()
{
	
   my @listaFilesystemName;
   my $osname = $^O;
	
   if( $osname eq 'linux' ) {

      $cadenaOK = "ext";	
      
      #Obtengo el nombre del filesystem
      #@listaFilesystemName = `df -kT | grep -v Mount | grep % | cut -d"%" -f2 | awk '{print \$1}'`;
      #@listaFilesystemName = ` df -kT |grep "%" |grep -v Use |awk '{print \$(NF-0)}'`;
      @listaFilesystemName = `df -PkT|tail -n +2|column -t | awk '{print \$7}'`;
      
      #Extraigo el tipo de filesystem
      @listaFilesystemType = `df -PkT|tail -n +2|column -t | awk '{print \$2}'`;
      
      #Extraigo el tamano de filesystem
      @listaFilesystemSize = `df -PkT|tail -n +2|column -t | awk '{print \$3}'`;
      
      #Extraigo lo que queda libre
      @listaFilesystemFree = `df -PkT|tail -n +2|column -t | awk '{print \$5}'`;
      
       #Extraigo lo que queda libre
      @listaFilesystemVolumen = `df -PkT|tail -n +2|column -t | awk '{print \$1}'`;

   }
   else {
		   
      $cadenaOK = "/dev";
      @listaFilesystemName = `df -k | grep -v "Mounted" | grep % | awk '{print \$7}'`;	
      @listaFilesystemType = `df -k | grep -v "Mounted" | grep % | awk '{print \$1}'`;	

   }
 
 
   foreach(@listaFilesystemName)
   {
       # print LOGS "$listaFilesystemsMountedOn[$i]\n";
       chomp $listaFilesystemName[$i];
       chomp $listaFilesystemType[$i];
       chomp $listaFilesystemSize[$i];
       chomp $listaFilesystemFree[$i];
       chomp $listaFilesystemVolumen[$i];
       
       #Convertimos los kbytes a bytes
       
       $fileSystemSize = $listaFilesystemSize[$i] * 1024;
       $fileSystemFree = $listaFilesystemFree[$i] * 1024;
       
       print "$fileSystemSize\n";
       
       
       
       #print INVENTARIO_INST "versionYAV= ${versionYAV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${version} \%\% instancia= ${listaFilesystemsMountedOn[$i]} \%\% ip= ${IpMaq} \%\% puerto= 0 \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${max_threads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess= - \%\% directorioBase= - \%\%\n";
       
       #Ejemplo windows
       #print INVENTARIO_ RIO  "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% serverUUID= ${server_uuid} \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\%  productVers= ${version} \%\% instanceName= ${instancia} \%\%                                   volumenName= ${volumen_name} \%\% driveType= ${drive_type} \%\% volumenSize= ${volumen_size} \%\% volumenFree= ${volumen_free} \%\% volumenDescription=  ${volumen_description} \%\%  volumenSerial= ${volumen_serial} \%\% filesystemType= ${filesystem} \%\%\n";
       
        print INVENTARIO_INST "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${server_uuid}  \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\%  productVers= ${version} \%\% instanceName= ${listaFilesystemName[$i]}   \%\% volumenName= ${listaFilesystemVolumen[$i]}  \%\% driveType= 0 \%\% volumenSize= ${fileSystemSize} \%\% volumenFree= ${fileSystemFree} \%\% volumenDescription=  ${volumen_description} \%\%  volumenSerial= ${volumen_serial} \%\% filesystemType= ${listaFilesystemType[$i]} \%\%\n";
       
       
       # print LOGS "versionYAV= ${versionYAV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${version} \%\% instancia= ${listaFilesystemsMountedOn[$i]} \%\% ip= ${ipMaq} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${max_threads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess= - \%\% directorioBase= - \%\%\n";
       $i++;
   }
    
     
 
}

#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

$versionYAV = '2.2.0.2';

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";
$inventario_inst="yavireInv_filesystem.data";

$DirLog="/opt/krb/yavire/agent/log/inventory";
$fichero_log="${DirLog}/yavireInv_filesystem.log"; 


$producto="filesystem";
$version="2.0";
$vendor="unix";

$instancia="-";
$TipoInstancia="SOFTWARE";
$subTipoInstancia="FILESYSTEM";
$propietario="krb";



#*===========================================================
#* Cuerpo del programa 
#*===========================================================


($system_manufacturer) = yavireUnix::getSystemManufacturer();
($server_uuid) = yavireUnix::getServerUUID(); 

 $maquinaTemp=`uname -n`;
 chomp $maquinaTemp;
 @maquina_troceada = split(/\./, $maquinaTemp);
 $system_name = $maquina_troceada[0];

 ($ip_address) = yavireUnix::getIPServer();


$DIR_DATA="${INVENTARIO}/data/filesystem/${server_uuid}";	
`mkdir -p "${DIR_DATA}"` unless (-d "${DIR_DATA}"); 

print "DIR_DATA: $DIR_DATA";

$fichero_inventario_inst="$DIR_DATA/$inventario_inst";


 
 # $maquinaTemp=`uname -n`;
 # chomp $maquinaTemp;
 # @maquina_troceada = split(/\./, $maquinaTemp);
 # $system_name = $maquina_troceada[0];

open(INVENTARIO_INST,">$fichero_inventario_inst") || die "problemas abriendo fichero de inventario inst $fichero_inventario_inst\n";

$fechaActual=yavireUnix::formatoFechaLog();

open(LOGS,">$fichero_log") || die "problemas abriendo fichero log $fichero_log\n";


$fechaActual=yavireUnix::formatoFechaLog();

print LOGS "==============================================================================================\n";
print LOGS "   Starting yavire Filesystem Inventory - Version $versionYAV ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";



# open(INVENTARIO_INST,">$fichero_inventario_inst") || die "problemas abriendo fichero de inventario inst $fichero_inventario_inst\n";

list_instance();

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire Filesystem Inventory - Version $versionYAV ($fechaActual) \n";
print LOGS "==============================================================================================\n";	

close LOGS;
close INVENTARIO_INST;

#*===========================================================
#* Fin script: yavireFilesystemInventory34.pl]
#*===========================================================

