#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: openWebApacheWeeklyFileInventory.pl
#*=========================================================
#* Fecha Creación: [01/03/2013]
#* Autor: Fernando Oliveros
#* Compañia: kronobyte
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
#* Date: [28/10/2014]
#* Problema: No se puede hacer una busqueda en todos los filesystem a la vez, existen algunos NAS que habría que obviar.
#* Solucion: Leer solo los que no sean NAS o compartidos.
#*
#*=============================================
#

#*===========================================================
#* Funciones del programa 
#*===========================================================

sub getOwner {
	#Obtiene el propietario de /home/Smartphones/jboss/server/default/deploy/cache-invalidation-service.xml
	local($fich) = $_[0];
	$linea = `ls -l $fich`;
	@fich_troceado = split(/\s+/, $linea);
	#print "fich_troceado= 0= $fich_troceado[0] 1= $fich_troceado[1] 2= $fich_troceado[2] 3= $fich_troceado[3] 4= $fich_troceado[4] 5= $fich_troceado[5] 6= $fich_troceado[6] 7= $fich_troceado[7]";
	return $fich_troceado[2];
}

sub getVersion {
	local($dirBase) = $_[0];
	
	chomp $dirBase;
		
	#print "DIRBASE in GetVersion: ($dirBase)\n";
	@resultVersion=`$dirBase -V 2> /dev/null`;
	# print  "RESVERSION=(@resultVersion)\n";
	
	#Buscamos la version a través del ejecutable 
	local($result)=`$dirBase -V 2> /dev/null`;
	chomp $result;
	
	print "RESULT: $result\n";
	
	local($apacheVersion)= $result =~ /Server version: Apache\/(\d+\.\d+\.\d+)/;
        
	return $apacheVersion;
}

sub getConfigFile {
	local($dirBase) = $_[0];
	chomp $dirBase;
		
	#print "DIRBASE in getConfigFile: ($dirBase)\n";
	@resultVersion=`$dirBase -V 2> /dev/null`;
	# print  "RESVERSION=(@resultVersion)\n";
	
	#Obtenemos el fichero de configuracion
	
	local($result)=`$dirBase -V | grep SERVER_CONFIG_FILE 2> /dev/null`;
	chomp $result;
	if ( $result =~ /\"(.*?)\"/ )
	{
		print "Paso 1\n";
		$configFile = $1;
		# print $inside, "\n";
	}
	
	print "CONFIG FILE: $configFile\n";
        
	return $configFile;
}


sub getDocumentRoot {
	local($dirBase) = $_[0];
	chomp $dirBase;
		
	#print "DIRBASE: ($dirBase)\n";
	@resultVersion=`$dirBase -V 2> /dev/null`;
	# print  "RESVERSION=(@resultVersion)\n";
	
	#Obtenemos el fichero de configuracion
	
	local($result)=`$dirBase -V | grep HTTPD_ROOT 2> /dev/null`;
	chomp $result;
	if ( $result =~ /\"(.*?)\"/ )
	{
		print "Paso 1\n";
		$documentRoot = $1;
		# print $inside, "\n";
	}
	
	print "Document Root: $documentRoot\n";
        
	return $documentRoot;
}


sub estudia_descartarlo {
	#Mira lo que contiene ese directorio para descartarlo, o bien darlo como una instalación buena.
	local($dir) = $_[0];
	local(@linea) = `ls $dir`;
	#print "estudia_descartarlo: linea=@linea\n";
	local($lineaJunta) = join(' ', @linea);
	local($descartar)="false";
	
	#print LOGS "lineaJunta=$lineaJunta\n";
	
	if ($lineaJunta !~ /conf/) 
	{
		print LOGS "No hay bin\n";
		$descartar="true";
		print LOGS "$dir: Se descarta por no contener el directorio conf \n";
	}
	else {
               $descartar="false";
	}
	
	
	# if (($lineaJunta !~ /htdocs/) && ($lineaJunta !~ /modules/) && ($lineaJunta !~ /conf/) && ($lineaJunta !~ /bin/)) 
	# {
		# $descartar="true";
		# print LOGS "$dir Se descarta por no contener ni el directorio certs, ni cache ni los ficheros start.sh stop.sh\n";
	# }
	# else {
		# $descartar="false";
		# print LOGS "No descartamos\n";
	# }
	
	
	if ($dir =~ /\/\./) {
		$descartar="true";
		#print "DENTRO PUNTO lineaJunta=$lineaJunta\n";
		}
	return $descartar;
}


#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

#Script de Apache
$versionYV="2.2.0.5_01";


#Control de errores
#exit 1 Parametros pasados de forma incorrecta.

$INVENTORY="/opt/krb/yavire/agent/inventory/weekly";
$fichero_inventory="$INVENTORY/yavireApacheWeeklyFileInventory.txt"; 
$LOG="/opt/krb/yavire/agent/log/inventory";
$fichero_log="$LOG/yavireApacheWeeklyFileInventory.log";
#$fichero_a_localizar='httpd*.conf';
$fileToFind='httpd';
$producto="apache";
$configFile="-";
$documentRoot="-";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================


`mkdir -p $INVENTORY` unless (-d "$INVENTORY");

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de log $fichero_log\n";

#Se abre el fichero para guardar los inventarios
#Configura la fecha y hora para el log y salida de pantalla

$fechaActual=yavireUnix::formatoFechaLog();

open(INVENTARIOS,">$fichero_inventory") || die "problemas abriendo fichero de inventario $fichero_inventory\n";


print LOGS "==============================================================================================\n";
print LOGS "   Starting yavire Apache Inventory - Version $versionYW ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";


my @files = yavireUnix::getConfFilesFromFilesystems(\*LOGS, $fileToFind);

print LOGS "Se han encontrado los siguientes ficheros\n";


foreach(@files)
{
    print "$_\n";
}   

foreach (@files) {
	
	$Directory=$_;
	print "=============================================================================================================================\n";
	chomp $Directory;
	print "Paso 1: $Directory\n";
	
	
	#Obtiene el propietario del $fichero_a_localizar
	$propietario=&getOwner($Directory); #/home/Smartphones/apache/conf/httpd.conf
	print "propietario= $propietario\n";
	
	#Obtiene la version
	$Version=&getVersion($Directory);
	print "version= $Version\n";
	if ($Version ne '') {
	   #Obtenemos fichero de configuracion
	   $configFile=&getConfigFile($Directory);
	   print "Config File= $configFile\n";
	
	   #Obtenemos fichero de configuracion
	   $documentRoot=&getDocumentRoot($Directory);
	   print "Document Root= $documentRoot\n";
	
	   print INVENTARIOS "$Directory%%$documentRoot%%$configFile%%$Version%%$propietario\n"
    }
	
}#foreach


$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire Apache Inventory - Version $versionYV ($fechaActual) \n";
print LOGS "==============================================================================================\n";	

close INVENTARIOS;
close LOGS;

#*===========================================================
#* Fin script: [openWebApacheWeeklyFileInventory.pl]
#*===========================================================
