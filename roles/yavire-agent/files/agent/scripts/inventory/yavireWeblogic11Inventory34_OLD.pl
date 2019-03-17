#!/usr/bin/perl

use POSIX qw(strftime);

#Script de Weblogic 11
$versionYV = '2.1.0.0_2';

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventario";


$DirLog="/opt/krb/yavire/agent/log/inventario";
$fichero_inventario="$INVENTARIO/semanal/yavireWeblogic8.1_0to11.0_FileInventory.txt";
`mkdir -p $DirLog` unless (-d $DirLog);


$maquinaTemp=`uname -n`;
chomp $maquinaTemp;
@maquina_troceada = split(/\./, $maquinaTemp);
$maquina=$maquina_troceada[0];

$producto="weblogic";
#$version="2.";
$ip="-";
$puerto="-";
$memoria_min="-";
$memoria_max="-";
$maxThreads="-";
$ssl="NO";
$snmp="-";
$acronimo="UNDEFINED";
$cluster="-";
$deploy="Si";
$producto_con_version="weblogic11";
#$ruta_a_localizar='/conf/server.xml'; #Creo que aqui no hace falta
$fichero_a_localizar='config.xml';
$dominio="-";
$instancia="-";
$TipoInstancia="WEB";

#Calcula la IP de la máquina
#print "Va a calcular la IP de la maquina\n";
$IpMaq=&IpMaquina();
#print "Ha calculado la ip de la maquina\n";

#Define, si es necesario, los directorios según la version
$DIR_DATA="${INVENTARIO}/data/${producto_con_version}/${maquina}";	
`mkdir -p "${DIR_DATA}"` unless (-d "${DIR_DATA}"); 
$inventario_inst="yavireInv_${producto_con_version}.data";
$fichero_inventario_inst="$DIR_DATA/$inventario_inst";
$fichero_log="${DirLog}/yavireInv_${producto_con_version}.log"; 


$datelog=&formatofecha_log(time);
open(LOGS,">>$fichero_log") || die "problemas abriendo fichero de inventario inst $fichero_log\n";

print LOGS "==============================================================================================\n";
print LOGS "   yavire daily inventory for Weblogic 11 - Version $versionYV\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n\n";

open(INVENTARIO_INST,">$fichero_inventario_inst") || die "problemas abriendo fichero de inventario inst $fichero_inventario_inst\n";

open(INVENTARIO,"<$fichero_inventario") || die "problemas abriendo fichero de inventario $fichero_inventario\n";
#print INVENTARIO_INST "MAQUINA\tPRODUCTO\tVERSION\tINSTANCIA\t\tIP\tPUERTO\tMEMORIA_MIN\tMEMORIA_MAX\tMAXTHREADS\tSSL\tSNMP\tACRONIMO\tDOMINIO\tCLUSTER\tDEPLOY\tPROPIETARIO\n";

#print INVENTARIOS "\n\nFecha de inserccion en el fichero: $datelog\n";
print LOGS "\n\nFecha de insercion en el fichero: $datelog\n";

print LOGS "\n-----------------------------------------------------------------------------------------------\n";
print LOGS "    Comenzamos lectura del fichero de inventario semanal $fichero_inventario \n";
print LOGS "-----------------------------------------------------------------------------------------------\n";


