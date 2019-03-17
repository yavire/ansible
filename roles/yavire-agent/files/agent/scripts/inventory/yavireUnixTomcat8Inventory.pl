#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#Script de tomcat
$versionYAV = '2.2.0.2_1';


#* NombreFichero: yavireUnixTomcat8Inventory.pl
#*=========================================================
#* Fecha Creación: [29/11/2015]
#* Autor: Fernando Oliveros
#* Compañia: Kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Genera el inventario de Tomcat 8
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

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";

$baseAgentDirUnix="/opt/krb/yavire/agent";
$DirLog="/opt/krb/yavire/agent/log/inventory";

`mkdir -p $DirLog` unless (-d $DirLog);
##Eso es una linea del contenido:
	#Directory%%Domain%%Version%%Propietario
	#=========%%=======%%=======%%=========
	#/home/gmaps/apache-tomcat6-Front%%gmaps%%6.0%%gmaps
	#/home/gmaps/apache-tomcat6-GS%%gmaps%%6.0%%gmaps

# $maquinaTemp=`uname -n`;
# chomp $maquinaTemp;
# @maquina_troceada = split(/\./, $maquinaTemp);
# $maquina=$maquina_troceada[0];

$vendor="Apache Software Foundation";
$producto="tomcat";
$subversionTomcat="8";
$ip_address="-";
$instancePort="-";
$memoria_min="-";
$memoria_max="-";
$maxThreads="-";
$cluster="-";
$machine="-";
$isAdmin="-";

$ruta_a_localizar='/conf/server.xml';
$fichero_a_localizar='server.xml';
$dominio="-";
$instancia="-";
$TipoInstancia="SOFTWARE";
$subTipoInstancia="APPSERVER";

$ficheroInventarioSemanal="yavireTomcatWeeklyFileInventory.txt";
$ficheroInventarioDiario="yavireInv_tomcat8.data";

#BORRAR


# $instancia="";
# $TipoInstancia="SOFTWARE";
# $subTipoInstancia="APPSERVER";
# $LogAccess="-";
# # $ruta_a_localizar='/config/server.xml';
# $fichero_a_localizar='config.xml';

# $baseAgentDirWin="C:\\krb\\yavire\\agent";
# 

#FIN BORRAR



# #Define, si es necesario, los directorios según la version
# $DIR_DATA="${INVENTARIO}/data/tomcat8/${maquina}";	
# `mkdir -p "${DIR_DATA}"` unless (-d "${DIR_DATA}"); 
# $inventorio_inst="yavireInv_tomcat8.data";
# $fichero_inventorio_inst="$DIR_DATA/$inventorio_inst"; 
# $fichero_log="${DirLog}/yavireInv_tomcat8.log";


#*===========================================================
#* Cuerpo del programa 
#*===========================================================

   ($uuid) = yavireUnix::getServerUUID(); 
  
   print $server_uuid;

   ($system_manufacturer) = yavireUnix::getSystemManufacturer();
 
   ($ip_server) = yavireUnix::getIPServer();
  
   $dirFichDataSemanal="$baseAgentDirUnix/inventory/weekly/"; 
   $rutaFicheroInventarioSemanal="$dirFichDataSemanal$ficheroInventarioSemanal"; 
   if (-d $dirFichDataSemanal) {
       print LOG "El directorio $dirFichDataSemanal existe\n";
   } 
   else {
       print LOG "Creamos directorio  $dirFichDataSemanal \n";
       print "$dirFichDataSemanal\n";
       system 1, "mkdir $dirFichDataSemanal";
    
   }
   
   $dirFichDataDiario="$baseAgentDirUnix/inventory/data/tomcat8/$uuid/"; 
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

   $szFichLog="$baseAgentDirUnix/log/inventory/yavireInv_tomcat8.log";

   $fecha=yavireUnix::formatoFechaLog();

   print "LOG: $szFichLog\n";

   open(LOGS,">>$szFichLog") || die "problemas abriendo fichero de inventario inst $szFichLog\n";

   open(INVENTARIO_DIARIO,">$rutaFicheroInventarioDiario") || die "problemas abriendo fichero de inventario diario $rutaFicheroInventarioDiario\n";

   open(INVENTARIO_SEMANAL,"<$rutaFicheroInventarioSemanal") || die "problemas abriendo fichero de inventario $rutaFicheroInventarioSemanal\n";



