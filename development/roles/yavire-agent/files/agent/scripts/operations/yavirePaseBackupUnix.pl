#!/usr/bin/perl
use lib '/opt/krb/yavire/agent/perl/lib/perl5/site_perl/5.8.8';
use Shell::Source;
use POSIX qw(strftime);

$owmVersion="2.1.0.0_21";

#######################################################CONTROL DE CAMBIOS#######################################################
#Se añade como parametro $dirEntregas
#Se añade dos parametros.
#Primero:                                              
                #1: Se hace el backup
                #0: No se hace el backup
#El segundo si se hace o no la copia de entregas a intermedio:
                #1: Se hace la copia
                #0: No se hace la copia

#Se añade la operacion como parametro

#Se añade el Nombre del pase como parametro, Se emplea para dar nombre al tar de backup (previo a la fecha/hora)

#Se añade como parametro el dominio, Indica el dominio a utilizar para los directorios intermedios


##########################################################TAREAS DEL SCRIPT##########################################################
 #1.Crea hasta un máximo de cinco copias de seguridad en  
 #2.Copia lo existente en entregables en instalaciones. 
 #3.Se elimina el versionado de entregables.

##########################################################Ejemplo de llamada:##########################################################
#/opt/krb/yavire/agent/scripts/operations/yavirePaseBackupUnix.pl "/home/yavire/entregas/test" "/home/yavire/instalaciones/yavire/oculto" 0 1  1 22222 yavire-test oculto


#*===========================================================
#* Funciones del programa
#*===========================================================
sub compararFicheros {
    
    $szFicheroOrigen = shift;
    $szFicheroDestino = shift;
    
    my $bFichIguales = 0;
        
    my $iTamFichOrigen;
    $iTamFichOrigen = `cksum $szFicheroOrigen | cut -d ' ' -f2`;
    chomp $iTamFichOrigen;
        
    my $iTamFichDestino;
    $iTamFichDestino = `cksum $szFicheroDestino | cut -d ' ' -f2`;
    chomp $iTamFichDestino;
    
    
    
    my $date1 = m_to_date(-M $szFicheroOrigen);
    my $date2 = m_to_date(-M $szFicheroDestino);
    
    print LOGS "Comparacion de ficheros:\n";
    print LOGS "   Source File:       $szFicheroOrigen \n";
    print LOGS "       Tam  : $iTamFichOrigen\n";
    print LOGS "       Date : $date1\n\n";
    
    print LOGS "   Intermediate File: $szFicheroDestino\n";
    print LOGS "       Tam  : $iTamFichDestino\n";
    print LOGS "       Date : $date2\n\n";
    
        
    if ($iTamFichOrigen==$iTamFichDestino) {
    	# print LOGS "Los ficheros son iguales \n";
    	$bFichIguales = 1;
    }
    else {
    	print LOGS "Los ficheros no son iguales \n";
    }
    
    # Ahora comparamos las fechas
    if (not ($date1 eq $date2)) {
	    
        # print LOGS "Las fechas son distintas, copiamos a intermedio.\n\n";
        $bFichIguales = 0;
    }
    
    
    return $bFichIguales;
}

sub m_to_date {
	
	   use POSIX qw/strftime/;
   
   my $days_ago = shift;
   my $ts = time() - ($days_ago * 24 * 60 * 60);
   
   #my $date = strftime('%Y-%m-%d', localtime($ts));
   my $date = strftime('%Y-%m-%d %H:%M:%S', localtime($ts));
   return $date;
}

