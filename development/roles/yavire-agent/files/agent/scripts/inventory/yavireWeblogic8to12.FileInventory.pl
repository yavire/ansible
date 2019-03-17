#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireWeblogic8.1_0to11.0_FileInventory.pl
#*=========================================================
#* Fecha Creaci�n: [01/03/2013]
#* Autor: Fernando Oliveros
#* Compa�ia: kronobyte
#* Email: 
#* Web: 
#*=============================================
#* Descripci�n:
#*    Inventario semanal de ubicacion de instancias Weblogic
#*    Genera un fichero con los directorios donde se encuentran los diferentes dominios de weblogic en la m�quina
#* Version 2.2.0.2_10 (9/02/2019)
$versionYV="2.2.0.2_10";
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
#* Problema: No se puede hacer una busqueda en todos los filesystem a la vez, existen algunos NAS que habr�a que obviar.
#* Solucion: Leer solo los que no sean NAS o compartidos.
#*
#*=============================================
#

#*===========================================================
#* Funciones del programa 
#*===========================================================

sub obtiene_propietario {
	#Obtiene el propietario de /home/Smartphones/jboss/server/default/deploy/cache-invalidation-service.xml
	local($fich) = $_[0];
	local($linea) = `sudo ls -l $fich`;
	@fich_troceado = split(/\s/, $linea);
	return $fich_troceado[2];
}


#*===========================================================
#* Fin de declaraci�n de funciones
#*===========================================================

   
#*===========================================================
#* Definici�n de variables
#*===========================================================


#Script de Weblogic
$INVENTORY="/opt/krb/yavire/agent/inventory/weekly";
$fichero_inventory="$INVENTORY/yavireWeblogic8.1_0to11.0_FileInventory.txt"; 
$LOG="/opt/krb/yavire/agent/log/inventory";
$fichero_log="$LOG/yavireWeblogic8.1_0to11.0_FileInventory.log";
$fichero_a_localizar='config.xml';
#$uni='/';
$dir_cron="/opt/krb/yavire/agent/cron";
$producto="weblogic";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de log $fichero_log\n";

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "==============================================================================================\n";
print LOGS "   Starting yavire Weblogic Inventory - Version $versionYV ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";
print LOGS "      File to Found : $fichero_a_localizar\n";
print LOGS "\n==============================================================================================\n\n";


#$boot='boot.log';
#$patron_version='Release ID:'; #Es el patron para encontrar la version del jboss en el fichero boot.log#

`sudo mkdir -p $INVENTORY` unless (-d "$INVENTORY");


#Se abre el fichero para guardar los inventarios
open(INVENTARIOS,">$fichero_inventory") || die "problemas abriendo fichero de inventario $fichero_inventory\n";

# print INVENTARIOS "Directory\t\t\t\t\tDomain\tVersion\tPropietario\n";
# print INVENTARIOS "=========\t\t\t\t\t=======\t=======\t=========\n";

#Configura la fecha y hora para el log y salida de pantalla
print LOGS "Se realiza el inventario de los Weblogic instalados version 3.0.0.0\n";
print LOGS "Fecha: $fechaActual\n";
print LOGS "--------------------------------------------------------\n\n";

my @files = yavireUnix::getConfFilesFromFilesystems(\*LOGS, $fichero_a_localizar);

print LOGS "Se han encontrado los siguientes ficheros\n";


foreach(@files)
{
    print LOGS "$_\n";
}   

