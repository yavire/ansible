#!/usr/bin/perl

#Version 2.1.0.0_5


#Descripcion del script
#Lee el fichero de variables obtenido a partir del dir_ori_pase del pase dado por parametro 
#y recorre todos los ficheros existentes en directorio dir_ori_pase y de forma recursiva en todos los subdirectorios contenidos
# y los modifica según el fichero variables
 
#Captura de parametros
$dir_ori_pase = $ARGV[0];       #Directorio donde reside(n) el/los fichero(s)a transformar.    
		                #Cada fichero a transformar, lo modifica y lo deja en el mismo sitio.
$fichVar = $ARGV[1];            #Fichero de variable con el path incluido.
$FichDirAtransformar = $ARGV[2];#Define el fichero o cto. de ficheros a transformar la varible por un valor definido en el fichero de variables
                                #Puede ser un fichero, o bien ALL, en ese caso se estudia todos los ficheros, y si procede se transforman.


#Definición de variables 
$fich_logs="/opt/krb/yavire/agent/log/configuracion_variables.log";

#Comprueba las variables de entrada
unless ((-d $dir_ori_pase) && ((-e $FichDirAtransformar)||($FichDirAtransformar eq "ALL") || ($FichDirAtransformar eq "all")) && (-e $fichVar)) {
	print "ERROR: Los parametros a pasar deben ser:\n DirectorioOrigen:$dir_ori_pase Atransformar:$FichDirAtransformar FicheroVariables:$fichVar\n";
	exit 1; 
}#unless

#Se abre el fichero para guardar los logs
open(LOGS,">>$fich_logs") || die "problemas abriendo fichero de log $fich_logs\n";


#################################################CUERPO SCRIPT#############################################################
#Configura la fecha y hora para el log y salida de pantalla
$datelog=&formatofecha_log(time);

print LOGS "SE REALIZA LA CONFIGURACION DE LOS FICHEROS DEL DIRECTORIO $fich_conf_instalables SEGUN EL FICHERO DE\n";
print LOGS "VARIABLES $fichVar, FECHA: $datelog\n\n";
print LOGS "Los ficheros transformados se dejan en $dir_dest\n";

#Obtiene los ficheros a transformar
if (("$FichDirAtransformar" eq "ALL") || ("$FichDirAtransformar" eq "all")) {
	#Entonces se estudian todos los ficheros contenidos en $dir_ori
	&TodosFicheros($dir_ori_pase);
	#print "ficheros TOTALES=@cont_dir\n";
} else {
	push(@cont_dir,$FichDirAtransformar); 
}

#Estudia cada fichero a transformar
for($i = 0; $i <= $#cont_dir; $i++) { 
	#print "Fichero a transformar: $cont_dir[$i] \n";
	next unless ($cont_dir[$i] =~ /\.xml|\.properties|\.conf|\.ini|\.props|\.sh|${FichDirAtransformar}/i);
	$sal_grep=`grep \%\% $cont_dir[$i]`;
	next unless ($sal_grep ne "");
	#lee cada fichero
	$fich_conf="$cont_dir[$i]"; #De aqui se lee
	$fich_conf_temp="$cont_dir[$i]_temp"; #Aquí se escribe
	
	
	open(FICH_CONF,"<$fich_conf") || die "problemas abriendo fichero fich_conf_instalables $fich_conf\n";
	open(FICH_CONF_TEMP,">$fich_conf_temp") || die "problemas abriendo fichero fich_conf_temp $fich_conf_emp\n"; #Aquí se escribe
	
	while ($linea_ini=<FICH_CONF>) {
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
						#j Es impar, es decir es un valor variable y hay que buscarlo en $fichVar
						$linea_fich = `grep "$valor_troceado[$j]=" $fichVar 2>&1`; #$linea_fich=GESTORESTRORG_LDAP-SERVER_URL=PRUEBA23					
						
						
						
						if ($linea_fich =~ /No such file or directory/i) {
							#Si la variable no la encuentra la deja tal cual.
							$linea="${linea}\%\%$valor_troceado[$j]\%\%";
							print LOGS "\nNO SE ENCUENTRA la variable $valor_troceado[$j] EN $fichVar \n";
							#print LOGS " j=$j El valor de linea_fich es $linea_fich\n";
						} else {
							#($dato_fich_var,$valor_fich_var)=split (/\=/,$linea_fich);
							($dato_fich_var,$valor_fich_var) = $linea_fich =~ /([^=]*)\=(.*)/;							
							#chop($valor_fich_var);
							$linea="${linea}$valor_fich_var" if ("$valor_fich_var" ne "");
							print LOGS "Se sustituye la variable $valor_troceado[$j] por $valor_fich_var en $fich_conf_instalables\n" if ("$valor_fich_var" ne "");
							
							$linea="${linea}\%\%$valor_troceado[$j]\%\%" if ("$valor_fich_var" eq "");
							print LOGS "NO EXISTE VALOR PARA LA VARIABLE $valor_troceado[$j] de $fich_conf_instalables\n" if ("$valor_fich_var" eq "");
							
							#$linea="${linea}$valor_fich_var";	
						}	
					}#if else			
				}#for			
		}#unless
		#Escribe en $dir_ori_pase el fichero rellenado con datos correctos
		print FICH_CONF_TEMP "$linea\n";											
	}#while
	close FICH_CONF;	
	close FICH_CONF_TEMP;
	$salida=`dos2unix $fich_conf_temp 2>&1`;
	$salida=`cp $fich_conf_temp $fich_conf 2>&1`;
	$salida=`rm $fich_conf_temp 2>&1`;
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

sub TodosFicheros {
        local($dirname) = $_[0];     #parametro pasado="$dir_ori_pase";       
        opendir(DIR,$dirname) || die("No puede abrir el directorio $dirname");
        local(@cont) = readdir(DIR); 
        local($file);
        local($i); 
        for ($i=0; $i<=$#cont; $i++) {      	
            next if ($cont[$i] eq '.' || $cont[$i] eq '..');
            $file = "$dirname\/$cont[$i]";
            if (-d $file){            	
	        &TodosFicheros($file);				
            }else{
             	push(@cont_dir,$file);           	
            }#if
         }#for                 
         closedir(DIR); 	    
}#TodosFicheros



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