#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';



#* NombreFichero: yavireTomcatWeeklyFileInventory.pl
#*=========================================================
#* Fecha Creaci�n: [01/03/2013]
#* Autor: Fernando Oliveros
#* Compa�ia: kronobyte
#* Email: 
#* Web: 
#*=============================================
#* Descripci�n:
#*    Inventario semanal de ubicacion de instancias tomcat
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
	#Obtiene el propietario de /opt/alfresco/tomcat/conf/server.xml
	local($fich) = $_[0];
	$linea = `ls -l $fich`;
	@fich_troceado = split(/\s+/, $linea);
	#print "fich_troceado= 0= $fich_troceado[0] 1= $fich_troceado[1] 2= $fich_troceado[2] 3= $fich_troceado[3] 4= $fich_troceado[4] 5= $fich_troceado[5] 6= $fich_troceado[6] 7= $fich_troceado[7]";
	return $fich_troceado[2];
}



sub estudia_descartarlo {
	#Mira lo que contiene ese directorio para descartarlo, o bien darlo como una instalaci�n buena.
	#* En el directorio ../conf tiene que existir el subdirectorio Catalina
	#* A la altura del subdirectorio /conf  existen los siguientes subdirectorios
		#- work
		#- bin
		#- webaaps
	#***EXCEPCION:	El agent-yavire  (para no inventariar dos veces)
	
	local($dir) = $_[0];
	local(@linea) = `ls $dir`;
	#print "estudia_descartarlo: linea=@linea\n";
	local($lineaJunta) = join(' ', @linea);
	local($descartar)="false";
	local($dirconf)="$dir/conf";
	
	
	if (($lineaJunta !~ /work/) && ($lineaJunta !~ /bin/) && ($lineaJunta !~ /webapps/)) 
	{
		
		$descartar="true";
		print LOGS "$dir Se descarta por no contener algunos estos directorios: work, bin y webapps.\n";
	}
	else {
		$descartar="false";
	}
	
	if ($dir =~ /\/\./) {
		$descartar="true";
		print LOGS "$dir Se descarta.\n";
	}
	
	#if ($dir =~ /yavire\-agent/) {
#		 $descartar="true";
#		 print LOGS "$dir Se descarta por ser el agente.\n";
#	}
	
	#Comprueba si dentro del directorio conf existe el dir Catalina
	#opendir ($dirconfPuntero, $dirconf);
	#local(@listado) = readdir $dirconfPuntero;
	#closedir $dirconfPuntero;
	#$dirconfJunto = join(' ', @listado);
	#if ($dirconfJunto !~ /Catalina/) {
	#	$descartar="true";
	#	print LOGS "$dir Se descarta por no contener al directorio Catalina dentro del dir conf\n";
	#	}	
	return $descartar;
}


sub obtieneVersion {
	local($dir) = $_[0];
        print LOGS "Directorio: ($dir)\n";
        
        
        #Buscamos la version a trav�s del ejecutable version.sh que viene en el tomcat
	print LOGS "Version ejecutable: ($ejecutableVersion)\n";
	local($result)=`find $dir -name $ejecutableVersion 2> /dev/null`;#Dev algo as�: ./bin/version.sh
	$ENV{JAVA_HOME}=$rutaJava;
	chomp $result;
	print LOGS "Se va a ejecutar : ($result)\n";
	print LOGS "JAVA_HOME:  $ENV{JAVA_HOME}\n";

	$salida=`$result`;
	# print "VERSION: $salida\n";
	#local($VersionEjecutable)= $salida =~ /Server version: Apache Tomcat\/(\d+\.\d+)/;	
	#local($VersionEjecutable)= $salida =~ /Server number:  (\d+\.\d+\.\d+)/;
	local($VersionEjecutable)= $salida =~ /Server version: Apache Tomcat\/(\d+\.\d+\.\d+)/;
	# print "VERSION2: $VersionEjecutable\n";
	
	if ($VersionEjecutable eq '') {
	   #Si no funciona el ejecutable java, intentamos con directorio
	   #Analizamos la ruta del directorio por si indica la version 5.0/5.5/6.0
           local($VersionDir)= $dir =~ /(\d+\.\d+)/;
           #print LOGS "versionDir: $VersionDir\n";
           #print "versionDir: $VersionDir\n";
        
           if ($VersionDir eq '') {
	      print LOGS "ERROR: al obtener version del tomcat.\n\n";
	      print LOGS "$salida\n";
	      $Version = 'Version=Error';
           }
           else {
              $Version = ${VersionDir};
              print LOGS "VersionDir=(${Version})\n";
           }
	   
	}
	else {
	   $Version = $VersionEjecutable;
	   print LOGS "VersionEjecutable=(${Version})\n";
	}
        
	return $Version;
}


