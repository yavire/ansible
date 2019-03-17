#!/usr/bin/perl

#Descripcion del script
#Dado un directorio obtiene los n=5 subdirectorios contenidos mayores, y dentro de cada uno los m=3 ficheros mayores con su usuario.
#TAMBIÉN MUESTRA LOS TRES FICHEROS MAYORES DEL DIRECTORIO DADO SI LA SUMA DE SU TAMAÑO ES ENTRA DENTRO DE LOS 5 SUBDIRECTORIOS MAYORES.

#Parametros
#Par1	El directorio a analizar
$dir_a_analizar = $ARGV[0];

#Errores
#exit 1	Permission denied en algún subdirectorio

#Inicialización de variables
$n=5;
$m=3;
$fich_logs="/opt/krb/yavire/agent/log/ficheros_mas_grandes.log";

#Se abre el fichero para guardar los logs
open(LOGS,">>$fich_logs") || die "problemas abriendo fichero de log $fich_logs\n";


#Obtiene los n directorios mayores
#	du -sk *
#	Mediante bucle lee aquellos directorios mayores, y coge solo los n mayores.
#	Dentro de cada uno de estos n directorios calcula los m ficheros mayores y tb obtiene su usuario.

@salida=`cd $dir_a_analizar && du -sk * 2>&1 | sort -n -r 2>&1`;


#Dibuja la primera columna
$linea="Tamanyo\t\tUsuario\tFichero\n";
push(@ficheros,$linea); 

#Recorre todo lo contenido para estudiar solo los subdirectorios
#Estudia los n primeros directorios, mayores pues han sido previamente ordenados
$j = 0;
for($i = 0; $i <= $#salida; $i++) { 
   if ($salida[$i]!~ /Permission denied/i) { 
	@salida_fraccionada=split(/\s+/,$salida[$i]);
	#$salida_fraccionada[0] Ocupación
	#$salida_fraccionada[1] fichero
	$file="$dir_a_analizar\/$salida_fraccionada[1]";
	if (-d $file) {
		#Es un directorio
		$j++;
		last if ($j > $n);
		#Estudia los m ficheros mayores contenidos en este directorio con su usuario
		#Dev fichero+path completo tamaño usuario
		#print "$j Estudia este directorio $file \n";
		&fich_mayores($file);			
	};#if d	
    }#if Permission denied
    else {
     	print  LOGS "ERROR: $salida[$i]\n"; 
	#print "ERROR: $salida[$i] \n"; 
    }#else	
}#for

#Muestra los ficheros
print "Ficheros de mayor tamanyo dentro de $dir_a_analizar:\n\n";
for ($k = 0; $k <= $#ficheros; $k++) { 
	print "$ficheros[$k]\n";
}#for

close LOGS;
#####################################################
#										RUTINAS
#####################################################
#

sub fich_mayores {
  #Se pasa el directorio donde se deben obtener los m ficheros mayores
  local ($dir)=$_[0];
  local $k;
  local $l;
  local ($p)=0;
  #Se acumulan todos los ficheros con su tamaño y se cogen los m mayores.
  local(@resultado_fich)=`cd $dir && ls -las -R --sort=size | grep -v :\$ | grep -v "total " | grep -v " \.\$" | grep -v " \.\.\$" | sort -g -b -r`;
  #4 -rw-r--r--  1 admweb admweb   508 Dec  9 10:33 cobrofinanciacionfacturacion.pre.properties_revisado 
  for($l = 0; $l <= $#resultado_fich; $l++) {    	
	@resultado_fraccionado=split(/\s+/,$resultado_fich[$l]);		
	if (($resultado_fraccionado[1] =!  m/^d/) && ($resultado_fraccionado[1] =!  m/^l/) && ($resultado_fich[$l] =~ m/[^\s]/)){
		$p++;	
		#print "resultadoooo $l = $resultado_fich[$l]\n";
		#No es un directorio, doy por supuesto que es un fichero
		last if ($p > $m);
		$usu=$resultado_fraccionado[3];
		$tamanyo=$resultado_fraccionado[5];
		$nom_fich=$resultado_fraccionado[9];
		#$linea="Tamanyo:${tamanyo}\t\tUsuario:${usu}\t Fichero:${dir}\/..${nom_fich}";
		$linea="${tamanyo}\t\t${usu}\n${dir}\/..${nom_fich}\n" if (${tamanyo} < 9999999); 
		$linea="${tamanyo}\t${usu}\n${dir}\/..${nom_fich}\n" if (${tamanyo} > 9999999);
		push(@ficheros,$linea); 		
	};#if
 }#for	
	
}#sub
