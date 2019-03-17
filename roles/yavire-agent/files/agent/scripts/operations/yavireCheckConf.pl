#!/usr/bin/perl

#Descripcion del script
#Lee el fichero de variables obtenido a partir del dir_ori_pase del pase dado por parametro 
#y recorre todos los ficheros existentes en directorio dir_ori_pase y de forma recursiva en todos los subdirectorios contenidos
# y los modifica según el fichero variables
 
#Parametro 1. dir origen del pase 
	#ejem1: /soflib00/instalaciones/delta/produccion/Batch
 #El fichero .variables debe estar en /soflib00/instalaciones/delta/produccion/delta_integracion.variables
 
#Definición de variables 
$dir_ori_pase = $ARGV[0];
$dir_ori_pase =~ s/\/\*$//; #Elimina /* al final del directorio si lo hubiera

$temporal=temporal; #Define el nombre del directorio temporal donde deja los ficheros traducidos de las variables de configuración. 

$dir_ori_pase_entregables = $dir_ori_pase;
$dir_ori_pase_entregables =~ s/instalaciones/entregables/; #Donde ponga instalaciones lo cambia por entregables

$fich_logs="/opt/krb/yavire/agent/log/test_configuracion_variables.log";

#Se abre el fichero para guardar los logs
open(LOGS,">>$fich_logs") || die "problemas abriendo fichero de log $fich_logs\n";