sub obtieneVersionOLD {
	local($dir) = $_[0];
        print LOGS "Directorio: ($dir)\n";
        
        #Analizamos la ruta del directorio por si indica la version 5.0/5.5/6.0
        local($VersionDir)= $dir =~ /(\d+\.\d+)/;
        #print LOGS "versionDir: $VersionDir\n";
        print "versionDir: $VersionDir\n";
        
        if ($VersionDir eq '') {
           #Buscamos la version a trav�s del ejecutable version.sh que viene en el tomcat
	   print LOGS "Version ejecutable: ($ejecutableVersion)\n";
	   local($result)=`find $dir -name $ejecutableVersion 2> /dev/null`;#Dev algo as�: ./bin/version.sh
	   $ENV{JAVA_HOME}=$rutaJava;
	   chomp $result;
	   print LOGS "Se va a ejecutar : ($result)\n";
	   print LOGS "JAVA_HOME:  $ENV{JAVA_HOME}\n";

	   $salida=`$result`;
	   # print "VERSION: $salida\n";
	   #local($VersionEjecutable)= $salida =~ /Server version: Apache Tomcat\/(\d+\.\d+)/;	
	   local($VersionEjecutable)= $salida =~ /Server number:  (\d+\.\d+\.\d+)/;
	   print "VERSION2: $VersionEjecutable\n";
		
	   if ($VersionEjecutable eq '') {
	      print LOGS "ERROR: al obtener version del tomcat.\n\n";
	      print LOGS "$salida\n";
	      $Version = 'Version=Error';
	   }
	   else {
	      $Version = $VersionEjecutable;
	      print LOGS "VersionEjecutable=(${Version})\n";
	   }
        }
        else {
           $Version = ${VersionDir};
           print LOGS "VersionDir=(${Version})\n";
        }
        
        
	return $VersionEjecutable;
}

#*===========================================================
#* Fin de declaraci�n de funciones
#*===========================================================

   
#*===========================================================
#* Definici�n de variables
#*===========================================================

#Script de Apache
$versionYV="2.2.0.3_3 (9/02/2019)";

$INVENTORY="/opt/krb/yavire/agent/inventory/weekly";
$fichero_inventory="$INVENTORY/yavireTomcatWeeklyFileInventory.txt"; 
$LOG="/opt/krb/yavire/agent/log/inventory";
$fichero_log="$LOG/yavireTomcatWeeklyFileInventory.log"; 
$ruta_a_localizar='conf/server.xml';
$fichero_a_localizar='server.xml';
$ejecutableVersion='version.sh';
$dir_cron="/opt/krb/yavire/agent/cron";
$producto="tomcat";
$Domain="-";
$rutaJava='/opt/krb/yavire/agent/java';

$dirFileSalida='/opt/krb/yavire/agent/tmp';
$FileSalida="${dirFileSalida}/Salida.txt";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

#Script de Tomcat 5 a 8

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de log $fichero_log\n";

$fechaActual=yavireUnix::formatoFechaLog();

print LOGS "==============================================================================================\n";
print LOGS "   Starting yavire Tomcat Inventory - Version $versionYV ($fechaActual)\n";
print LOGS "==============================================================================================\n\n";

#Control de errores
#exit 1 Parametros pasados de forma incorrecta.


