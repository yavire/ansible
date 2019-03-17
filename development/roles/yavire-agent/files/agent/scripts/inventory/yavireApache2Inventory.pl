#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireApache2Inventory.pl
#*=========================================================
#* Fecha Creación: [24/03/2015]
#* Autor: Fernando Oliveros
#* Compañia: Yavire
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Inventario detallado de los Apaches
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





#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";
$invDaily="yavireInv_apache2.data";

$DirLog="/opt/krb/yavire/agent/log/inventory";
$fichero_log="${DirLog}/yavireInv_apache2.log"; 
$ficInvWeekly="$INVENTARIO/weekly/yavireApacheWeeklyFileInventory.txt";
   
#*===========================================================
#* Definición de variables
#*===========================================================

$versionYV = '2.2.0.2_1';

$TipoInstancia="SOFTWARE";
$subTipoInstancia="WEBSERVER";
$producto="apache";
$versionApache="-";
$ip="-";
$puerto="-";
$memoria_min="-";
$memoria_max="-";
$max_threads="-";
$cluster="-";
$producto_con_version="apache2";
$fichero_a_localizar='httpd*.conf';
$dominio="-";
$instancia="-";



#*===========================================================
#* Cuerpo del programa 
#*===========================================================

($server_uuid) = yavireUnix::getServerUUID(); 
($ip_address) = yavireUnix::getIPServer();


$maquinaTemp=`uname -n`;
chomp $maquinaTemp;
@maquina_troceada = split(/\./, $maquinaTemp);
$maquina=$maquina_troceada[0];


$DIR_DATA="${INVENTARIO}/data/apache2/${server_uuid}";	
`mkdir -p "${DIR_DATA}"` unless (-d "${DIR_DATA}"); 

print "DIR_DATA: $DIR_DATA\n";

$ficInvDaily="$DIR_DATA/$invDaily";

# `mkdir -p $DIR_DATA` unless (-d $DIR_DATA); 
# `mkdir -p $DirLog` unless (-d $DirLog);


$datelog=yavireUnix::formatoFechaLog();

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de inventario inst $fichero_log\n";

open(INVENTARIO_DIARIO,">$ficInvDaily") || die "problemas abriendo fichero de inventario diario $ficInvDaily\n";
open(INVENTARIO_SEMANAL,"<$ficInvWeekly") || die "problemas abriendo fichero de inventario semanal $ficInvWeekly\n";


print LOGS "\n\n************************************************************************\n";
print LOGS "\n\nyavire daily Apache inventory - Version $versionYV ($datelog)\n\n";

