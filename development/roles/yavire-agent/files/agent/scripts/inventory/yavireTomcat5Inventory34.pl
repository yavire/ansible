#!/usr/bin/perl

#Script de tomcat
$versionYV = '2.2.0.1';

#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";


$DirLog="/opt/krb/yavire/agent/log/inventory";
$fichero_inventorio="$INVENTARIO/weekly/yavireTomcat5_to_Tomcat7_FileInventory.txt"; 
`mkdir -p $DirLog` unless (-d $DirLog);
##Eso es una linea del contenido:
	#Directory%%Domain%%Version%%Propietario
	#=========%%=======%%=======%%=========
	#/home/gmaps/apache-tomcat6-Front%%gmaps%%6.0%%gmaps
	#/home/gmaps/apache-tomcat6-GS%%gmaps%%6.0%%gmaps

$maquinaTemp=`uname -n`;
chomp $maquinaTemp;
@maquina_troceada = split(/\./, $maquinaTemp);
$maquina=$maquina_troceada[0];

$producto="tomcat";
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
$producto_con_version="tomcat5";
$ruta_a_localizar='/conf/server.xml';
$fichero_a_localizar='server.xml';
$dominio="-";
$instancia="-";
$TipoInstancia="SOFTWARE";
$subTipoInstancia="APPSERVER";

#Calcula la IP de la máquina
#print "Va a calcular la IP de la maquina\n";
$IpMaq=&IpMaquina();
#print "Ha calculado la ip de la maquina\n";

#$lineaSsl='Include conf/extra/httpd-ssl.conf';
#$lineaSsl='Include conf/extra/httpd*-ssl.conf';


#print "fichero_log=$fichero_log\n";

#Define, si es necesario, los directorios según la version
$DIR_DATA="${INVENTARIO}/data/tomcat5/${maquina}";	
`mkdir -p "${DIR_DATA}"` unless (-d "${DIR_DATA}"); 
$inventorio_inst="yavireInv_tomcat5.data";
$fichero_inventorio_inst="$DIR_DATA/$inventorio_inst"; 
$fichero_log="${DirLog}/yavireInv_tomcat5.log";


$datelog=&formatofecha_log(time);
open(LOGS,">>$fichero_log") || die "problemas abriendo fichero de inventario inst $fichero_log\n";

open(INVENTARIO_INST,">$fichero_inventorio_inst") || die "problemas abriendo fichero de inventario inst $fichero_inventorio_inst\n";

open(INVENTARIO,"<$fichero_inventorio") || die "problemas abriendo fichero de inventario $fichero_inventorio\n";
#print INVENTARIO_INST "MAQUINA\tPRODUCTO\tVERSION\tINSTANCIA\t\tIP\tPUERTO\tMEMORIA_MIN\tMEMORIA_MAX\tMAXTHREADS\tSSL\tSNMP\tACRONIMO\tDOMINIO\tCLUSTER\tDEPLOY\tPROPIETARIO\n";

#print INVENTARIOS "\n\nFecha de inserccion en el fichero: $datelog\n";
print LOGS "\n\nFecha de insercion en el fichero: $datelog\n";
print LOGS "Leyendo fichero: $fichero_inventorio\n";

while (<INVENTARIO>) {	
	$linea=$_;
	next unless ($linea =~ /^\//);
        print LOGS "Leyendo linea: ($linea)\n";
	@linea_troceada = split(/%%/, $linea);
	$directorio="$linea_troceada[0]";
	#No utilizamos el dominio del inventario semanal, lo dejamos como UNDEFINED, el núcleo de oyavirele pondrá el dominio dependiendo de la máquina.
	#$dominio="$linea_troceada[1]";
	$nombreinstancia2="$linea_troceada[1]";
	$nombreinstancia2=lc($nombreinstancia2);
	
	$esta_version="$linea_troceada[2]";
	$propietario="$linea_troceada[3]";
	chomp $propietario;
	
	print LOGS "propietario=(${propietario})\n";
	print LOGS "fichero_a_localizar=(${fichero_a_localizar})\n";
	print LOGS "directorio=($directorio)\n";
	
	@result=`find $directorio -name $fichero_a_localizar 2> /dev/null`;#Estudio cada valor
	#/home/franquicias/apache/conf/httpd.conf server.xml
	print LOGS "esta_version=($esta_version)\n";
	next if ($esta_version !~ /5\./);
	
	foreach (@result) {
		$res=$_;
		next unless ($res =~ /\/conf\/$fichero_a_localizar/i);
		($instancia)= $res =~ /.+\/(.+)\/conf\/$fichero_a_localizar/;	
		#print "\n\nEMPIEZA\n";
		#print "res=$res";
		$puerto="-";
		$ip="-";
		$LogAccess="-";
		$nonSSL=0; #Doy por supuesto que no está definido el NO SSL 
		
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
		@salidaGrep = grep(/Define a non-SSL HTTP/, @fichServidor);    
		#@salidaGrep = grep(/hhhhhhhhhhhhhhhhhhhh/, @fichServidor);    
		#print "salida=$#salidaGrep fin\n";
		$nonSSL=1 if ($#salidaGrep ne -1);
		close FILESERVER;
		
		open(FILERES,"<$res") || print ERROR "Existen problemas al abrir el fichero $res\n";
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
				($ip) = $fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/ if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				($maxThreads) = $fich_linea =~ /maxThreads=\"(\d+)\"/i if ($fich_linea =~ /maxThreads=\"(\d+)\"/i);
				
				#last if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				last if ($fich_linea =~ /\/>/);
				### FIN CASO NO SSL ###
			
		}
		else {
			print "nonSSL NO eq 1\n";
				########  SE ESTUDIA EL CASO SSL <!-- Define a SSL HTTP/1.1 Connector on port 8443 -->  ########		
				next unless (($fich_linea =~ /Define a SSL HTTP.+ Connector on port/ ) || ($LineaPuerto == 1));
				$LineaPuerto=1;	
				#next if $fich_linea =~ /Define a SSL HTTP.+ Connector on port/;
				
				#Estamos en <Connector     port="8080"
				($puerto) = $fich_linea =~ /<Connector port=\"(\d+)\"/ if ($fich_linea =~ /<Connector port=\"(\d+)\"/);
				($ip) = $fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/ if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				($maxThreads) = $fich_linea =~ /maxThreads=\"(\d+)\"/i if ($fich_linea =~ /maxThreads=\"(\d+)\"/i);
				
				#last if ($fich_linea =~ /address=\"(\d+\.\d+\.\d+\.\d+)\"/);
				last if ($fich_linea =~ /\/>/);
				### FIN CASO NO SSL ###
			}
			
					
			}#while     	
			close (FILERES); 
			#print "ip=$ip\n";
			#print "puerto=$puerto\n";
			#print "maxThreads=$maxThreads\n";
			$ip = $IpMaq if ("$ip" == "-" );
			#print "ip2=$ip\n";
			if (${esta_version} =~ /\d+/)
			{
				$instancia = join  "", $instancia,'-',$nombreinstancia2; 
				print INVENTARIO_INST "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";	
			}
			else {
				print LOGS "Se descarta el apache:\n";
				print LOGS "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\%  LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";
			}
		}#foreach
	}#while

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
