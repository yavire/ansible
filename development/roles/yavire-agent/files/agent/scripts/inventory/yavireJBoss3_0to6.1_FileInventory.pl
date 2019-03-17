#!/usr/bin/perl
use POSIX qw(strftime);

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: openWebJBoss3_to_Tomcat6.1_FileInventory.pl
#*=========================================================
#* Fecha Creación: [01/03/2013]
#* Autor: Fernando Oliveros
#* Compañia: kronobyte
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Inventario semanal de ubicacion de instancias JBoss
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

sub obtiene_propietario {
   #Obtiene el propietario de /home/Smartphones/jboss/server/default/deploy/cache-invalidation-service.xml
   
   local($fich) = $_[0];
   #print LOGS "OBTENEMOS PROPIETARIO del fichero ($fich)\n";
   
   $linea = `ls -l $fich`;
   #print LOGS "OBTENEMOS PROPIETARIO del fichero ($linea)\n";
   @fich_troceado = split(/\s+/, $linea);
   
   return $fich_troceado[2];
}

sub obtiene_version {
	
	local($dirBase) = $_[0];
	
	$patron_version='Specification-Version:'; #Es el patron para encontrar la version del jboss en el fichero META-INF/MANIFEST.MF
	
	print LOGS "Obteniendo version de $dirBase\n";
	#Copiamos el fichero $dirBase/lib/jboss-system.jar a /opt/krb/yavire/tmp
	chdir "/opt/krb/yavire/agent/tmp";
	
	print LOGS "Se copia  cp ${dirBase}/lib/jboss-system.jar a /opt/krb/yavire/agent/tmp\n";
	
	`cp ${dirBase}/lib/jboss-system.jar /opt/krb/yavire/agent/tmp`;
	
	#Extraemos el fichero META-INF/MANIFEST.MF del jar copiado
	
	print LOGS "Extraemos /opt/krb/yavire/agent/java1.6/bin/jar xf /opt/okrb/yavire/agent/tmp/jboss-system.jar META-INF/MANIFEST.MF\n";
	`/opt/krb/yavire/agent/java1.6/bin/jar xf /opt/krb/yavire/agent/tmp/jboss-system.jar META-INF/MANIFEST.MF`;
	sleep 5;
	
	#Buscamos la cadena similar a Specification-Version: 4.2.2.GA en el fichero extraido
	
	print LOGS "Buscamos patron  $patron_version en /opt/krb/yavire/agent/tmp/META-INF/MANIFEST.MF\n";
	@linea_version= grep (/$patron_version/, `cat /opt/krb/yavire/agent/tmp/META-INF/MANIFEST.MF`);	
	
	$ver = join('', @linea_version);
	($Version)= $ver =~ /(\d+\.\d+)/;
	
	sleep 5;
	
	print LOGS "VersionBuena= ($Version)\n\n";
	
	#Borramos los fichero extraidos
	`rm -R /opt/krb/yavire/agent/tmp/jboss-system.jar /opt/krb/yavire/agent/tmp/META-INF`;
	sleep 5;

	return $Version;
}

#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================


#Script de Jboss
$versionYV="2.2.0.1";


#Control de errores
#exit 1 Parametros pasados de forma incorrecta.

$INVENTORY="/opt/krb/yavire/agent/inventory/weekly";
$fichero_inventory="$INVENTORY/yavireJBoss3_0to6.1_FileInventory.txt"; 
$LOG="/opt/krb/yavire/agent/log/inventory";
$fichero_log="$LOG/yavireJBoss3_0to6.1_FileInventory.log";
$fichero_a_localizar='cache-invalidation-service.xml';
$uni='/';
$producto="jboss";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

#Script de Tomcat 5 a 7

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de log $fichero_log\n";

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "==============================================================================================\n";
print LOGS "   Starting yavire JBoss Inventory - Version $versionYV ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";
print LOGS "      File to Found : $fichero_a_localizar\n";
print LOGS "\n==============================================================================================\n\n";

`mkdir $INVENTORY` unless (-d "$INVENTORY");



