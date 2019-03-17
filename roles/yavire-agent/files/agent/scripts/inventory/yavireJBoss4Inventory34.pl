#!/usr/bin/perl

use POSIX qw(strftime);

#Script de Jboss
$versionYV = '2.2.0.1';


#Directorio datos
$INVENTARIO="/opt/krb/yavire/agent/inventory";
$nombreFicheroInventario="yavireInv_jboss4.data";

$log="/opt/krb/yavire/agent/log/inventory";
$fichero_log="${log}/yavireInv_jboss4.log";

$ficheroInventarioSemanal="$INVENTARIO/weekly/yavireJBoss3_0to6.1_FileInventory.txt";

$maquinaTemp=`uname -n`;
chomp $maquinaTemp;
@maquina_troceada = split(/\./, $maquinaTemp);
$maquina=$maquina_troceada[0];

$producto="jboss";
$version="4.";
$ip="-";
$puerto="-";
$memoria_min="-";
$memoria_max="-";
$max_threads="-";
$ssl="NO";
$snmp="-";
$acronimo="UNDEFINED";
$cluster="-";
$deploy="Si";
$producto_con_version="jboss4";
$LogAccess="-";
$dominio="-";


$TipoInstancia="SOFTWARE";
$subTipoInstancia="APPSERVER";

open(LOGS,">$fichero_log") || die "problemas abriendo fichero de inventario inst $fichero_log\n";

print LOGS "==============================================================================================\n";
print LOGS "   yavire daily inventory for JBoss - Version $versionYV\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n\n";


$DIR_DATA="${INVENTARIO}/data/jboss4/${maquina}";
$ficheroInventarioDiario="$DIR_DATA/$nombreFicheroInventario"; #/opt/krb/yavire/inventario/data/jboss4/vodload01/inventario_jboss4.log
`mkdir -p $DIR_DATA` unless (-d $DIR_DATA); 

open(INVENTARIO_INST,">$ficheroInventarioDiario") || die "problemas abriendo fichero de inventario inst $ficheroInventario\n";
open(INVENTARIO,"<$ficheroInventarioSemanal") || die "problemas abriendo fichero de inventario semanal $ficheroInventarioSemanal\n";
#print INVENTARIO_INST "MAQUINA\tPRODUCTO\tVERSION\tINSTANCIA\tIP\tPUERTO\tMEMORIA_MIN\tMEMORIA_MAX\tMAX_THREADS\tSSL\tSNMP\tACRONIMO\tDOMINIO\tCLUSTER\tDEPLOY\n";

#Halla la IP de la máquina
#Genera las ips de la máquina

$SO=`uname -s`;
chop $SO;
	
if ("$SO" eq "AIX") {
   #SOP es Aix 
   $ip=`/usr/bin/nslookup $maquina |tail -2 |head -1 |cut -d\":\" -f2 |cut -d\" \" -f3`;
   chomp $ip;
   if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {
      $ip=`ifconfig -a | grep \"inet\" | head -1 | awk \'{print \$2}\'`;
      chomp $ip;
   }#		
} elsif ("$SO" eq "Linux") {
   #Si es Linux 
   $ip=`/usr/bin/nslookup $maquina | tail -2 | head -1 | cut \-d\":\" \-f2 |cut -d\" \" \-f2`;	
   chomp $ip;
   if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {	
      $ip=`/sbin/ifconfig | grep -m 1  \"inet addr\" |  awk \-F\"addr:\" \'{print \$2}\' |  awk \'{print \$1}\'`;		 
      chomp $ip;
   }
} else  {
   #("$SO" eq "Solaris (SunOS)")
   $ip=`/usr/sbin/nslookup $maquina |tail -2 |head -1 |cut -d\":\" -f2 |cut -d\" \" -f3`;
   if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {
      $ip=`ifconfig -a | grep \"inet\" | head -1 | awk \'{print \$2}\'`;
      chomp $ip;
   }#if	
}#if (SO)
	  
print LOGS "\n-----------------------------------------------------------------------------------------------\n";
print LOGS "    Comenzamos lectura del fichero de inventario semanal $ficheroInventarioSemanal \n";
print LOGS "-----------------------------------------------------------------------------------------------\n";