while (<INVENTARIO_SEMANAL>) {	
	$linea=$_;
	next unless ($linea =~ /^\//);
	print LOGS "Tratando instalacion $linea... \n";
	print  "Tratando instalacion $linea... \n";
	
	@linea_troceada = split(/%%/, $linea);
	
	$dominio="$linea_troceada[0]";
	$directorio="$linea_troceada[1]";
	
	@subDirectorySeparate = split(/\//, $directorio);
		
	$instancia2=$subDirectorySeparate [$#subDirectorySeparate  - 1];
	#print "Domain=$Domain\n";
	
	# $nombreinstancia2="$linea_troceada[0]";
	$instancia2 = lc($instancia2);
	print "NOMBREINSTANCIA: $instancia2\n";
	
	$versionApache="$linea_troceada[3]";
	$propietario="$linea_troceada[4]";
	chomp $propietario; 
	
	#print "propietario=${propietario}fin\n";	
	
	$fichConf = "$linea_troceada[1]/$linea_troceada[2]";
	
	print "CONF: $fichConf\n";
	print "VERSION: $versionApache\n";
	print "PROPIETARIO: $propietario\n";
			
	print LOGS "Tratando fichero de configuracion $fichConf \n";
		
		 ($instancia)= $fichConf =~ /.+\/(.+)\/conf\/httpd.*\.conf/;
		 $instancia = join  "", $instancia,'-',$instancia2; 
		
		
		 print  "INSTANCIA ($instancia)\n";
		# #print "\n\nEMPIEZA\n";
		
	$puerto="-";
	$ip="-";
	$LogAccess="-";
		
	#Estudia LogAccess
	@lineaCustomLog= grep (/^[\s]*CustomLog/i, `cat $fichConf`);
	$juntaLineaCustomLog = join('', @lineaCustomLog);
	print "juntaLineaCustomLog=$juntaLineaCustomLog\n";
	if ($juntaLineaCustomLog !~ /\d+/)
	{
		#Es este formato CustomLog logs/access_log common
		($pathRelativo)= $juntaLineaCustomLog =~ /CustomLog (.+) [combined]/i;	
		$LogAccess="${directorio}/${pathRelativo}";
		#print "LogAccess Corto=$LogAccess\n";
	}
	else {
		#Es este formato: CustomLog "|/usr/sbin/rotatelogs -l /home/franquicias/apache/logs/access_log 86400" combined
		($LogAccess)= $juntaLineaCustomLog =~ /CustomLog \"\|.+ -l (.+access_log) \d+\" combined/i;	
		#print "LogAccess Largo=$LogAccess\n";
	}

	#IP
	#Busca este patron Listen 10.44.6.165:4080
	@lineaIP= grep (/^listen \d+\.\d+\.\d+\.\d+:/i, `cat $fichConf`);
	$ipJunta = join('', @lineaIP);
	#print "IPJUNTA: $ipJunta\n";
		
	if ($ipJunta eq '') {
              #Busca este patron Listen URL:4080
              print LOGS "\n";
	      @lineaIP= grep (/^listen .*:/i, `cat $fichConf`);
	      $ipJunta = join('', @lineaIP);
		   
	      if ($ipJunta eq '') { 
		      print LOGS "Encontrado patron Listen <puerto>\n";
		      @lineaIP= grep (/^Listen \d+/i, `cat $fichConf`);
		      $ipJunta = join('', @lineaIP);
		      ($puerto)= $ipJunta =~ /^listen (\d+)/i;
		      $ip=$ip_address;
		      #print LOGS "puerto 1.1=($puerto)\n";
		      #print LOGS "Ip 1.1=($ip)\n";
	      }
	      else {
		   	print LOGS "Encontrado patron Listen <DNS>:<puerto>\n";
		   	($ip,$puerto)= $ipJunta =~ /^listen (.*):(\d+)/i if ("$ipJunta" ne "");
		        #print LOGS "puerto 1.2=($puerto)\n";
		        #print LOGS "Ip 1.2=($ip)\n";
	      }
		   
	}
	else {
            print LOGS "Encontrado patron Listen <IP>:<puerto>\n";
		   #print LOGS "ipJunta=($ipJunta)\n";
		   #print LOGS "puerto 1=($puerto)\n";
	   ($ip,$puerto)= $ipJunta =~ /^listen (\d+\.\d+\.\d+\.\d+):(\d+)/i if ("$ipJunta" ne "");
	   #print LOGS "puerto 2=($puerto)\n";
		
	   if ($ip !~ /\d+\.\d+\.\d+\.\d+/)
	   {
		$ip=$ip_address;	  
		   }#if
		   #print LOGS "puerto 2=($puerto)\n";
		   #print LOGS "Ip 2=($ip)\n";
	   }
	
	   #SSL
	   #Busca linea ssl. Si es ssl, se descarta el anterior puerto, y se machaca con el suyo.
		
	   @resultLineaSsl= grep (/Include conf\/extra\/httpd*\-ssl\.conf/i, `cat $fichConf`);
	   $LineaSslJunta = join('', @resultLineaSsl);
		
	   #print "lineaSsl=${lineaSsl}fin de res= $res\n";
	   if ($LineaSslJunta =~ /Include conf\/extra\/httpd*\-ssl\.conf/)
	   {
		#print "Tiene SSL, y LineaSslJunta=$LineaSslJunta\n";	
		$ssl="SI";
		#Halla el puerto con ssl
		($ficheroSsl)= $LineaSslJunta =~ /Include (conf\/extra\/httpd.*\-ssl\.conf)/;
		#print "LineaSslJunta=${LineaSslJunta}fin\n";
		#print "res=$res\n";
		#print "ficheroSsl=${ficheroSsl}fin\n";
		($principioRes)= $fichConf =~ /(.+)\/conf\/httpd.*\.conf/;	
		#print "principioRes=${principioRes}\n";
		$fichSslConf="${principioRes}/${ficheroSsl}";
		@resultListen = grep (/^Listen \d+/i, `cat $fichSslConf`);
		$LinearesultListen = join('', @resultListen);
		#print "LinearesultListen=$LinearesultListen\n";
		($puerto)= $LinearesultListen =~ /Listen (\d+)/;
			
	  }
	  else {
		#print "NO NO NO Tiene SSL, y LineaSslJunta=$LineaSslJunta\n";
		$ssl="NO";
		#Halla el puerto sin ssl
		if ("$puerto" eq "-")
		{
			#print "Entra en puerto - \n";
			@resultListenRes = grep (/^Listen \d+/i, `cat $fichConf`);
				
			$LineaResultListenRes = join('', @resultListenRes);
			#print "Entra LineaResultListenRes=$LineaResultListenRes\n";
			($puerto)= $LineaResultListenRes =~ /^listen (\d+)/i;
		};#if puerto == "-"
			
			
	};#if else
	
	$directorio=$fichConf;
		
	if (${versionApache} =~ /\d+/)
	{
		#Ejemplo IIS
		#versionYAV= 2.1.0.2_2        %% instanceType= WEB                      %%  serverUUID= 00710ABB-1BFE  %%  productVendor= Microsoft Corporation %% productName= IIS %%                productVers= 7.5 %%                     instanceDomain= - %% i                  nstanceName= Default Web S %% instanceIP= 192.16 %% instancePort= 80 %%              isAdminInstance= 0 %%    memoryMin= 64 %%                        memoryMax= 64 %%                          maxThreads= 150 %%                      clusterInstance= - %%                propietary= Propietario        %% LogAccess=C:\inetpub\lo %% instanceDir= C:\Windows\system32\inetsrv %%
		print INVENTARIO_DIARIO "versionYAV= ${versionYV} \%\% instanceType= ${TipoInstancia}  \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${server_uuid}  \%\% productVendor= Apache Software Foundation %% productName= ${producto} \%\% productVers= ${versionApache} \%\% instanceDomain= ${dominio}  \%\% instanceName= ${instancia} \%\% instanceIP= ${ip} \%\% instancePort= ${puerto} \%\% isAdminInstance= 0 \%\% memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${max_threads} \%\% clusterInstance= ${cluster} \%\% propietary= ${propietario} \%\% LogAccess=$LogAccess \%\% instanceDir= $directorio  \%\%\n";
		#print LOGS "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${max_threads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";
	}
	else {
		print LOGS "Se descarta el apache:\n";
		#print LOGS "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${max_threads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\%  LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";
	}

}#while

close LOGS;
close INVENTARIO_SEMANL;
close INVENTARIO_DIARIO;
