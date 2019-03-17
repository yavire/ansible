#!/usr/bin/perl

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#Script de tomcat
#Update (9/02/2019)
$versionYV = '2.2.0.3_3';

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";


$DirLog="/opt/krb/yavire/agent/log/inventory";
$fichero_inventario="$INVENTARIO/weekly/yavireTomcatWeeklyFileInventory.txt"; 
`mkdir -p $DirLog` unless (-d $DirLog);

# $maquinaTemp=`uname -n`;
# chomp $maquinaTemp;
# @maquina_troceada = split(/\./, $maquinaTemp);
# $maquina=$maquina_troceada[0];

$vendor="Yavire";
$producto="agent";
$version="2.0";
$dominio="-";
$puerto="57020";
$memoria_min="-";
$memoria_max="-";
$maxThreads="-";
$cluster="-";
$isAdmin=0;
$ruta_a_localizar='/conf/server.xml';
$fichero_a_localizar='server.xml';
$instancia="yavire-agent";
$TipoInstancia="SOFTWARE";
$subTipoInstancia="YAVAGENT";

$inventario_inst="yavireInv_agent.data";
$fichero_log="${DirLog}/yavireInv_agent.log";


open(LOG,">>$fichero_log") || die "Can't open inventory file $fichero_log\n";


($fecha) =  yavireUnix::formatoFechaLog();


print LOG "$fecha: Starting yavireAgentInventory.pl $versionYV\n";

#Define, si es necesario, los directorios seg�n la version


($server_uuid) = yavireUnix::getServerUUID(); 

($system_manufacturer) = yavireUnix::getSystemManufacturer();
 
($ip_address) = yavireUnix::getIPServer();


$DIR_DATA="${INVENTARIO}/data/agent/${server_uuid}";	
`mkdir -p "${DIR_DATA}"` unless (-d "${DIR_DATA}"); 
$fichero_inventario_inst="$DIR_DATA/$inventario_inst"; 
 
 $maquinaTemp=`uname -n`;
 chomp $maquinaTemp;
 @maquina_troceada = split(/\./, $maquinaTemp);
 $system_name = $maquina_troceada[0];

open(INVENTARIO_INST,">$fichero_inventario_inst") || die "Can't open inventory file $fichero_inventario_inst\n";

open(INVENTARIO,"<$fichero_inventario") || die "Can't open inventory file $fichero_inventario\n";