sub backup {
	
	    $szFicheroDespliegue = shift;
    
        $nv=3; #Numero de versiones a mantener
        @dir_raiz = split(/$szDominio/, $szDirIntermedio);
        $dir_copias="${szDirIntermedio}_Backup";

    if (not (-d $dir_copias)) {
        print LOGS "Creamos directorio de backup $dir_copias\n";
       `mkdir \-p $dir_copias` unless (-e $dir_copias);
       sleep 5;
   }
 	    print LOGS "\n-------------------------------------------------------------------------------------------------------------------------\n";
    print LOGS "      Ejecucion de backup del fichero  $szFicheroDespliegue\n";
    print LOGS "-------------------------------------------------------------------------------------------------------------------------\n\n";
	   
   
   if (-e $szDirIntermedio) {


        #Revisamos la cantidad de backups
        chdir(${dir_copias});
                if ($szFicheroDespliegue ne "N/A") {
	   @contenido = `ls -rt *$szFicheroDespliegue`;
           if ($contenido=~ /No such/i) {
    	      print LOGS "\nERROR: $salida\n";
	   }

	}
	else {
	   @contenido = `ls -rt $nombrePase*`;
           if ($contenido=~ /No such/i) {
    	      print LOGS "\nERROR: $salida\n";
	   }
	
        }
                # print LOGS "Total ficheros anteriores: $#contenido\n";        # foreach (@contenido) {
 	   # print LOGS $_;
        # } 
	
	#Borra todas las versiones a partir de la cuarta
	$fin=$#contenido - ${nv} + 1;
	 	
        for($i = 0; $i <= $fin; $i++) {
           #Borra cada directorio
           $file = "$contenido[$i]";	
           print LOGS "Borrando fichero antiguo: $file\n";	
           $salida=`rm  $file 2>&1`;
                   
       }#for  
		                   
	#Crea el directorio version en el directorio 
	$date=&formatofecha(time);
	
	$dir_date="${dir_copias}";
	
	@directorio_date = split(/\//, $dir_date);
	
	#Copia del directorio intermedio ($szDirIntermedio) a $dir_date
	$dir_ori="${szDirIntermedio}/\*";
	
	opendir(DIR_INTERMEDIO,$szDirIntermedio) || die("No puede abrir el directorio $szDirIntermedio");
        @cont_ori_distri = readdir(DIR_INTERMEDIO);  
        closedir(DIR_INTERMEDIO);
 
        if ($#cont_ori_distri > 1) {
         	
        	#print LOGS "Cambiando a directorio ${szDirIntermedio}\n";
         	chdir(${szDirIntermedio});
        	
                if ($szFicheroDespliegue ne "N/A") {
			
                      $fich_copia="BK_${date}_${szFicheroDespliegue}";
                                            # print LOGS "Fichero copia: $fich_copia\n";
                                            $salida=`cp -p $szFicheroDespliegue $dir_date/$fich_copia 2>&1`;
	              if ($salida=~ /No such/i) {
	      	         print LOGS "\nERROR: $salida\n";
	      	      } else  {		
			 print LOGS "Backup:\n";
			 print LOGS "   Origen : $szDirIntermedio/$szFicheroDespliegue\n";
			 print LOGS "   Destino: $dir_date/$fich_copia\n";
		      }
                  
                }
                else {
                   
                   $fich_tar="${nombrePase}_${date}";
                   print LOGS "Ejecutando tar cvfp ${fich_tar}.tar * \n\n";
                   `tar cpf "${fich_tar}.tar" * 2> /dev/null`;
                   $salida=`mv  "${fich_tar}.tar"  $dir_date 2>&1`;
		
		   if ($salida=~ /No such/i) {
		 	print "\nERROR: $salida\n";
		 	print LOGS "\nERROR: $salida\n";
		   } else  {		
			print LOGS "Moviendo comprimido de  $szDirIntermedio hacia $dir_date\n";
		   }
		
                   
                }
                
	 }#if
	
	
   } else {
	#SE CREA TODO EL DIRECTORIO DE instalaciones
	`mkdir \-p $szDirIntermedio`;
	sleep 4;
   }
	}


sub copiaEntregaAIntermedio {
	        $szFicheroDespliegue = shift;
	
	print LOGS "\n-------------------------------------------------------------------------------------------\n";
        print LOGS "      Copia de origen a intermedio \n";
        print LOGS "-------------------------------------------------------------------------------------------\n\n";
	
	if (-d $szDirIntermedio) {
		
	   chdir($szDirIntermedio);
           
  	    #Si no es fichero de despliegue, borramos el directorio.
	    if (not ($szFicheroDespliegue ne "N/A")) {
	       $salida=`rm -r * 2>&1`;
	       if ($salida=~ /error/i) {
	          print LOGS "\nERROR: $salida\n";
	       }
	       else  {		
	          print LOGS "Borramos directorio intermedio $szDirIntermedio/*\n";
	       } #if
	   }#if		
	   
	           
           $DIR_ORIGEN = $dirEntregas;
           $DIR_ORIGEN =~ s/\/\*$//; #Elimina /* al final del directorio si lo hubiera
           
           if (-d $DIR_ORIGEN) {
		   
              # print LOGS "Copiando de entregas $DIR_ORIGEN a intermedio $szDirIntermedio\n";
              
	      chdir($DIR_ORIGEN);
	      
              if ($szFicheroDespliegue ne "N/A")
              {
		      
		  print LOGS "Copia:\n";
		  print LOGS "   Origen : $DIR_ORIGEN$szFicheroDespliegue\n";
		  print LOGS "   Destino: $szDirIntermedio/$szFicheroDespliegue\n";
	          $salida=`cp -p $szFicheroDespliegue $szDirIntermedio 2>&1`;
	          if ($salida=~ /No such/i) {
	      	     print LOGS "\nERROR: $salida\n";
	          }
	         
	                         
              }
              else {
                  print LOGS "Copiando todo el directorio $DIR_ORIGEN hacia  el directorio $szDirIntermedio\n";
	          $salida=`cp -rp * $szDirIntermedio 2>&1`;
	          if ($salida=~ /No such/i) {
	      	     print LOGS "\nERROR: $salida\n";
	         }
                 
              } 	      
	     
	   }
	   
	}
}

sub copiaBackupAIntermedio {
	
        $szFicheroDespliegue = shift;
	
	print LOGS "\n-------------------------------------------------------------------------------------------\n";
        print LOGS "      Copia de backup a intermedio \n";
        print LOGS "-------------------------------------------------------------------------------------------\n\n";
	
	if (-d $szDirIntermedio) {
		
	   chdir($szDirIntermedio);
           
  	    #Si no es fichero de despliegue, borramos el directorio.
	    if (not ($szFicheroDespliegue ne "N/A")) {
	       $salida=`rm -r * 2>&1`;
	       if ($salida=~ /error/i) {
	          print LOGS "\nERROR: $salida\n";
	       }
	       else  {		
	          print LOGS "Borramos directorio intermedio $szDirIntermedio/*\n";
	       } #if
	   }#if		
	   
	           
           $DIR_ORIGEN = "${szDirIntermedio}_Backup/";
           $DIR_ORIGEN =~ s/\/\*$//; #Elimina /* al final del directorio si lo hubiera
           
           if (-d $DIR_ORIGEN) {
		   
              # print LOGS "Copiando de backup $DIR_ORIGEN a intermedio $szDirIntermedio\n";
              
	      chdir($DIR_ORIGEN);
	      
              if ($szFicheroDespliegue ne "N/A")
              {
		  
	         # Como es un restore, eliminamos la fecha del fichero AAAAMMDD_HHMM_Fichero 
	         my @aRestoreFile = split('_', $szFicheroDespliegue);
	         
	         $salida=`cp -p $szFicheroDespliegue $aRestoreFile[3] 2>&1`;
	              
		 print LOGS "Mueve:\n";
		 print LOGS "   Origen : $DIR_ORIGEN$aRestoreFile[3]\n";
		 print LOGS "   Destino: $szDirIntermedio/$aRestoreFile[3]\n";
	         $salida=`mv  $aRestoreFile[3] $szDirIntermedio 2>&1`;
	         if ($salida=~ /No such/i) {
	      	    print LOGS "\nERROR: $salida\n";
	         }
	         
	                         
              }
              else {
                  print LOGS "Copiando todo el directorio $DIR_ORIGEN hacia  el directorio $szDirIntermedio\n";
	          $salida=`cp -rp * $szDirIntermedio 2>&1`;
	          if ($salida=~ /No such/i) {
	      	     print LOGS "\nERROR: $salida\n";
	         }
                 
              } 	      
	     
	   }
	   
	}

}
#*===========================================================
#* Fin de funciones del programa
#*===========================================================

#*===========================================================
#* Definición de variables
#*===========================================================


$dirEntregas = $ARGV[0];
$szParFichDespliegue = $ARGV[1]; #Pueden venir varios ficheros separados por @
$szDirIntermedio = $ARGV[2];
$ESPEJO = $ARGV[3]; #ESPEJO 1, NO ESPEJO 0
$RESTORE = $ARGV[4]; 
$COPIAdeENTREGABLES = $ARGV[5]; #COPIA de Entregables a Intermedio 1, NO COPIA 0
$OPERACION = $ARGV[6]; #Numero de operacion
$nombrePase = $ARGV[7]; #Nombre del pase
$szDominio = $ARGV[8]; #Dominio: Integracion Produccion oculto

$DIRLOG="/opt/krb/yavire/agent/webtools/operaciones/comandos";

#$nv=5; #Numero de versiones a mantener
#$copias="copias${szDominio}"; #Directorio donde se dejan las copias de seguridad
#*===========================================================
#* Cuerpo del programa 
#*===========================================================

if ($szParFichDespliegue ne "N/A") {
   
   $COMANDO="PaseProgramasEjecutarDespliegueUnixBK";	
}
else {
   $COMANDO="PaseProgramasEjecutarPROGUnixBK";	
}

$FICHLOG="$DIRLOG\/$OPERACION\_$nombrePase\_$COMANDO";

#Se abre el fichero para guardar los logs
open(LOGS,">>$FICHLOG") || die "problemas abriendo fichero de log $fich_logs\n";

$datelog=&formatofecha_log(time);print LOGS "\n==============================================================================================\n";
print LOGS "   yavire script for backup Version $owmVersion ($datelog)\n";
print LOGS "\n==============================================================================================\n\n";
print LOGS "      Command: $COMANDO\n";
print LOGS "      Source Dir: $dirEntregas\n";
print LOGS "      Deploy File: $szParFichDespliegue\n"; 
print LOGS "      Intermediate Directory: $szDirIntermedio\n";
print LOGS "      CopyToIntermediate: $COPIAdeENTREGABLES\n";
print LOGS "      Mirror: $ESPEJO\n";
print LOGS "      Restore: $RESTORE\n";
print LOGS "      Instance: $nombrePase\n";
print LOGS "      Environment: $szDominio\n";
print LOGS "      Operation ID: $OPERACION\n";
print LOGS "      Log: $FICHLOG\n";
print LOGS "\n==============================================================================================\n\n";


$szDirIntermedio =~ s/\/\*$//; #Elimina /* al final del directorio si lo hubiera

#Comprueba que lo que se pasa como parametro es valido.
if ($szDirIntermedio eq  "") {
	print "OWM_ERROR: Se le ha de pasar como parametro el directorio inicial\n";
	exit 1; 
}#fin

@dir_raiz = split(/$szDominio/, $szDirIntermedio);

if (not (-d $szDirIntermedio)) {
    print LOGS "Creamos directorio  $szDirIntermedio \n";
    `mkdir \-p $szDirIntermedio` unless (-e $szDirIntermedio);
    sleep 5;
}

#Generamos el subdirectorio de copias
#$dir_copias="$dir_raiz[0]$copias";

$datelog=&formatofecha_log(time);

#Analizamos el fichero de despliegue
$szPathFicheroOrigen = "${dirEntregas}";

if ($szParFichDespliegue ne "N/A")
{
   
   my @aFicherosDespliegues = split('@', $szParFichDespliegue);
      #Recorremos los ficheros
   
      foreach my $szFicheroDespliegue(@aFicherosDespliegues) {
	              if ($RESTORE != 0) {
		 
            $dirEntregas =  "${szDirIntermedio}_Backup/";
            print LOGS "\n-----------------------------------------------------------------------------------------------------\n";
            print LOGS "      Restore de fichero   $szFicheroDespliegue\n";
            print LOGS "-----------------------------------------------------------------------------------------------------\n\n";
            copiaBackupAIntermedio($szFicheroDespliegue);
            
         }
         else {
		 
	     print LOGS "\n===================================================================================================================\n";
             print LOGS "      Comprobacion de fichero $szFicheroDespliegue\n";
             print LOGS "===================================================================================================================\n\n";
             
             
            $szPathFicheroOrigen = "${dirEntregas}${szFicheroDespliegue}";
            $szPathFicheroDestino = "${szDirIntermedio}/${szFicheroDespliegue}";
                 
            #print "FICHDESP: $szFichDespliegue\n";	
            print LOGS "\nSource File:        $szPathFicheroOrigen\n";
            print LOGS "Intermediate File: $szPathFicheroDestino\n\n";
            
            if ((-e "$szPathFicheroOrigen") and (-e "$szPathFicheroDestino")) {
                 
               $bFichIguales = compararFicheros($szPathFicheroOrigen,$szPathFicheroDestino);
                          
               if  ($bFichIguales == 1) {
                  print LOGS "OWM_WARN: El fichero entregado es igual al fichero actual, no hacemos backup ni copiamos al directorio intermedio\n";
               }
               else {
                  # print LOGS "El fichero entregado es diferente del fichero del directorio intermedio, se hace backup y se copia al directorio intermedio\n";
                                  
                  backup($szFicheroDespliegue);
                  copiaEntregaAIntermedio($szFicheroDespliegue);
                  
                  
               }
            }
            else {
               
               if (not (-e "$szPathFicheroOrigen")){
                  print LOGS "\nOWM_ERROR: El fichero de despliegue $szFicheroDespliegue no existe. Nos salimos.\n";
                  #Salimos del programa, no hay nada que desplegar/copiar
                  # print LOGS "Nos salimos del programa, no hay fichero de despliegue en el directorio origen\n\n";
                  exit 1;
               }
               
               if (not (-e "$szPathFicheroDestino")) {
                  print LOGS "\nEl fichero de despliegue $szPathFicheroDestino no existe en el directorio intermedio. No hacemos Backup y se copia el entregado al directorio intermedio.\n\n";
                  copiaEntregaAIntermedio($szFicheroDespliegue);
                  
               }
            }
            
             print LOGS "\n-------------------------------------------------------------------------------------------\n\n";         
        }#If Restore
        
     }#foreach

}
else {
   print LOGS "No tenemos fichero de despliegue como parametro, es un pase de programas\n";
   backup("N/A");
   copiaEntregaAIntermedio("N/A");
}
	
$datelog=&formatofecha_log(time);
print LOGS "\n==============================================================================================\n";
print LOGS "   Finishing yavire script for backup Version $owmVersion ($datelog) \n";
print LOGS "\n==============================================================================================\n";



close LOGS;


#####################################################
#										RUTINAS
#####################################################
#
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


sub formatofecha {
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
	local($fecha)= "${year}${mes}${dia}_$hour$min";
	return $fecha;
}



sub full_rmdir {
	local($dirname) = $_[0];
	$dirname =~ s/\s$//;
	#print "Se procede a borrar el directorio ${dirname}fin\n";
	`rm -r "$dirname"`;
	
}#full_rmdir

#Indica si el directorio está vacio
sub dir_vacio {
	local($dirname) = $_[0];
	opendir(DIR, $dirname) || die("No puede abrir el directorio 334 $dirname");
        local(@cont) = readdir(DIR);  
        
        #print "ENTRA EN dir_vacio\n";
        if ($#cont < 2 ) {
        	#Está vacio
        	print "dirname=$dirname esta vacio\n";
        	return 0;
        } else {
        	print "dirname=$dirname NO esta vacio\n";
        	return 1;
        }
	close DIR;

}#sub dir_vacio