foreach (@files) {
	$linea=$_;
	chop $linea;

	if (($linea !~ /bak/i) && ($linea !~ /samples/i) && ($linea !~ /RECYCLE/i) && (($linea =~ /\\config\\${fichero_a_localizar}/i) || ($linea =~ /\/config\/${fichero_a_localizar}/i))) {
		print LOGS "Iniciamos tratamiento de fichero $linea\n";
		open(FILEIN,"<$linea") || print LOGS "Existen problemas al abrir el fichero $linea\n";
		print LOGS "Hola2\n";
		while (<FILEIN>) {
			$fich_linea = $_;
			chop($fich_linea);		
		
			#Lo trocea para studiar el dominio
			@dom_temp=split(/\//,$linea);
			
			if ($fich_linea =~  /Domain Configuration Version/i) {
						($ver) = $fich_linea =~ /<Domain Configuration Version>(\d+.\d+)[.\d+]*<\/Domain Configuration Version>/;
						#print "ANTES ver=$ver\n";
						#($versi) = $fich_linea =~ /<domain-version>(\d+.\d+[.\d+]*)<\/domain-version>/;
						#if ($versi =~ /10.3.[1-2]/) {
					#	$ver = "10.3";
					#	}
					#else {
					#	$ver = "11.0";
					#}; #if
					
					#print "DESPUES ver=$ver\n";
					#print "versi=$versi\n";
					
					#Obtiene el dominio
					if ($ver =~ /^8\./) {
					$dominio= $dom_temp[$#dom_temp-1];
					$directorio= $linea;
					#print "directorio1=$directorio\n";
					} else {
					$dominio= $dom_temp[$#dom_temp-2];
					$directorio= $linea;
					#print "directorio2=$directorio\n";
					}#if
					
					last;
			}#fin	
		
		# <Domain ConfigurationVersion="8.1.3.0" Name="Intranets">
			if ($fich_linea =~  /Domain ConfigurationVersion/i) {
					($ver) = $fich_linea =~ /<Domain ConfigurationVersion\=\"(\d+.\d+)[.\d+]*/;
					#print "ANTES ver=$ver\n";
					#($versi) = $fich_linea =~ /<domain-version>(\d+.\d+[.\d+]*)<\/domain-version>/;
					#if ($versi =~ /10.3.[1-2]/) {
					#	$ver = "10.3";
					#}
					#else {
					#$ver = "11.0";
					#}; #if
					#print "DESPUES ver=$ver\n";
					#print "versi=$versi\n";
					
					
					#Obtiene el dominio
					if ($ver =~ /^8\./) {
					$dominio= $dom_temp[$#dom_temp-1];
					$directorio= $linea;
					#print "directorio3=$directorio\n";
					} else {
					$dominio= $dom_temp[$#dom_temp-2];
					$directorio= $linea;
					#print "directorio4=$directorio\n";
					}#if
									
					
					last;
			}#fin	
			if ($fich_linea =~  /domain-version/i)  {
					($ver) = $fich_linea =~ /<domain-version>(\d+.\d+)[.\d+]*<\/domain-version>/;
					#print "ANTES ver=$ver\n";
					#($versi) = $fich_linea =~ /<domain-version>(\d+.\d+[.\d+]*)<\/domain-version>/;
					#if ($versi =~ /10.3.[1-2]/) {
					#	$ver = "10.3";
					#}
					#else {
					#$ver = "11.0";
					#}; #if
					#print "DESPUES ver=$ver\n";
					#print "versi=$versi\n";
					
					
					#Obtiene el dominio
					if ($ver =~ /^8\./) {
						$dominio= $dom_temp[$#dom_temp-1];
						$directorio= $linea;
					#print "directorio5=$directorio\n";
						} else {
					$dominio= $dom_temp[$#dom_temp-2];
					#print "dominio=$dominio\n";
											
					}#if
					
					
					last;
			}#fin

		}#while  
			
		close (FILEIN);   
			
		#Obtiene el propietario del $fichero_a_localizar
		$propietario=&obtiene_propietario($linea);
		@dir_temp=split(/\/${dominio}\//,$linea);
		$directorio= $dir_temp[0];
		#print "directorio fuera=$directorio\n"; 
		#Si la version es 10.3 se transforma a 11.0
		$ver = "11.0" if ($ver =~ /10\.3/);
		if (($dominio == "") && ($ver == "")) {
			print LOGS "No se ha incluido ${directorio}\t\t\t$dominio\t$ver\t$propietario\n"; 
			print LOGS "en el fichero de Weblogics encontrados pues la versi�n y el dominio no han podido hallarse.\n"; 
		} else {
			# print INVENTARIOS "${directorio}\t\t\t$dominio\t$ver\t$propietario\n";  
			#D:\ProductosInstalados\Middleware\user_projects\domains\yavire%%undefined%%12.1%%Administradores
			print INVENTARIOS "$directorio/$dominio%%undefined%%$ver%%$propietario\n"
			
			
		}
		
		#Crea para cada nuevo dominio el directorio /opt/krb/yavire/cron/weblogic/version/dominio donde se dejan los ficheros para que yavire opere
		#`mkdir ${dir_cron}/${producto}${Version}` unless (-d "${dir_cron}/${producto}${Version}"); #Crea el directorio /opt/krb/yavire/cron/jboss4.0 a menos que exista.
		#`mkdir -p ${dir_cron}/${producto}${ver}/${dominio}` unless (-d "${dir_cron}/${producto}${ver}/${dominio}");
			
	}#if
}#foreach result
	

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire Weblogic Inventory - Version $versionYV ($fechaActual) \n";
print LOGS "==============================================================================================\n";	


close INVENTARIOS;
close LOGS;

#*===========================================================
#* Fin script: [yavireWeblogic8.1_0to11.0_FileInventory.pl]
#*===========================================================

