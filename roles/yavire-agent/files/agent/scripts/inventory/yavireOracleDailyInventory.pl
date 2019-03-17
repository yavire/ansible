#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireOracleDailyInventory.pl
#*=========================================================
#* Fecha Creación: [28/04/2016]
#* Autor: Fernando Oliveros
#* Compañia: Kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Genera el inventario diario de Oracle para Unix
#*    Version 2.2.0.2_1
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

#Script de tomcat
$versionYAV = '2.2.0.2';

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";

$DirLog="/opt/krb/yavire/agent/log/inventory";
$inventoryWeeklyFile="yavireOracle_FileInventory.txt";

`mkdir -p $DirLog` unless (-d $DirLog);

$maquinaTemp=`uname -n`;
chomp $maquinaTemp;
@maquina_troceada = split(/\./, $maquinaTemp);
$maquina=$maquina_troceada[0];

$vendor="Oracle Corporation";
$producto="oracle";
$ruta_a_localizar='/conf/server.xml';
$fichero_a_localizar='server.xml';
$instancia="-";
$TipoInstancia="SOFTWARE";
$subTipoInstancia="DATABASE";
$baseAgentDirUnix="/opt/krb/yavire/agent";
$ficheroInventarioDiario="yavireInv_oracle.data";
$propietario="undefined";

$szFichLog="$baseAgentDirUnix/log/inventory/yavireInv_oracle.log"; 

#*===========================================================
#* Cuerpo del programa 
#*===========================================================


print "Hola 2\n";
print "$szFichLog\n";


($uuid) = yavireUnix::getServerUUID(); 
 
print $server_uuid;

($system_manufacturer) = yavireUnix::getSystemManufacturer();
 
($ip_server) = yavireUnix::getIPServer();
  
$dirFichDataSemanal="$baseAgentDirUnix/inventory/weekly/"; 
$rutaFicheroInventarioSemanal="$dirFichDataSemanal$inventoryWeeklyFile"; 

if (-d $dirFichDataSemanal) {
     print LOG "El directorio $dirFichDataSemanal existe\n";
} 
else {
   print LOG "Creamos directorio  $dirFichDataSemanal \n";
   print "$dirFichDataSemanal\n";
   system 1, "mkdir $dirFichDataSemanal";
    
}
   
$dirFichDataDiario="$baseAgentDirUnix/inventory/data/oracle/$uuid/"; 
$rutaFicheroInventarioDiario="$dirFichDataDiario$ficheroInventarioDiario"; 
if (-d $dirFichDataDiario) {
    print LOG "El directorio $dirFichDataDiario existe\n";
} 
else {
    print LOG "Creamos directorio  $dirFichDataDiario \n";
    print "$dirFichDataDiario\n";
    # system 1, "mkdir $dirFichDataDiario";
    `mkdir -p "${dirFichDataDiario}"` unless (-d "${dirFichDataDiario}");
    sleep 5;
           
}

#$inventoryWeeklyFile_inst="$DIR_DATA/$inventorio_inst"; 

print "Week: $rutaFicheroInventarioSemanal\n";
print "Daily: $rutaFicheroInventarioDiario\n";


open(LOGS,">>$szFichLog") || die "problemas abriendo fichero log de inventario semanal $szFichLog\n";

open(INVENTARIO_INST,">$rutaFicheroInventarioDiario") || die "problemas abriendo fichero de inventario diario $rutaFicheroInventarioDiario\n";

open(INVENTARIO_WEEK,"<$rutaFicheroInventarioSemanal") || die "problemas abriendo fichero de inventario $rutaFicheroInventarioSemanal\n";

#print LOGS "\n\nFecha de insercion en el fichero: $datelog\n";

#Leemos todos los ficheros oratab encontrados
while (<INVENTARIO_WEEK>) {
	
	$file=$_;;
	open(INFO, $file) or die("Could not open  file.");
	
	my $uid = (stat $file)[4];
	my $propietario = (getpwuid $uid)[0];
	
	# print "uid: $uid\n";
	# print "user: $propietario\n";
	
	#Analizamos los ficheros cat
	while ( <INFO> ) {
		$line=$_;
		next if /^\s*($|#)/; #Eliminamos filas en blanco y comentarios
		#print $line;
		
		@splitLine = split(/:/, $line);
		$instanceName="$splitLine[0]";
		$directorio="$splitLine[1]";
				
		#Del directorio, obtenemos la versión
		@splitDir = split(/\//, $directorio);
		
		foreach (@splitDir) {
			$res=$_;
			# print "$res\n";
			$versionOracle = $res if ($res =~ /12\./);
			$versionOracle = $res if ($res =~ /11\./);
			$versionOracle = $res if ($res =~ /13\./);
			$versionOracle = $res if ($res =~ /9\./);
			$versionOracle = $res if ($res =~ /8\./);
		}
		
		print INVENTARIO_INST "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${uuid} \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${versionOracle} \%\% instanceName= ${instanceName} \%\%  clusterInstance= - \%\% propietary= ${propietario} \%\% instanceDir= $directorio \%\%\n";
    
	}
	close(INFO);
	
	 
	# }#foreach
}#while

close LOGS;
close INVENTARIO_WEEK;
close INVENTARIO_INST;


#*===========================================================
#* Fin script: yavireOracle12DailyInventory.pl]
#*===========================================================