`mkdir -p $dirFileSalida` unless (-d "$dirFileSalida");
`mkdir -p $INVENTORY` unless (-d "$INVENTORY");


#Se abre el fichero para guardar los inventarios
#Configura la fecha y hora para el log y salida de pantalla

open(INVENTARIOS,">$fichero_inventory") || die "problemas abriendo fichero de inventario $fichero_inventory\n";
# print INVENTARIOS "Fecha de creacion del fichero: $fechaActual\n";
# print INVENTARIOS "Directory%%Domain%%Version%%Propietario\n";
# print INVENTARIOS "=========%%=======%%=======%%=========\n";


my @files = yavireUnix::getConfFilesFromFilesystems(\*LOGS, $fichero_a_localizar);

print LOGS "Se han encontrado los siguientes ficheros\n";


foreach(@files)
{
    print LOGS "$_\n";
}   


#Todo el path del fichero que define que existe una instalacion de Tomcat
#/opt/alfresco/tomcat/conf/server.xml

$antDirectory="";
$antDomain="";
$antVersion="";
$antpropietario="";
$anterior="";

foreach (@files) {
	$res=$_;
	#print LOGS "\nProcesando tomcat: $res \n";
	next if ("$res" eq "$anterior");
	next unless ($res =~ /\/${ruta_a_localizar}/i);
	
	print LOGS "Procesando tomcat: $res \n";
	
	#Cada fichero /opt/alfresco/tomcat/conf/server.xml
	@res_troceado = split(/\//, $res);
	
	#Dominio es Smartphones, es decir tres directorios para atr�s.
	$Domain=$res_troceado[$#res_troceado - 3];
	#print "Domain=$Domain\n";
	
	#Obtiene el propietario del $fichero_a_localizar
	$propietario=&obtiene_propietario($res); #/opt/alfresco/tomcat/conf/server.xml
	#print "propietario= $propietario\n";
	
	#Obtiene el directorio base de la instalacion
	$valor_ini = $#res_troceado - 1 ;
	$valor_fin = $#res_troceado;
	for ($i = $valor_fin; $i >= $valor_ini; $i--) {
		pop (@res_troceado);
	}#for
	$Directory = join('/', @res_troceado);  #/opt/alfresco/tomcat       /conf/server.xml
	#print "Directory=$Directory\n";
	
	#Estudia si lo descarta
	$descarta=&estudia_descartarlo($Directory); #Si este directorio no contiene una serie de ficheros/directorios minimos lo descarta
	next if ("$descarta" eq "true");
	
	#Obtiene la version
	$Version=&obtieneVersion($Directory);
	
	print LOGS "VERSION: ($Version)\n";
	print "VERSION: ($Version)\n";
	
	if ($Version ne 'Version=Error') {
	   #Crea para cada nuevo dominio el directorio /opt/krb/yavire/cron/tomcat/dominio donde se dejan los ficheros para que yavire opere
	   `mkdir -p ${dir_cron}/${producto}${Version}/${Domain}` unless (-d "${dir_cron}/${producto}${Version}/${Domain}");
	   #print "$Directory%%${Domain}%%$Version%%$propietario\n";
	   $repe = "false";
	   $repe = "true" if (("$antDirectory" eq "$Directory") && ("$antDomain" eq "$Domain") && ("$antVersion" eq "$Version") && ("$antpropietario" eq "$propietario"));
	   print INVENTARIOS "$Directory%%${Domain}%%$Version%%$propietario\n" if ($repe eq "false") ;
	   $antDirectory="$Directory";
	   $antDomain="$Domain";
	   $antVersion="$Version";
	   $antpropietario="$propietario";
	   $anterior="$res";
	}
	
	
}#foreach

$fechaActual=yavireUnix::formatoFechaLog();
print LOGS "\n\n==============================================================================================\n";
print LOGS "    Finishing yavire Tomcat Inventory - Version $versionYV ($fechaActual) \n";
print LOGS "==============================================================================================\n";		

close INVENTARIOS;
close LOGS;

#*===========================================================
#* Fin script: yavireTomcatWeeklyFileInventory.pl]
#*===========================================================