#Se construye el path del fichero .variables
#Debe ser estar en una ubicación equivalente a esta: /soflib00/instalaciones/zeus/integracion
#Y el nombre zeus_integracion.variables
@dir_ori_pase_troceado = split (/\//,$dir_ori_pase);
$path_fich_variables="\/@dir_ori_pase_troceado[1]\/@dir_ori_pase_troceado[2]\/@dir_ori_pase_troceado[3]\/@dir_ori_pase_troceado[4]";
$fich_variables="$path_fich_variables\/@dir_ori_pase_troceado[3]_@dir_ori_pase_troceado[4].variables";


unless (-e $fich_variables ) {
	print "ERROR: El fichero $fich_variables de variables no existe\n";
	exit 1; 
}#unless
#################################################CUERPO SCRIPT#############################################################
#Configura la fecha y hora para el log y salida de pantalla
$datelog=&formatofecha_log(time);

print LOGS "SE REALIZA EL TEST DE LA CONFIGURACION DE LOS FICHEROS DEL DIRECTORIO $fich_conf_instalables SEGUN EL FICHERO DE\n";
print LOGS "VARIABLES $fich_variables, FECHA: $datelog\n\n";

#Recorre todo el directorio dir_config_entregables, y sus subdirectorios para leer cada uno de sus ficheros




#Se construye el path del directorio temporal donde se albergarán los ficheros de prueba de la configuracion de variables
@dir_ori_temp_troceado = split (/\//,$dir_ori_pase);
$path_dest_temp="\/@dir_ori_pase_troceado[1]\/@dir_ori_pase_troceado[2]\/@dir_ori_pase_troceado[3]\/${temporal}";
$path_dest_temp=~ s/entregables/instalaciones/; #Donde pone entregables lo cambia por instalaciones
`mkdir $path_dest_temp` unless (-e $path_dest_temp);


#Obtener $cont_dir_instalables, contiene todos los ficheros a estudiar
&ficheros_entregables($dir_ori_pase_entregables);
#print "ficheros TOTALES =@cont_dir_entregables\n";


for($i = 0; $i <= $#cont_dir_entregables; $i++) { 
	next unless ($cont_dir_entregables[$i] =~ /\.xml|\.properties|\.conf|\.ini|\.props|\.sh/i);
	$sal_grep=`grep \%\% $cont_dir_entregables[$i]`;
	next unless ($sal_grep ne "");
	#lee cada fichero
	$fich_conf_entregables="$cont_dir_entregables[$i]"; #De aqui se lee
	@fich_temp = split (/\//,$fich_conf_entregables);
	$fichero = $fich_temp[$#fich_temp];
	$fich_conf_instalables_temp="$path_dest_temp\/$fichero"; #Aquí se escribe
	
	open(FICH_CONF_ENTREGABLES,"<$fich_conf_entregables") || die "problemas abriendo fichero fich_conf_instalables $fich_conf_entregables\n";
	open(FICH_CONF_INSTALABLES_TEMP,">$fich_conf_instalables_temp") || die "problemas abriendo fichero fich_conf_instalables_temp\n";
	#print "analiza el fich $cont_dir_instalables[$i]\n";
	#print "Trata $fich_conf_instalables\n";
	
	while ($linea_ini=<FICH_CONF_ENTREGABLES>) {
		#chop($linea_ini);
		$linea=$linea_ini;
		#print LOGS "\n\nEl valor de linea_ini es $linea_ini\n";
		
		unless ($linea_ini =~ /^#/) {
				#dato de entrada = ldap://%GESTORESTRORG_LDAP-SERVER_URL%:1389
				#print "linea_ini=$linea_ini\n";
				@valor_troceado=split (/\%\%/,$linea_ini); #%%HERRAMMANUAL_URLDES%%
				$linea="";
				
				
				for ($j = 0; $j <= $#valor_troceado; $j++) {
					if ($j % 2 == 0) {
						#Si $j es par es valor fijo						
						$linea="${linea}$valor_troceado[$j]";	
					} else {
						#j Es impar, es decir es un valor variable y hay que buscarlo en $fich_variables
						$linea_fich = `grep "$valor_troceado[$j]=" $fich_variables 2>&1`; #$linea_fich=GESTORESTRORG_LDAP-SERVER_URL=PRUEBA23					
						
						
						
						if ($linea_fich =~ /No such file or directory/i) {
							#Si la variable no la encuentra la deja tal cual.
							$linea="${linea}\%\%$valor_troceado[$j]\%\%";
							print LOGS "\nNO SE ENCUENTRA la variable $valor_troceado[$j] EN $fich_variables \n";
							#print LOGS " j=$j El valor de linea_fich es $linea_fich\n";
						} else {
							#($dato_fich_var,$valor_fich_var)=split (/\=/,$linea_fich);
							($dato_fich_var,$valor_fich_var) = $linea_fich =~ /([^=]*)\=(.*)/;							
							#chop($valor_fich_var);
							$linea="${linea}$valor_fich_var" if ("$valor_fich_var" ne "");
							print LOGS "Se sustituye la variable $valor_troceado[$j] por $valor_fich_var en $fich_conf_entregables\n" if ("$valor_fich_var" ne "");
							
							$linea="${linea}\%\%$valor_troceado[$j]\%\%" if ("$valor_fich_var" eq "");
							print LOGS "NO EXISTE VALOR PARA LA VARIABLE $valor_troceado[$j] de $fich_conf_instalables\n" if ("$valor_fich_var" eq "");
							
							#$linea="${linea}$valor_fich_var";	
						}	
					}#if else			
				}#for			
		}#unless
		#Escribe en $dir_ori_pase el fichero rellenado con datos correctos
		print FICH_CONF_INSTALABLES_TEMP "$linea\n";											
	}#while
	close FICH_CONF_ENTREGABLES;	
	close FICH_CONF_INSTALABLES_TEMP;
	$salida=`dos2unix $fich_conf_instalables_temp 2>&1`;
	#$salida=`cp $fich_conf_instalables_temp $fich_conf_instalables 2>&1`;
	#$salida=`rm $fich_conf_instalables_temp 2>&1`;
}#for cont_dir_entregables

#Comprueba después de la transformacion las variables que siguen existiendo en los ficheros transformados en gvlspexp en instalaciones.

@salida=`cd $dir_ori_pase && grep %% * | grep -v :# 2>&1`;

if ("@salida" ne "") {
	print LOGS "ERROR: Falta por definir este conjunto de variables:\n";
	print LOGS "@salida\n";
	
	print "ERROR: Falta por definir este conjunto de variables:\n";	
	print "@salida\n";
}

print LOGS "--------------------FIN Configuracion variables-------------------------------\n\n";

close LOGS;
closedir(DIR_ENTREGABLES);



#####################################################
#										RUTINAS
#####################################################
#

sub ficheros_entregables {
        local($dirname) = $_[0];     #parametro pasado="$dir_ori_pase";       
        opendir(DIR,$dirname) || die("No puede abrir el directorio $dirname");
        local(@cont) = readdir(DIR); 
        local($file);
        local($i); 
        for ($i=0; $i<=$#cont; $i++) {      	
            next if ($cont[$i] eq '.' || $cont[$i] eq '..');
            $file = "$dirname\/$cont[$i]";
            if (-d $file){            	
	        &ficheros_entregables($file);				
            }else{
             	push(@cont_dir_entregables,$file);           	
            }#if
         }#for                 
         closedir(DIR); 	    
}#ficheros_entregables


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