while (<INVENTARIO_SEMANAL>) {	
	$linea=$_;
	
	#print "Linea leida: $linea\n";
	
	next unless ($linea =~ /^\//);
	@linea_troceada = split(/%%/, $linea);
	$directorio="$linea_troceada[0]";
	#No utilizamos el dominio del inventario semanal, lo dejamos como UNDEFINED, el núcleo dee yavire le pondrá el dominio dependiendo de la máquina.
	#$dominio="$linea_troceada[1]";
	$nombreinstancia2="$linea_troceada[1]";
	$nombreinstancia2=lc($nombreinstancia2);
	
	$subversionTomcat="$linea_troceada[2]";
	$propietario="$linea_troceada[3]";
	chomp $propietario;
	
	# print "propietario=(${propietario})\n";
	# print "fichero_a_localizar=(${fichero_a_localizar})\n";
	# print "directorio=$directorio\n";
		
	next if ($subversionTomcat !~ /8\./);
	
	@result=`find $directorio -name $fichero_a_localizar 2> /dev/null`;#Estudio cada valor
	
	foreach (@result) {
		$res=$_;
		print "RES: $res\n";
		
		next unless ($res =~ /\/conf\/$fichero_a_localizar/i);
		($instancia)= $res =~ /.+\/(.+)\/conf\/$fichero_a_localizar/;	

                if ($instancia =~ /yavire\-agent/) {
                    print "$dir Se descarta por ser el agente.\n";
                    next;
                }
		#print "\n\nEMPIEZA\n";
		#print "res=$res";
		$instancePort="-";
		$ip_address="-";
		$LogAccess="-";
		$maxThreads="-";
		$nonSSL=0; #Doy por supuesto que no está definido el NO SSL 
		
		#print "res=$res\n";
		#print "ip ANTES=$ip\n";
		#print "puerto ANTES=$instancePort\n";
		#print "maxThreads ANTES=$maxThreads\n";
		
		#Estudia LogAccess
		#@lineaCustomLog= grep (/^[\s]*CustomLog/i, `cat $res`);
		#$juntaLineaCustomLog = join('', @lineaCustomLog);
		##print "juntaLineaCustomLog=$juntaLineaCustomLog\n";
		#if ($juntaLineaCustomLog !~ /\d+/)
		#{
		#	#Es este formato CustomLog logs/access_log common
		#	($pathRelativo)= $juntaLineaCustomLog =~ /CustomLog (.+) [combined]/i;	
		#	$LogAccess="${directorio}/${pathRelativo}";
		#	#print "LogAccess Corto=$LogAccess\n";
		#}
		#else {
		#	#Es este formato: CustomLog "|/usr/sbin/rotatelogs -l /home/franquicias/apache/logs/access_log 86400" combined
		#	($LogAccess)= $juntaLineaCustomLog =~ /CustomLog \"\|.+ -l (.+access_log) \d+\" combined/i;	
		#	#print "LogAccess Largo=$LogAccess\n";
		#	}
	
		
		#Recorremos el fichero para encontrar el puerto
		$LineaPuerto=0;
		#print "fichero_server=$fichero_server\n";
		open(FILESERVER,"<$res") || print ERROR "Existen problemas al abrir el fichero $res\n";
		
		#Hallo si tiene definición non-SSL en cuyo caso, ignoro la SSL
		@fichServidor=<FILESERVER>;
		@salidaGrep = grep(/Define a non-SSL\/TLS HTTP/, @fichServidor);    
		print "salida=$#salidaGrep fin\n";
		$nonSSL=1 if ($#salidaGrep ne -1);
		close FILESERVER;
		
		open(FILERES,"<$res") || print ERROR "Existen problemas al abrir el fichero $res\n";
		while (<FILERES>) {
			$fich_linea = $_;
			chop($fich_linea);
			
			#print "$fich_linea";
			
			if ($nonSSL eq 1)
			{
				#print "nonSSL eq 1\n";
				########  SE ESTUDIA EL CASO NO SSL <!-- Define a non-SSL HTTP/1.1 Connector on port 8080 -->  ########		
				next unless (($fich_linea =~ /Define a non-SSL\/TLS HTTP.+ Connector on port/ ) || ($LineaPuerto == 1));
				$LineaPuerto=1;	
				#next if $fich_linea =~ /Define a non-SSL HTTP.+ Connector on port/;
				
				print "Paso 1";
				
				#Estamos en <Connector     port="8080"
				($instancePort) = $fich_linea =~ /<Connector port=\"(\d+)\"/ if ($fich_linea =~ /<Connector port=\"(\d+)\"/);
				($ip_address) = $fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/ if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				($maxThreads) = $fich_linea =~ /maxThreads=\"(\d+)\"/i if ($fich_linea =~ /maxThreads=\"(\d+)\"/i);
				
				#last if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				last if ($fich_linea =~ /\/>/);
				### FIN CASO NO SSL ###
			
		        }
		        
			else {
				print "Paso 2";
				#print "nonSSL NO eq 1\n";
				########  SE ESTUDIA EL CASO SSL <!-- Define a SSL HTTP/1.1 Connector on port 8443 -->  ########		
				next unless (($fich_linea =~ /Define a SSL\/TLS HTTP.+ Connector on port/ ) || ($LineaPuerto == 1));
				$LineaPuerto=1;	
				#next if $fich_linea =~ /Define a SSL HTTP.+ Connector on port/;
				
				#Estamos en <Connector     port="8080"
				($instancePort) = $fich_linea =~ /<Connector port=\"(\d+)\"/ if ($fich_linea =~ /<Connector port=\"(\d+)\"/);
				($ip_address) = $fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/ if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				($maxThreads) = $fich_linea =~ /maxThreads=\"(\d+)\"/i if ($fich_linea =~ /maxThreads=\"(\d+)\"/i);
				
				#last if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				last if ($fich_linea =~ /\/>/);
				### FIN CASO NO SSL ###
			}
			
					
			}#while     	
			close (FILERES); 
			$ip_address = $ip_server if ("$ip_address" == "-" );
			if (${subversionTomcat} =~ /\d+/)
			{
				# print "INSTANCIA: $instancia\n";
				# print "INSTANCIA2: $nombreinstancia2\n";
				# $instancia = join  "", $instancia,'-',$nombreinstancia2; 
				#print INVENTARIO_INST "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";	
				print INVENTARIO_DIARIO "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${uuid} \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${subversionTomcat} \%\% instanceDomain= ${dominio} \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% instancePort= ${instancePort} \%\% isAdminInstance= ${isAdmin} \%\% memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\% machineInstance= ${machine} \%\% propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";
			}
			else {
				print LOGS "Se descarta el apache:\n";
				print LOGS "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\%  LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";
			}
		}#foreach
	}#while

close LOGS;
close INVENTARIO_DIARIO;
close INVENTARIO_SEMANAL;


#*===========================================================
#* End script: yavireUnixTomcat8Inventory.pl]
#*===========================================================