#Se abre el fichero para guardar los inventarios
open(INVENTARIOS,">$fichero_inventory") || die "problemas abriendo fichero de inventario $fichero_inventory\n";
print INVENTARIOS "IdJBoss\tDirectory\t\t\t\t\tDomain\tVersion\tPropietario\n";
print INVENTARIOS "=======\t=========\t\t\t\t\t=======\t=======\t=========\n";

my @files = yavireUnix::getConfFilesFromFilesystems(\*LOGS, $fichero_a_localizar);

print LOGS "Se han encontrado los siguientes ficheros\n";


foreach(@files)
{
    print LOGS "$_\n";
}   


$IdJBoss=1;
$Domain_ant="";

#Todo el path del fichero que define que existe una instalacion de jboss
#/home/Smartphones/jboss/server/default/deploy/cache-invalidation-service.xml

foreach (@files) {
	$res=$_;
	print LOGS "\n-----------------------------------------------------------------------------------------------\n";
	print LOGS "Tratando linea $res \n";
	
	@res_troceado = split(/\//, $res);
	
	#Obtiene el propietario del $fichero_a_localizar
	
	$propietario=&obtiene_propietario($res); #/home/Smartphones/jboss/server/default/deploy/cache-invalidation-service.xml
	print LOGS "propietario= ($propietario)\n";
	
	$Domain=$res_troceado[$#res_troceado - 4];
	#print LOGS "dominio= ($Domain)\n";
	
	#Obtiene el directorio base de la instalacion, /home/Smartphones/jboss, -4 desde cache-invalidation-service.xml
	$valor_ini = $#res_troceado - 3 ;
	$valor_fin = $#res_troceado;
	for ($i = $valor_fin; $i >= $valor_ini; $i--) {
		pop (@res_troceado);
	}#for
	
	$Directory = join('/', @res_troceado);
	print LOGS "Base= ($Directory)\n";
	
	#Obtiene el dominio, jboss, el último directorio de $Directory
	@Directory_troceado=split(/\//, $Directory);
	#$Domain=$Directory_troceado[$#Directory_troceado];
	
	#Obtiene el path hasta la instancia, /home/web101/jboss2/server/default, es decir -2 desde cache-invalidation-service.xml
	@res_troceado = split(/\//, $res);
	$valor_ini = $#res_troceado - 1 ;
	$valor_fin = $#res_troceado;
	for ($i = $valor_fin; $i >= $valor_ini; $i--) {
		pop (@res_troceado);
	}#for
	
	$instancia_path = join('/', @res_troceado);
	print LOGS "InstanciaPath= ($instancia_path)\n";
	
	
	print LOGS "Dominio anterior= ($Domain_ant)\n";
	print LOGS "Dominio= ($Domain)\n";
	
	#Solo se estudia la instalacion de todas las obtenidas con "cache-invalidation-service.xml" no repetidas
	# if ("$Domain_ant" ne  "$Domain") {
		
	   #Obtiene la version
	   print LOGS "Calculamos version del jboss\n";
	   $Version=&obtiene_version($Directory);
		
	   #print LOGS "VersionOBTENIDA= ($Version)\n\n";
	   next if ($Version == "");
		# #Crea para cada nuevo dominio el directorio /opt/krb/yavire/cron/jboss4.0/jboss_admin_5 donde se dejan los ficheros para que yavire opere
		
	        print LOGS "Inventariando: $IdJBoss\t$Directory\t\t\t\t${Domain}\t$Version\t$propietario\n" if ($Version ne "");
		print INVENTARIOS "$IdJBoss\t$Directory\t\t\t\t${Domain}\t$Version\t$propietario\n" if ($Version ne "");
		$IdJBoss++;
	# }#if
	$Domain_ant=$Domain;
}#foreach
	

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire JBoss Inventory - Version $versionYV ($fechaActual) \n";
print LOGS "==============================================================================================\n";	

close INVENTARIOS;
close LOGS;

#*===========================================================
#* Fin script: [openWebJBoss3_to_Tomcat6.1_FileInventory.pl]
#*===========================================================


