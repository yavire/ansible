#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireOracle_FileInventory.pl
#*=========================================================
#* Fecha Creación: [27/04/2014]
#* Autor: Fernando Oliveros
#* Compañia: kronobyte
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Inventario semanal de ubicacion de instancias Oracle
#*    

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


#Script de Jboss
$versionYV="2.2.0.1";
$INVENTORY="/opt/krb/yavire/agent/inventory/weekly";
$inventoryFile="$INVENTORY/yavireOracle_FileInventory.txt"; 
$LOG="/opt/krb/yavire/agent/log/inventory";
$fichero_log="$LOG/yavireOracle_FileInventory.log";
$fichero_a_localizar='oratab';
#$uni='/';
$producto="oracle";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de log $fichero_log\n";

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "==============================================================================================\n";
print LOGS "   Starting yavire Oracle Inventory - Version $versionYV ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";
print LOGS "      File to Found : $fichero_a_localizar\n";
print LOGS "\n==============================================================================================\n\n";


#$boot='boot.log';
#$patron_version='Release ID:'; #Es el patron para encontrar la version del jboss en el fichero boot.log#

`mkdir -p $INVENTORY` unless (-d "$INVENTORY");


#Se abre el fichero para guardar los inventarios
open(INVENTARIOS,">$inventoryFile") || die "problemas abriendo fichero de inventario $inventoryFile\n";

# print INVENTARIOS "Directory\t\t\t\t\tDomain\tVersion\tPropietario\n";
# print INVENTARIOS "=========\t\t\t\t\t=======\t=======\t=========\n";

#Configura la fecha y hora para el log y salida de pantalla
print LOGS "Se realiza el inventario de los Oracle instalados\n";
print LOGS "Fecha: $fechaActual\n";
print LOGS "--------------------------------------------------------\n\n";

my @files = yavireUnix::getConfFilesFromFilesystems(\*LOGS, $fichero_a_localizar);

print  "Finding file $fichero_a_localizar\n";
#print LOGS "Se han encontrado los siguientes ficheros\n";

foreach(@files)
{
    print  "$_\n";
}  

foreach (@files) {
		$linea=$_;
		chop $linea;
		# print $linea;
		print INVENTARIOS  "$linea\n";

}#foreach result
	

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire Oracle Inventory - Version $versionYV ($fechaActual) \n";
print LOGS "==============================================================================================\n";	


close INVENTARIOS;
close LOGS;

#*===========================================================
#* Fin script: [yavireOracle_FileInventory.pl]
#*===========================================================

