#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireUnixMemoryInventory.pl
#*=========================================================
#* Fecha Creación: [28/10/2016]
#* Autor: Fernando Oliveros
#* Compañia: Yavire
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Memory inventory
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

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}


sub list_memory_server()
{
   
   #$server_totalMemory =`cat /proc/meminfo | grep MemTotal |  awk \'{print \$2}\'`;
   
   local ($max_modules_size);
   $max_modules_size=`sudo /usr/sbin/dmidecode -t memory| grep 'Maximum Memory Module Size'| awk \'{print \$5,  \$6}\'`; 
   chomp $max_modules_size;
   $max_modules_size = trim($max_modules_size);
      
   #Convertimos a bytes
   if (index($max_modules_size, "MB") != -1) {
      $max_modules_size =~ s/[^0-9]//g;
      $max_modules_size = $max_modules_size * 1024 * 1024;
   }
   else {
            
      if (index($max_modules_size, "GB") != -1) {
         $max_modules_size =~ s/[^0-9]//g;
         $max_modules_size = $max_modules_size * 1024 * 1024 * 1024;
      }
   }
   
   if ($max_modules_size eq '') {
      $max_modules_size = "undefined";
   }
   
   print "Maximum Memory Module Size: ${max_modules_size}\n";
   
   local ($max_memory_size);
   $max_memory_size=`sudo /usr/sbin/dmidecode -t 16| grep 'Maximum Capacity'| awk \'{print \$3,  \$4}\'`;
   chomp $max_memory_size;
   $max_memory_size = trim($max_memory_size);
   
   #Convertimos a bytes
   if (index($max_memory_size, "MB") != -1) {
      $max_memory_size =~ s/[^0-9]//g;
      $max_memory_size = $max_memory_size * 1024 * 1024;
   }
   else {
            
      if (index($max_memory_size, "GB") != -1) {
          $max_memory_size =~ s/[^0-9]//g;
          $max_memory_size = $max_memory_size * 1024 * 1024 * 1024;
      }
   }

   if ($max_memory_size eq '') {
      $max_memory_size = "undefined";
   }
   
   print "Maximum Capacity: ${max_memory_size}\n";
   
   
   local ($mem_module_voltage);
   $mem_module_voltage=`sudo /usr/sbin/dmidecode -t memory| grep 'Memory Module Voltage'| awk \'{print \$4,  \$5}\'`;
   chomp $mem_module_voltage;
   $mem_module_voltage = trim($mem_module_voltage);
   
   if ($mem_module_voltage eq '') {
      $mem_module_voltage = "undefined";
   }
   
   print "Memory Module Voltage: ${mem_module_voltage}\n";
   
	
   print INVENTARIO_INST "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${server_uuid}  \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\%  productVers= ${version} \%\% maxModSize= ${max_modules_size}   \%\% maxTotMem= ${max_memory_size}  \%\% modVoltage= ${mem_module_voltage}  \%\%\n";
     
 
}

sub list_memory_modules()
{
   
   
   
   my $cmd = "sudo /usr/sbin/dmidecode -t 17";    
   my @output = `$cmd`;    
   chomp @output;
   
   $bFoundMemoryDevice = 0;
   my $module_size  =  "";
   my $module_speed = "";
   my $module_locator  = "";
   my $bank_locator  = "";
   my $module_type  = "";

   foreach my $line (@output)
   {
             
       print "<<$line>>\n";
       #$line =~ s/^\s+|\s+$//g;
            
       if (index($line, "Memory Device") != -1) {
            print "Encontrado un modulo\n";
            $bFoundMemoryDevice = 1;
       }
         
       if (index($line, "Size:") != -1) {
            print "Encontrado un modulo\n";
                     
            my $first_column  = (split ' ', $line)[1]; 
            my $second_column  = (split ' ', $line)[2]; 
            $module_size_txt  = "${first_column} ${second_column}" ;        
            print "MODULE SIZE: ${module_size_txt}\n";
            
            #Convertimos a bytes
            if (index($module_size_txt, "MB") != -1) {
               $module_size = $first_column * 1024 * 1024;
            }
            else {
            
               if (index($module_size_txt, "GB") != -1) {
                  $module_size = $first_column * 1024 * 1024 * 1024;
               }
               else {
                  $module_size = $first_column
               }
            }
       }
             
       if (index($line, "Locator:") != -1) {
          
         if (index($line, "Bank Locator:") != -1) {
            print "Encontrado un BANK LOCATOR\n";
         }
         else {
            print "Encontrado un LOCATOR\n";
             my $first_column  = (split ' ', $line)[1]; 
             my $second_column  = (split ' ', $line)[2]; 
             $module_locator  = "${first_column} ${second_column}" ;        
             print "LOCATOR: ${module_locator}\n";
          }
          
       }
       
  
       if (index($line, "Bank Locator:") != -1) {
                
          print "Encontrado un Bank Locator\n";
          my $first_column  = (split ' ', $line)[2]; 
          my $second_column  = (split ' ', $line)[3]; 
          $bank_locator  = "${first_column} ${second_column}" ;        
          print "BANK LOCATOR: ${bank_locator}\n";

          
       }
       
       if (index($line, "Type:") != -1) {
          
          print "Encontrado Type\n";
          
          my $first_column  = (split ' ', $line)[1]; 
          my $second_column  = (split ' ', $line)[2]; 
          $module_type  = "${first_column} ${second_column}" ;        
          print "TYPE: ${module_type}\n";
          
       }
       
        if (index($line, "Speed:") != -1) {
           if (index($line, "Configured Clock Speed:") != -1) {
              print "Encontrado un CLOCK SPEED\n";
           }
           else {
               print "Encontrado speed\n";
               my $first_column  = (split ' ', $line)[1]; 
               my $second_column  = (split ' ', $line)[2]; 
               $module_speed  = "${first_column}" ;        
               print "MODULE SPEED: ${module_speed}\n";
               print INVENTARIO_INST "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${server_uuid}  \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\%  productVers= ${version} \%\% dimmLocator= ${module_locator}   \%\% bankLocator=  ${bank_locator}  \%\% memType= ${module_type}   \%\% memSize= ${module_size} \%\% memSpeed= ${module_speed} \%\% maxTotMem= -  \%\% modVoltage= - \%\%\n";
           }

          
       }
       
   }
   
 
}


#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

$versionYAV = '2.2.0.4';

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";
$inventario_inst="yavireInv_memory.data";

$DirLog="/opt/krb/yavire/agent/log/inventory";
$fichero_log="${DirLog}/yavireInv_memory.log"; 


$producto="memory";
$version="2.0";
$vendor="unix";

$instancia="-";
$TipoInstancia="HARDWARE";
$subTipoInstancia="MEMORY";


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


$DIR_DATA="${INVENTARIO}/data/memory/${server_uuid}";	
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
print LOGS "   Starting yavire Memory Inventory - Version $versionYAV ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";



# open(INVENTARIO_INST,">$fichero_inventario_inst") || die "problemas abriendo fichero de inventario inst $fichero_inventario_inst\n";

list_memory_server();
list_memory_modules();

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire Memory Inventory - Version $versionYAV ($fechaActual) \n";
print LOGS "==============================================================================================\n";	

close LOGS;
close INVENTARIO_INST;

#*===========================================================
#* Fin script: yavireUnixMemoryInventory34.pl]
#*===========================================================