while (<INVENTARIO>) {	
	$linea=$_;
	next unless ($linea =~ /^\//);
	@linea_troceada = split(/%%/, $linea);
	$directorio="$linea_troceada[0]";
	
	$nombreinstancia2="$linea_troceada[1]";
	$nombreinstancia2=lc($nombreinstancia2);
	

	$propietario="$linea_troceada[3]";
	chomp $propietario;

	
	@result=`find $directorio -name $fichero_a_localizar 2> /dev/null`;#Estudio cada valor
	
	next if ($directorio !~ /\/opt\/krb\/yavire\/agent\/yavire\-agent/);
	
	foreach (@result) {
		$res=$_;
		next unless ($res =~ /\/conf\/$fichero_a_localizar/i);
		# ($instancia)= $res =~ /.+\/(.+)\/conf\/$fichero_a_localizar/;	
		
		$puerto="-";
		$ip="-";
		$LogAccess="-";
		$maxThreads="-";
		$nonSSL=0; #Doy por supuesto que no est� definido el NO SSL 
		
			
		#Recorremos el fichero para encontrar el puerto
		$LineaPuerto=0;
		#print "fichero_server=$fichero_server\n";
		open(FILESERVER,"<$res") || print ERROR "Can't open file $res\n";
		
		#Hallo si tiene definici�n non-SSL en cuyo caso, ignoro la SSL
		@fichServidor=<FILESERVER>;
		@salidaGrep = grep(/Define a non-SSL HTTP/, @fichServidor);    
		
		$nonSSL=1 if ($#salidaGrep ne -1);
		close FILESERVER;
		
		open(FILERES,"<$res") || print ERROR "Can't open file $res\n";
		while (<FILERES>) {
			$fich_linea = $_;
			chop($fich_linea);
			
			if ($nonSSL eq 1)
			{
				#print "nonSSL eq 1\n";
				########  SE ESTUDIA EL CASO NO SSL <!-- Define a non-SSL HTTP/1.1 Connector on port 8080 -->  ########		
				next unless (($fich_linea =~ /Define a non-SSL HTTP.+ Connector on port/ ) || ($LineaPuerto == 1));
				$LineaPuerto=1;	
				#next if $fich_linea =~ /Define a non-SSL HTTP.+ Connector on port/;
				
				#Estamos en <Connector     port="8080"
				($puerto) = $fich_linea =~ /<Connector port=\"(\d+)\"/ if ($fich_linea =~ /<Connector port=\"(\d+)\"/);

				#Ponemos la ip del servidor, no esta
				#($ip) = $fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/ if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				($maxThreads) = $fich_linea =~ /maxThreads=\"(\d+)\"/i if ($fich_linea =~ /maxThreads=\"(\d+)\"/i);
				
				#last if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				last if ($fich_linea =~ /\/>/);
				### FIN CASO NO SSL ###
			
		}
		else {
			#print "nonSSL NO eq 1\n";
				########  SE ESTUDIA EL CASO SSL <!-- Define a SSL HTTP/1.1 Connector on port 8443 -->  ########		
				next unless (($fich_linea =~ /Define a SSL HTTP.+ Connector on port/ ) || ($LineaPuerto == 1));
				$LineaPuerto=1;	
				#next if $fich_linea =~ /Define a SSL HTTP.+ Connector on port/;
				
				#Estamos en <Connector     port="8080"
				($puerto) = $fich_linea =~ /<Connector port=\"(\d+)\"/ if ($fich_linea =~ /<Connector port=\"(\d+)\"/);

				#Ponemos la ip del servidor, no esta
				#($ip) = $fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/ if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				($maxThreads) = $fich_linea =~ /maxThreads=\"(\d+)\"/i if ($fich_linea =~ /maxThreads=\"(\d+)\"/i);
				
				#last if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				last if ($fich_linea =~ /\/>/);
				### FIN CASO NO SSL ###
			}
			
					
			}#while     	
			close (FILERES); 
			
			#En el caso de que no encontremos ip especifica
			#$ip = $ip_address if ("$ip" == "-" );
			
			if (${version} =~ /\d+/)
			{
				
				#Caso de servidores EC2 de AWS
				my $substring = "ec2";
				if (lc($server_uuid) =~ /\Q$substring\E/) {
					$aws_public_ip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`;
					$ip_address=`curl http://169.254.169.254/latest/meta-data/local-ipv4`;
					
				}
				else {
				     $aws_public_ip = $ip_address;
				}
				
				print INVENTARIO_INST "versionYAV= ${versionYV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${server_uuid} \%\%  productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${version} \%\% instanceDomain= ${dominio}  \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% awsPublicIP= ${aws_public_ip} \%\% instancePort= ${puerto} \%\% isAdminInstance= ${isAdmin} \%\%  memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\%  propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";	
			        #print INVENTARIO_INST "versionYAV= ${versionYV} \%\% instanceType= ${TipoInstancia} \%\% serverUUID= ${server_uuid} \%\%  serverVendor= ${system_manufacturer} \%\% serverName= ${system_name} \%\% serverIP= ${ip} \%\%  productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${version} \%\% instanceDomain= ${dominio}  \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% instancePort= ${puerto} \%\% isAdminInstance= ${isAdmin} \%\%  memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\%  propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";	
			        
			}
			else {
				print LOG "Tomcat descarted\n";
				# print LOG "versionYAV= ${versionYV} \%\% instanceType= ${TipoInstancia} \%\%  serverVendor= ${system_manufacturer} \%\% serverName= ${system_name} \%\% serverIP= ${ip} \%\%  productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${version} \%\% instanceDomain= ${dominio}  \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% instancePort= ${puerto} \%\% isAdminInstance= ${isAdmin} \%\%  memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\%  propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";	
			}
		}#foreach
	}#while


($fecha) =  yavireUnix::formatoFechaLog();

print LOG "$fecha: Finisihing  yavireAgentInventory.pl $versionYV\n";

close LOG;
close INVENTARIO;
close INVENTARIO_INST;