while (<INVENTARIO>) {
	$linea=$_;
	print LOGS "\n-----------------------------------------------------------------------------------------------\n";
	print LOGS "Tratando linea:  ($linea) \n";
	
	next if ($linea !~ /^\d/); #Solo se evaluan las lineas que empiecen por un dígito
	
	@linea_troceada = split(/\s+/, $linea);
	
	$path_raiz_instancias="$linea_troceada[1]/server";
	
	$directorio="$linea_troceada[1]";
	#Troceamos el subdirectorio para buscar nombre de instancia
	
	@dirTroceado = split(/\//, $directorio);
	
	$nombreinstancia1=$dirTroceado[$#dirTroceado];
	$nombreinstancia1=lc($nombreinstancia1);
	

	#$nombreinstancia2="$linea_troceada[2]"; #Dominio
	
	$nombreinstancia2=$dirTroceado[$#dirTroceado - 1];
	$nombreinstancia2=lc($nombreinstancia2);
	
	# print LOGS "Nombre instancia2: $nombreinstancia2\n";
	# print LOGS "Nombre instancia1: $nombreinstancia1\n";
	
	$esta_version="$linea_troceada[3]";
	$propietario="$linea_troceada[4]";
	
	print LOGS "Raiz de las instancias: ($path_raiz_instancias)\n";
	print LOGS "Version de las instancias: ($esta_version)\n";
	

	next unless ($esta_version  =~ /$version/);
	
	@instancias=`ls $path_raiz_instancias`;#all  default  minimal
	#print @instancias;
	
	foreach (@instancias) {
		
		$instancia=$_;
		chop $instancia;
		
		$subDirectorio = "$path_raiz_instancias\/$instancia";
		print LOGS "Tratando fichero de configuracion del directorio $path_raiz_instancias\/$instancia\n";
		
		if ( -d $subDirectorio ) {
			#Halla el puerto
			$ficheroConfiguracion="";
			$puerto="-";
			
			SWITCH:
			{
				($esta_version =~ /4\.0/) && do {
					#Vodafone 09-2012
					$ficheroConfiguracion = `find ${path_raiz_instancias}\/${instancia} -name "server.xml" | grep -i \"\/jbossweb-tomcat55.sar\/server.xml\"`;
					if ($ficheroConfiguracion eq "") {
					   print LOGS "No se ha encontrado fichero de configuracion\n";
					}
					else {
					   print LOGS "Taatamos fichero de configuracion: $ficheroConfiguracion\n\n";					
					   #Recorremos el fichero para encontrar el puerto
  					   $LineaPuerto=0;
					   open(FILESERVER,"<$ficheroConfiguracion") || print LOGS "Existen problemas al abrir el fichero $ficheroConfiguracion\n";
					   while (<FILESERVER>) {
					      $fich_linea = $_;
					      chop($fich_linea);
					      #print "antes de next\n";		
					      next unless (($fich_linea =~ /A HTTP.+ Connector on port / ) || ($LineaPuerto == 1));
					      $LineaPuerto=1;	
					      next if $fich_linea =~ /A HTTP.+ Connector on port /;
					      #Estamos en <Connector port="11080" address="${jboss.bind.address}"
					      ($puerto) = $fich_linea =~ /<Connector port=\"(\d+)\" address/;
					      last;
					   }#while     	
					   close (FILESERVER); 
	       			        }
					
                                        last SWITCH;
 			     };	
																		
				($esta_version =~ /4\.2/) && do {
					#Brisa 09-2012
					$ficheroConfiguracion = `find ${path_raiz_instancias}\/${instancia} -name "server.xml"`;
					if ($ficheroConfiguracion eq "") {
					   print LOGS "No se ha encontrado fichero de configuracion\n\n";
					}
					else {
					   print LOGS "Tratamos fichero de configuracion: $ficheroConfiguracion\n";					
					
					   $LineaPuerto=0;
					   open(FILESERVER,"<$ficheroConfiguracion") || print LOGS "Existen problemas al abrir el fichero $ficheroConfiguracion\n";
					
					   while (<FILESERVER>) {
						$fich_linea = $_;
						chop($fich_linea);		
						next unless (($fich_linea =~ /<Connector port=\"/ ) || ($LineaPuerto == 1));
						$LineaPuerto=1;	
						($puerto) = $fich_linea =~ /<Connector port=\"(\d+)\" address/ if ($fich_linea =~ /<Connector port=\"/) ;
						last if ($fich_linea =~ /protocol=\"HTTP/); #Estamos en emptySessionPath="true" protocol="HTTP/1.1"
						next;					
					   }#while     	
					   close (FILESERVER); 
					}
					last SWITCH;
					   
				};	
																																															
				(1 eq 1) && do {
					$ficheroConfiguracion = `find ${path_raiz_instancias}\/${instancia} -name "server.xml"`;
					if ($ficheroConfiguracion eq "") {
					   print LOGS "No se ha encontrado fichero de configuracion\n\n";
					}
					else {
					   print LOGS "Taatamos fichero de configuracion: $ficheroConfiguracion\n";					
					   #Recorremos el fichero para encontrar el puerto
					   $LineaPuerto=0;
					   open(FILESERVER,"<$ficheroConfiguracion") || print LOGS "Existen problemas al abrir el fichero $ficheroConfiguracion\n";
					   while (<FILESERVER>) {
						$fich_linea = $_;
						chop($fich_linea);		
						next unless (($fich_linea =~ /<Connector port=\"/ ) || ($LineaPuerto == 1));
						$LineaPuerto=1;	
						($puerto) = $fich_linea =~ /<Connector port=\"(\d+)\" address/ if ($fich_linea =~ /<Connector port=\"/) ;
						last if ($fich_linea =~ /protocol=\"HTTP/); #Estamos en emptySessionPath="true" protocol="HTTP/1.1"
						next;					
					   }#while     	
					   close (FILESERVER); 
					}
					last SWITCH;
				};
			};#SWITCH	
			
			$instancia = join  "", $instancia,'-',$nombreinstancia1,'-',$nombreinstancia2; 
			
			if ($ficheroConfiguracion ne "") {
			   print INVENTARIO_INST "versionYAV= ${versionYV} \%\% TipoInstancia= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% maquina= ${maquina} \%\% producto= ${producto} \%\% version= ${esta_version} \%\% instancia= ${instancia} \%\% ip= ${ip} \%\% puerto= ${puerto} \%\% memoriaMin= ${memoria_min} \%\% memoriaMax= ${memoria_max} \%\% maxThreads= ${max_threads} \%\% ssl= ${ssl} \%\% snmp= ${snmp} \%\% acronimo= ${acronimo} \%\% dominio= ${dominio} \%\% cluster= ${cluster} \%\% deploy= ${deploy} \%\% propietario= ${propietario} \%\% LogAccess=$LogAccess \%\% directorioBase= $directorio \%\%\n";
			}
                }
	        else {
	           print LOGS "$subDirectorio no es un subdirectorio\n";
	        }		
		
	};#for
}#while

print LOGS "\n==============================================================================================\n";
print LOGS "   yavire daily inventory for JBoss Version $versionYV\n";
print LOGS strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print LOGS "\n==============================================================================================\n";

close INVENTARIO;
close INVENTARIO_INST;
close LOGS;