while (<INVENTARIO>) {	
	$linea=$_;
	
        print LOGS "\n-----------------------------------------------------------------------------------------------\n";
	print LOGS "Tratando linea:  ($linea) \n";
	
	next unless ($linea =~ /^\//);
	@linea_troceada = split(/\s+/, $linea);
	$directorio="$linea_troceada[0]";
	
	$dominio="$linea_troceada[1]";
	print LOGS "dominio=$dominio\n";
	$esta_version="$linea_troceada[2]";
	$propietario="$linea_troceada[3]";
	chomp $propietario;
	
	#print "propietario=${propietario}fin\n";
	
	print LOGS "fichero_a_localizar=${fichero_a_localizar}\n";
	print LOGS "directorio=$directorio\n";
        $directorio = "$directorio/$dominio";
	
	print LOGS "directorioReal=$directorio\n";
	
	@result=`find $directorio -name $fichero_a_localizar 2> /dev/null`;#Estudio cada valor
        print LOGS "Hacemos el find $directorio =@result\n";
	#/oradata/orawls/ihs_projects/domains/ihs/config/config.xml
	print LOGS "Version=$esta_version\n";
	
	#print "result de $directorio =@result\n";
	next if ($esta_version !~ /11\./);
        print LOGS "Nos vale la version\n";
	
	
	foreach (@result) {
		$res=$_;
		print LOGS "res1=$res\n";
		next unless ($res =~ /\/config\/$fichero_a_localizar/i);
		#print LOGS "res2=$res\n";
		next unless ($res =~ /$dominio/i);
		#print LOGS "res3=$res\n";
		#print LOGS "res=$res\n";
		#($instancia)= $res =~ /.+\/(.+)\/config\/$fichero_a_localizar/;	
		
		#print "res=$res";
		$puerto="-";
		$ip="-";
		$LogAccess="-";
		$nonSSL=0; #Doy por supuesto que no está definido el NO SSL 
	
		#Recorremos el fichero config.xml para encontrar el puerto
		$LineaPuerto=0;
		#print "fichero_server=$fichero_server\n";
		open(FILESERVER,"<$res") || print ERROR "Existen problemas al abrir el fichero $res\n";
		
		#Buscamos si tiene definición non-SSL en cuyo caso, ignoro la SSL
		@fichServidor=<FILESERVER>;
		@salidaGrep = grep(/Define a non-SSL HTTP/, @fichServidor);    
		$nonSSL=1 if ($#salidaGrep ne -1);
		close FILESERVER;
		
		$nuevaInstancia = 0;
		open(FILERES,"<$res") || print ERROR "Existen problemas al abrir el fichero $res\n";
                print LOGS "Tratando fichero de configuracion: $res\n";
                
		while (<FILERES>) {
			$fich_linea = $_;
			chop($fich_linea);
			
			##NO SE SI FALTA COMPROBAR QUE ESTA ISNTANCIA CORRESPONDE A ESTA MÁQUINA 
			
			#Cada instancia está encapsulada por <server>...</server>	
			$nuevaInstancia = 0 if ($fich_linea =~ /\<server\>/); #Instancia nueva
			$server = 0 if ($fich_linea =~ /\<server\>/); #Instancia nueva
			
			if (($server eq 0) && ($fich_linea =~ /<name>(.+)<\/name>/))
			{
				$server = 1; # La primera vez que aparace <name>(.+)<\/name> dentro de <server> es una nueva instancia
					     # Pero no el resto de <name> dentro de este server.
				($instancia) = $fich_linea =~ /<name>(.+)<\/name>/ if ($fich_linea =~ /<name>(.+)<\/name>/); #fijate que excluya <\/name> en el nombre de la instancia: <name>bea_admin</name>
				#Con cada nueva instancia se inicializa las variables
				$ip = "-";
				$puerto = "-";
				$machine = "-";
				$cluster = "-";
                                print LOGS "Se ha encontrado la instancia $instancia\n";
			}#if
			
			
			#Definicion de LogAccess /opt/oracle/Middleware/user_projects/domains/Publicacion_VFJ/servers/Server_VFJ05/logs/access.log
		        $LogAccess="${directorio}\/${dominio}\/servers\/${instancia}\/logs\/Access.log";
			
			($ip) = $fich_linea =~ /<listen-address>(\d+\.\d+\.\d+\.\d+)<\/listen-address>/ if ($fich_linea =~ /<listen-address>(\d+\.\d+\.\d+\.\d+)<\/listen-address>/); #<listen-address></listen-address>
			($puerto) = $fich_linea =~ /<listen-port>(\d+)<\/listen-port>/ if ($fich_linea =~ /<listen-port>(\d+)<\/listen-port>/); #<listen-port>7010</listen-port>
			($machine) = $fich_linea =~ /<machine>(.+)<\/machine>/ if ($fich_linea =~ /<machine>(.+)<\/machine>/); #<machine>proyvalihswls02.indra.es</machine>
			($cluster) = $fich_linea =~ /<cluster>(.+)<\/cluster>/ if ($fich_linea =~ /<cluster>(.+)<\/cluster>/); #<cluster>Cluster_Publicacion_VFJ2</cluster>
						
			$nuevaInstancia = 1 if ($fich_linea =~ /\<\/server\>/); #Se acaba la instancia y hay que escribir
			
			#Solo escribe si la ip de la instancia pertenece a la máquina donde reside la instancia que está tratando
									
			if ($nuevaInstancia == 1)
			{	
				
				print LOGS "Valores encontrados de la nueva instancia: $instancia\n";
			        print LOGS "     Listen Address: $ip\n";
			        print LOGS "     Listen Port: $puerto\n";
			        print LOGS "     Machine: $machine\n";
			        print LOGS "     Cluster: $cluster\n\n";
			        print LOGS "     Server IP: $IpMaq\n\n";
			     
                                
				if (("$ip" eq "-" ) && ("$cluster" ne "-" ))
				{
					#la ip no venía definida en <listen-address>10.44.7.146</listen-address> y es un cluster
					#entonces sacamos la ip de <cluster-address>10.44.7.146:17102,10.44.7.146:17104,10.44.7.146:17106,10.44.7.146:17108</cluster-address>
					#$puerto
					#print "\n\nENTRAAAAAAAAAAAAAAAAAAAAAA\n\n";
					$encuentraCluster = 0;
					$ipCluster = "-";
					#print "ENTRA EN FILERESCLUSTER antes\n";
					
					open(FILERESCLUSTER,"<$res") || print ERROR "Existen problemas al abrir el fichero para cluster $rescluster\n";
					while (<FILERESCLUSTER>) {
						
						#Recorre de nuevo el mismo fichero config.xml pero para obtener las propiedades del cluster asociado
						#con el fin de sacar la ip de la máquina donde reside la intancia estudiada.
						$fich_linea_cluster = $_;
						#print "ENTRA EN FILERESCLUSTER despues\n";
						chop($fich_linea_cluster);
						$encuentraCluster = 1 if ($fich_linea_cluster =~ /<name>$cluster<\/name>/); #Encuentra <name>Cluster_Publicacion_VFJ2</name>
						($ipCluster) = $fich_linea_cluster =~ /(\d+\.\d+\.\d+\.\d+):${puerto}/ if (($encuentraCluster == 1) && ($fich_linea_cluster =~ /<cluster-address>(.+)<\/cluster-address>/));
						
						#print "COINCIDE\n" if (($encuentraCluster == 1) && ($fich_linea_cluster =~ /<cluster-address>.+<\/cluster-address>/));
						#print "COINCIDE\n" if ($encuentraCluster == 1) ;
						#($ipCluster) = $fich_linea_cluster =~ /<cluster-address>(.+)$puerto/ if ($encuentraCluster eq 1)
						#<cluster-address>10.44.7.146:17102,10.44.7.146:17104,10.44.7.146:17106,10.44.7.146:17108</cluster-address>
						#$ipCluster en teoría es la ip del puerto asociado.
						
						if ($ipCluster ne "-") 
						{
							#Solo captura la ip del Cluster si esta tiene datos
							$ip = $ipCluster;
							#print "ipCluster despues=$ipCluster\n";
							last;
						}
					}#while
					close FILERESCLUSTER;
				}
				
				if ("$ip" eq "-" )
				 {
					#No está definida la  <listen-address></listen-address> pero no es un cluster
					#O bien no está definido la ip en el cluster.
					#print "ENTRA EN ELSE\n";
					$ip = $IpMaq;
				 }
				 
				 if ("$puerto" eq "-" )
				 {
					#No está definido la  <listen-port></listen-port> 
					#Dejamos el puerto por defecto del weblogic
					$puerto = "7001";
				 }
				 
				 
				 
				
				# print LOGS "IpMaq ANTES DE ESCRIBIR = $IpMaq\n";
				# print LOGS "ip ANTES DE ESCRIBIR = $ip\n";
				# print LOGS "Version: $esta_version\n";
				
				# if ("$IpMaq" eq "$ip")
				# {	
					if (${esta_version} =~ /\d+/) #Se filtra porque puede que venga en vacio la versión
					{
                                                print LOGS "Se inserta la instancia ${instancia}\n";
						print INVENTARIO_INST "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";	
					}
					else {
						print LOGS "Se descarta el Weblogic:\n";
						print LOGS "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\%  LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";
					}
					#FER-$nuevaInstancia = 0;
				# }#if (("$IpMaq" == "$ip")
                                $nuevaInstancia = 0;
			}
		
			
					
		}#while     	
		close (FILERES); 
		
		}#foreach
	}#while
	
	
print LOGS "\n==============================================================================================\n";
print LOGS "   yavire daily inventory for Weblogic 11 Version $versionYV\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n";

close LOGS;
close INVENTARIO;
close INVENTARIO_INST;



#######################################################SUBRUTINAS#############################################################################
sub formatofecha_log {
	local($fechaseg) = $_[0];
	local(@meses) = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dec");
	local(@meses) = ("01","02","03","04","05","06","07","08","09","10","11","12");
	local(@dias) = ("Lun","Mar","Mie","Jue","Vie","Sab","Dom");
	local(@fecha) = localtime($fechaseg);
	local($mes) = $meses["$fecha[4]"];
	#local($mes) = $fecha[4]+ 1;
	local($year) = $fecha[5] + 1900;
	local($diasemana) = $dias[--$fecha[6]]; 
	local($dia) = sprintf ("%2.2d", $fecha[3]);
	local($hour) = sprintf ("%2.2d", $fecha[2]);
	local($min) = sprintf ("%2.2d", $fecha[1]);
	local($sec) = sprintf ("%2.2d", $fecha[0]);
	#my $fecha= "$diasemana $mes $dia $hour:$min:$sec $year";
	#local($fecha)= "$mes $dia $hour:$min:$sec";
	local($fecha)= "$dia/$mes/$year $hour:$min:$sec";
	return $fecha;
}


sub IpMaquina {
	#Halla la IP de la máquina
	#Genera las ips de la máquina
	local ($ip);
	local ($SO)=`uname -s`;
	chop $SO;
	if ("$SO" eq "AIX") {
		#SOP es Aix 
		$ip=`/usr/bin/nslookup $maquina \|tail \-2 \|head \-1 \|cut \-d\":\" \-f2 \|cut \-d\" \" \-f3`;
		chomp $ip;
		if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {
			$ip=`ifconfig \-a \| grep \"inet\" \| head \-1 \| awk \'{print \$2}\'`;
			#Cuidado con esta porque pueden haber varias ips u se está cogiendo solo la primera
			#Realmente se ha de coger solo una, pero se ha de saber cual.
			chomp $ip;
		}#		
	} elsif ("$SO" eq "Linux") {
		#Si es Linux 
		$ip=`/usr/bin/nslookup $maquina \| tail \-2 \| head \-1 \| cut \-d\":\" \-f2 \|cut -d\" \" \-f2`;	
		chomp $ip;
		if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {	
		$ip=`/sbin/ifconfig \| grep \-m 1  \"inet addr\" \|  awk \-F\"addr:\" \'{print \$2}\' \|  awk \'{print \$1}\'`;		 
			chomp $ip;
		}#if	 
	} else  {
		#("$SO" eq "Solaris (SunOS)")
		$ip=`/usr/sbin/nslookup $maquina \|tail \-2 \|head \-1 \|cut \-d\":\" \-f2 \|cut -d\" \" \-f3`;
		if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {
			$ip=`ifconfig -a \| grep \"inet\" \| head \-1 \| awk \'{print \$2}\'`;
			chomp $ip;
		}#if	
	}#if (SO)
	
	return $ip;
}
