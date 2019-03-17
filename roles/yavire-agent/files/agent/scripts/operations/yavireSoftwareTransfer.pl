#!/usr/bin/perl
use POSIX qw(strftime);


if ($^O =~ /Win/) {
  eval "use List::Util qw(first)";
  eval "use Archive::Zip qw(:ERROR_CODES :CONSTANTS)";
  eval "use File::Copy qw(copy)";
  eval "use File::Path";
  
  #eval "use lib  'C:\\krb\\yavire\\agent\\scripts'";
}
 
#require yavire21; 
  
#use List::Util qw(first);
#use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
#use File::Copy qw(copy);

#* NombreFichero: yavireSoftwareTransfer.pl
#*=========================================================
#* Fecha Creación: [17/03/2014]
#* Autor: Fernando Oliveros
#* Compañia: kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Transferencia de ficheros windows via rsync
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


sub transformFile {
   
   local($fileToTransform) = $_[0];
   local($dirMappings) = $_[1];
   local($dirTransform) = $_[2];
         
    # print "Hola2:($fileToTransform)\n";
    # print "Mappings:($dirMappings)\n";
    # print "TransformDir($dirTransform)\n";
   
   #Extraemos el nombre del fichero a transformar
   if ($^O =~ /Win/) {
      $fname= substr($fileToTransform, rindex($fileToTransform,"\\")+1, length($fileToTransform)-rindex($fileToTransform,"\\")-1);
      $fnameTransform = "$dirTransform\\$fname";
   }
   else {
      $fname= substr($fileToTransform, rindex($fileToTransform,"/")+1, length($fileToTransform)-rindex($fileToTransform,"/")-1);
      $fnameTransform = "$dirTransform/$fname";
   }
              
   # print "HOLA: $fnameTransform\n";
   
   open(FICH_CONF,"<$fileToTransform") || die "Error to open file $fileToTransform\n";
   open(FICH_CONF_TEMP,">$fnameTransform") || die "Error to open file $fnameTransform\n"; 
     
   #Leemos del fichero sin transformar
   while ($lineaOrig=<FICH_CONF>) {
       
       $totalLine=$lineaOrig;
       
       @variablesByLine=split (/\{\%/,$lineaOrig);
       my $size = @variablesByLine;
       
       if ($size > 1) {
          #Tenemos variables
          for ($j = 0; $j <= $#variablesByLine; $j++) {
             #Obtenemos la posible variable
             $lineaTmp="$variablesByLine[$j]";
             # print "Hola4($j): $lineaTmp\n";
            
             #Buscamos si acaba en el token %}
             ($varName) = ($lineaTmp =~ /(.*)\%\}/);
             
             # print "VARNAME : $varName\n";
           
             if ($varName ne "")  {
                # print "ENCONTRE LA VARIABLE : $varName\n";   
                
                #Buscamos el valor real de la variable en el fichero de variables
                #print "DIRMAPPIN-1: $dirMapping\n";
                
                ($varValue) = getVariable($dirMappings, $fname, $varName );
                
                # print "VARIABLE $varName\n";
                # print "VALOR NUEVO: $varValue\n";
                                
                $find = "\{\%$varName\%\}";
                
                # print "VALOR VIEJO ($find)\n";
                # print "LINEA A REEMPLAZAR: ($totalLine)\n";
                
                $find = quotemeta $find; # escape regex metachars if present
                
                $totalLine =~ s/$find/$varValue/g;
                
                # print "LINEA REEMPLAZADA: ($totalLine)\n";
                
                              
             }
          
          }
          
          print FICH_CONF_TEMP "$totalLine\n";	
       
          
      }
      else {
         print FICH_CONF_TEMP "$totalLine\n";
      }
             
      
   }#while
   close FICH_CONF;	
   close FICH_CONF_TEMP;
   
   
}

sub getVariable {
   
    local($fileMapping) = $_[0];
    local($fileName) = $_[1];
    local($varName) = $_[2];
    
    # print  "-----------------------------------------------------------------------------------------------------\n\n";
    
    # print "FILEMAPPING:  $fileMapping\n";
    # print "FILENAME:  $fileName\n";
    # print "VARNAME:  $varName\n";
    
    my $var ="";
    
    open(FICH_VAR,"<$fileMapping") || die "Error to open file $fileMapping\n";
    
     while ($lineMap=<FICH_VAR>) {
       
       my $line2=$lineMap;
              
       my @tokens=split (/;/,$line2);
       
       for ($m = 0; $m <= $#tokens; $m++) {
          
          my $line2Tmp="$tokens[$m]";
           # print "Hola4: $line2Tmp\n";
          
          if (index($line2Tmp, $fileName) != -1) {
            # print "ENCONTRE LA LINEA: $line2Tmp contains $fileName\n";
            
            if (index($line2Tmp, $varName) != -1) {
               # print "ESTA SI ES LA LINEA VERDADERA: $line2Tmp contains $fileName\n";
               
               #( $var ) = $lineaTmp=~ /(\=.*)\s*$/;
               
               ($var) = $line2Tmp =~ /=\s*(.+)$/;
               # print "VAR: $var\n";
               last;
               
            }
            
         } 
          
       }
       
    }
    
    close FICH_VAR;	
    
    # print  "-----------------------------------------------------------------------------------------------------\n\n";
    
    return $var;
}


sub getFilesToTransform {

        local($dirname) = $_[0];     
        local($dirTransforms) = $_[1];     
        local($dirVariables) = $_[2];
        
        
        opendir(DIR,$dirname) || die("Error to open $dirname");
        local(@cont) = readdir(DIR); 
        local($file);
        local($i); 
        for ($i=0; $i<=$#cont; $i++) {      	
            next if ($cont[$i] eq '.' || $cont[$i] eq '..');
            $file = "$dirname\\$cont[$i]";
            
            if (-d $file){            	
	        &getFilesToTransform($file, $dirTransforms, $dirVariables);				
	        
            }else{
               #Filtramos ficheros  
               #print "Hola3:  $file\n";
               
               #Si no existe el fichero de variables, simplemente copiamos el fichero
               #print "Hola4:  $file\n";
               if (-e $dirVariables) {
               
                  print "$file\n";
                  if ($file =~ /\.ini|\.conf|\.xml|\.yml|\.json|\.cfg|\.props|\.properties|\.sh|\.ksh|\.csh|\.bat|\.ps1/) {
                     open(FILE,$file);
                     if (grep{/\{\%/} <FILE>){
                        print "File $file with variables to transform\n";
                        push(@cont_dir,$file);  
                     }
                     else{
                        print "      File $file without variables to transform\n";
                        
                        #No tienen variables, pero se debe copiar al directorio del resto
                        
                        if ($^O =~ /Win/) {
                           copy($file,$dirTransforms) or print  "yavError: Copy failed";
                         }
                         else {
                             $salida=`cp -p $file $dirTransforms 2>&1`;
                             if ($salida=~ /No such/i) {
                                  print "\n $salida\n";
                             }
                         }
                        
                     }
                     close FILE;
                  }   
               }
               else {
                  
                  #print "Hola4:  $file\n";
                  if ($^O =~ /Win/) {
                     copy($file,$dirTransforms) or print  "yavError: Copy failed";
                   }
                   else {
                       $salida=`cp -p $file $dirTransforms 2>&1`;
                       if ($salida=~ /No such/i) {
                            print "\n $salida\n";
                       }
                   }
                  
               }
               
               
                        	
            }#if
         }#for                 
         closedir(DIR); 	    
}#getFilesToTransform

#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

$versionYAV = '2.2.0.2_48';

#Se añade dos puntos al parametro
$szUserDestinyServer="$ARGV[0]";
$szServerDestiny="$ARGV[1]";
$szSourceDir = "$ARGV[2]";
$szSourceDirWin = "$ARGV[3]";
$szDeployFile = "$ARGV[4]";
$szDirDestiny = "$ARGV[5]"; 
$typePermissions = "$ARGV[6]"; 
$mirror = "$ARGV[7]"; 
$SourceServerName = "$ARGV[8]"; 
$DestinyServerName = "$ARGV[9]"; 
$CopyContentDirectory = "$ARGV[10]"; 
$codFileTransfer = "$ARGV[11]"; 
$codOperationFT = "$ARGV[12]"; 
$backup = "$ARGV[13]";
$typeConf = "$ARGV[14]"; #Config = 1 or File Deploy = 0
$restore = "$ARGV[15]"; 

$baseAgentDirWin="C:\\krb\\yavire\\agent";
$baseAgentDirUnix="/opt/krb/yavire/agent";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

#$datelog="DDDDDD";
#$datelog=yavire21::formatoFechaLog();

if ($^O =~ /Win/) {
    $USER_PROCESS = $ENV{USERNAME};
}
else {
   $USER_PROCESS=(getpwuid($<))[0];
}


print "\n==============================================================================================\n";
print "   yavire File Transfer - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n\n";
print "        Source Server User: $USER_PROCESS\n";
print "        Source Server Name: $SourceServerName\n";
print "        Target Server IP: $szServerDestiny\n";
print "        Target Server Name: $DestinyServerName\n";
print "        Target Server User: $szUserDestinyServer\n";
print "        Source Directory: $szSourceDir\n"; 
print "        Source Directory for Windows: $szSourceDirWin\n"; 
print "        Files: $szDeployFile\n";
print "        Target Directory: $szDirDestiny\n";
print "        Permissions Type (755/750): $typePermissions\n";
print "        Mirror: $mirror\n";
print "        Directory content or Directory: $CopyContentDirectory\n";
print "        File Transfer Code: $codFileTransfer\n";
print "        Operation Code: $codOperationFT\n";
print "        Backup: $backup\n";
print "        Type: $typeConf (Config=1 Files=0)\n";
print "        Restore: $restore\n";
print "\n==============================================================================================\n\n";


if ($typePermissions eq 0) {
   #755
   $PERMISOS="u+rwx,g+rx,g-w,o+rx,o-w";
}
else {
   #750
   $PERMISOS="u+rwx,g+rx,g-w,o-rwx";
}


#Si es un restore, no hacemos ni transformaciones ni backups
if ($restore eq 0) {

   if ($typeConf eq 1) {
       print  "\n-----------------------------------------------------------------------------------------------------\n";
       print  "      Variables Transformations\n";
       print  "\n-----------------------------------------------------------------------------------------------------\n";
       
      #Obtenemos directorio donde encontrar las variables a transformar
      if ($^O =~ /Win/) {
         $dirMapping="$baseAgentDirWin\\mappingsFT\\$codFileTransfer"; 
      }
      else {
         $dirMapping="$baseAgentDirUnix/mappingsFT/$codFileTransfer/"; 
      }
      
      print  "      Mapping directory: $dirMapping\n";
      
      #Generamos directorio donde se dejaran los ficheros transformados
      if ($^O =~ /Win/) {
         
         if ($CopyContentDirectory eq 1) {
            $fnameDir= substr($szSourceDir, rindex($szSourceDir,"\\")+1, length($szSourceDir)-rindex($szSourceDir,"\\")-1);
            $dirConfTransform="$baseAgentDirWin\\transformsFT\\$codFileTransfer\\$codOperationFT\\$fnameDir"; 
            $dirConfTransformWin= "/cygdrive/C/krb/yavire/agent/transformsFT/$codFileTransfer/$codOperationFT/$fnameDir";
         
         }
         else {
            $dirConfTransform="$baseAgentDirWin\\transformsFT\\$codFileTransfer\\$codOperationFT";    
            $dirConfTransformWin= "/cygdrive/C/krb/yavire/agent/transformsFT/$codFileTransfer/$codOperationFT";

         }
         
         $szSourceDirWin = $dirConfTransformWin;
         $szSourceDirTmp =  "$baseAgentDirWin\\transformsFT\\$codFileTransfer\\$codOperationFT"; 
     
         
         
      }
      else {
         
          if ($CopyContentDirectory eq 1) {
            $fnameDir= substr($szSourceDir, rindex($szSourceDir,"/")+1, length($szSourceDir)-rindex($szSourceDir,"/")-1);
            $dirConfTransform="$baseAgentDirUnix/transformsFT/$codFileTransfer/$codOperationFT/$fnameDir/"; 
         }
         else {
            $dirConfTransform="$baseAgentDirUnix/transformsFT/$codFileTransfer/$codOperationFT/";       
         }
         
         $szSourceDirWin = $dirConfTransform;
         $szSourceDirTmp = "$baseAgentDirUnix/transformsFT/$codFileTransfer/$codOperationFT/"; 
      
      }
      
       print  "      New source directory: $szSourceDirWin\n";
      
      if (-d $dirConfTransform) {
         print LOG "The directory  $dirConfTransform exists\n";
      } 
      else {
         print "      Creating  $dirConfTransform directory\n";
      
      
         if ($^O =~ /Win/) {
            system 1, "mkdir $dirConfTransform";
         }
         else {
            `mkdir \-p $dirConfTransform`;
         }
          
         sleep 4;
      
      
      } 
      
      $fileVar="yavFTMapping.txt";

      if ($^O =~ /Win/) {
         $fileAndDir="$dirMapping\\$fileVar"; 
      }
      else {
         $fileAndDir="$dirMapping/$fileVar"; 
      }
      
      &getFilesToTransform($szSourceDir, $dirConfTransform, $fileAndDir);
      
      if (-e $fileAndDir) {
         print "        The mapping file $fileAndDir exists\n";
         
      } 
      else {
         print "        The mapping file $fileAndDir doesn't  exists\n";
         print "        The system will not be transforming variables. You can define them in the File Transfer Configuration\n";
      } 
      
      for($i = 0; $i <= $#cont_dir; $i++) { 
          print "($cont_dir[$i])\n";
          &transformFile($cont_dir[$i], $fileAndDir, $dirConfTransform);
      }
      
      
   }
   
   print  "-----------------------------------------------------------------------------------------------------\n\n";

   #/************BACKUPS******/

   if ($backup eq 1) {
      
      #Generamos directorio de backups
      if ($^O =~ /Win/) {
         $dirBackup="$baseAgentDirWin\\backupsFT\\$codFileTransfer\\$codOperationFT"; 
      }
      else {
         $dirBackup="$baseAgentDirUnix/backupsFT/$codFileTransfer/$codOperationFT/"; 
      }
         
      if (-d $dirBackup) {
         print LOG "The directory  $dirBackup exists\n";
      } 
      else {
         print "        Creating  $dirBackup directory\n";
         
         
         if ($^O =~ /Win/) {
            system 1, "mkdir $dirBackup";
         }
         else {
            `mkdir \-p $dirBackup`;
         }
             
         sleep 4;
         
      }      
      
      
       if ($typeConf eq 1) {
         $szSourceDir = $szSourceDirTmp;
       
       }
      
      #Si el valor viene con *, son transferencias de directorios y no de ficheros de despliegues
      #Si son ficheros, se hace un zip o tar, en caso contrario, una copia del war/ear
      if ($szDeployFile eq "*") {
         
         if ($^O =~ /Win/) {
           
            
            my $outDir = "$dirBackup\\$codFileTransfer-$codOperationFT.zip";
            my $obj = Archive::Zip->new();
            $obj->addTree( $szSourceDir );
            # Write the files to zip.
            if ($obj->writeToFileNamed($outDir) == AZ_OK) 
            {  

               print  "\n-----------------------------------------------------------------------------------------------------\n";
               print  "      Backup directory successfully...\n";
               print  "      Source:    $szSourceDir\n";
               print  "      Target:    $outDir\n";
               print  "-----------------------------------------------------------------------------------------------------\n\n";
            } 
            else 
            {
               print  "\n-----------------------------------------------------------------------------------------------------\n";
               print  "      Backup directory compress error:    $szSourceDir\n";
               print  "-----------------------------------------------------------------------------------------------------\n\n";
            }
         }
         else {
            
             $fich_tar="$codFileTransfer-$codOperationFT.tar";
             #Nos movemos al directorio source
             #`cd ${szSourceDir}`;
             
             chdir($szSourceDir);
             
              print "           Executing tar cvfp ${fich_tar} * \n\n";
            `tar cpf "${fich_tar}" * 2> /dev/null`;
            
            $salida=`mv  "${fich_tar}"  $dirBackup 2>&1`;
            if ($salida=~ /No such/i) {
                   print "\nERROR: $salida\n";
                   print LOGS "\nERROR: $salida\n";
            } else  {		
               print "           Copying file backup to  $dirBackup\n";
            }
            
             
         }
          
      }
      else {
          
          if ($^O =~ /Win/) {
              $source = "$szSourceDir\\$szDeployFile";
              $target = "$dirBackup\\$szDeployFile";
              
              print  "\n-----------------------------------------------------------------------------------------------------\n";
              print  "      Backup deploy file...\n";
              print  "      Source:    $source\n";
              print  "      Target:    $target\n";
              print  "-----------------------------------------------------------------------------------------------------\n\n";
              
              copy($source,$target) or print  "yavError: Copy failed";
          }
          else {
              $source = "$szSourceDir/$szDeployFile";
              $target = "$dirBackup/$szDeployFile";
              
              print  "\n-----------------------------------------------------------------------------------------------------\n";
              print  "      Backup deploy file...\n";
              print  "      Source:    $source\n";
              print  "      Target:    $target\n";
              print  "-----------------------------------------------------------------------------------------------------\n\n";
              
              
              $salida=`cp -p $source $target 2>&1`;
              if ($salida=~ /No such/i) {
                   print "\n $salida\n";
              }

          }
          
      }
      
   }
   
}


#Si el valor viene con *, son transferencias de directorios y no de ficheros de despliegues
if ($szDeployFile ne "*") {
   
   my @aFicherosDespliegues = split('@', $szDeployFile);
   
   foreach my $szFicheroDespliegue(@aFicherosDespliegues) {
       
       print "\n===================================================================================================================\n";
       print "      File Transfer ($szFicheroDespliegue)\n";
       print "===================================================================================================================\n\n";
      
       if ($mirror eq 0) {
           #NO ES ESPEJO. Se deja preparado rsync por si se quiere mejorar.
           if ($^O =~ /Win/) {
              $ENV{PATH} = 'C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}';
	      $parametroRSYNC = "C:\\krb\\yavire\\agent\\cwRsync\\bin\\rsync -avz --chmod=Dug=rwX,Fug=rw,Fug-x -e \"ssh -i /cygdrive/c/krb/yavire/agent/cwRsync/rsync-only\" -r  ${szSourceDirWin}/${szFicheroDespliegue} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
		     
	   }
	   else {
	      $parametroRSYNC = "/usr/bin/rsync -varl --chmod=${PERMISOS} ${szSourceDir}/${szFicheroDespliegue} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	   }
           
       }
       else {
           #ESPEJO
           
           if ($^O =~ /Win/) {
              $ENV{PATH} = 'C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}';
	      $parametroRSYNC = "C:\\krb\\yavire\\agent\\cwRsync\\bin\\rsync -avz --chmod=Dug=rwX,Fug=rw,Fug-x  -e \"ssh -i /cygdrive/c/krb/yavire/agent/cwRsync/rsync-only\" --delete -r  ${szSourceDirWin}/${szFicheroDespliegue} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
           }
	   else {
	      $parametroRSYNC = "/usr/bin/rsync -varl --chmod=${PERMISOS} --delete ${szSourceDir}/${szFicheroDespliegue} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	   }
       }
       
       my @commands = ( "${parametroRSYNC}");
       
       my @pids;
       foreach my $cmd( @commands ) {
          
          if ($^O =~ /Win/) {
              print "PATH=C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}\n";
              print "executing command: $cmd\n\n";
              
              my $result = `$cmd`;
              
           
              print $result;

	   }
	  else {
	     print "executing command: $cmd\n\n";
             my $pid = fork;
             if ( $pid ) {
                # parent process
                push @pids, $pid;
                next;
             }
          

             # now we're in the child
             @files = `${cmd}`;

             foreach (@files) {
                print "$_\n";
             }
             #system( $cmd );
             exit;            # terminate the child
	     
	  }
          
      }
      
      

       wait for @pids;   # wait for each child to terminate

       print "\n\n-------------------------------------------------------------------------------------------\n";  
       print "        Finished File Transfer $szFicheroDespliegue\n";
       print "-------------------------------------------------------------------------------------------\n";  
    
   }#foreach

   
}
else {
   
    print "\n===================================================================================================================\n";
    print "      Directory Transfer ($szSourceDir)\n";
    print "===================================================================================================================\n\n";
   
    if ($mirror eq 0) {
       
       if ($CopyContentDirectory eq 0) {
         #Solo copiamos el contenido del directorio
		 
	      if ($^O =~ /Win/) {
	         $ENV{PATH} = 'C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}';
	         $parametroRSYNC = "C:\\krb\\yavire\\agent\\cwRsync\\bin\\rsync -avz --chmod=Dug=rwX,Fug=rw,Fug-x -e \"ssh -i /cygdrive/c/krb/yavire/agent/cwRsync/rsync-only\" -r  ${szSourceDirWin}/* ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
		     
	      }
	      else {
	         $parametroRSYNC = "/usr/bin/rsync -varl --chmod=${PERMISOS} ${szSourceDir}/* ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	      }
		 
       }
       else {
         #Se copia en el directorio destino todo el origen, incluyendo el directorio y su contenido. Se elimina el /*
         if ($^O =~ /Win/) {
            $ENV{PATH} = 'C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}';
	        $parametroRSYNC = "C:\\krb\\yavire\\agent\\cwRsync\\bin\\rsync -avz --chmod=Dug=rwX,Fug=rw,Fug-x -e \"ssh -i /cygdrive/c/krb/yavire/agent/cwRsync/rsync-only\" -r  ${szSourceDirWin} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	     }
	     else {
	        $parametroRSYNC = "/usr/bin/rsync -varl --chmod=${PERMISOS} ${szSourceDir} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	     }
         

       }
       #/usr/bin/rsync -varl --chmod=$PERMISOS $DIRECTORIO_ORIGEN $USUARIO@$MAQUINA_DESTINO:$DIRECTORIO_DESTINO &
    }
    else {
       #En modo oespejo, eliminamos el * final y agregamos --delete
       if ($CopyContentDirectory eq 0) {
          #Solo copiamos el contenido del directorio
         	 
	   if ($^O =~ /Win/) {
	        $ENV{PATH} = 'C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}';
	        $parametroRSYNC = "C:\\krb\\yavire\\agent\\cwRsync\\bin\\rsync -avz --chmod=Dug=rwX,Fug=rw,Fug-x -e \"ssh -i /cygdrive/c/krb/yavire/agent/cwRsync/rsync-only\" --delete -r  ${szSourceDirWin}/ ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	        
	    }
	    else {
	        $parametroRSYNC = "/usr/bin/rsync -avz --chmod=${PERMISOS} --delete ${szSourceDir}/ ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
	        
	    }
	 
       }
       else {
          #Se copia en el directorio destino todo el origen, incluyendo el directorio y su contenido. Se elimina el /
          if ($^O =~ /Win/) {
	         $ENV{PATH} = 'C:\\krb\\yavire\\agent\\cwRsync\\bin;$ENV{PATH}';
	         $parametroRSYNC = "C:\\krb\\yavire\\agent\\cwRsync\\bin\\rsync -avz --chmod=Dug=rwX,Fug=rw,Fug-x -e \"ssh -i /cygdrive/c/krb/yavire/agent/cwRsync/rsync-only\" --delete -r  ${szSourceDirWin} ${szUserDestinyServer}\@${szServerDestiny}:${szDirDestiny}";
          }
	      else {
	         $parametroRSYNC = "/usr/bin/rsync -avz --chmod=${PERMISOS} --delete ${szSourceDir} ${szUserDestinyServer}\@${szServerDestiny}:$szDirDestiny}";
	      }

       }
    }
       
        
    my @commands = ( "${parametroRSYNC}");
       
    my @pids;
    foreach my $cmd( @commands ) {
       print "Command to execute: $cmd\n\n";
       
       # if ($^O =~ /Win/) {
          
         # open my $handle, '-|', $cmd or die $!;

         # push @procs, $handle;
          
       # }
       # else {
          
          my $pid = fork;
          if ( $pid ) {
             # parent process
             push @pids, $pid;
             next;
          }

          # now we're in the child
          @files = `${cmd}`;

          foreach (@files) {
             print "$_\n";
          }
          #system( $cmd );
          exit;            # terminate the child
       #}
          
    }

    wait for @pids;   # wait for each child to terminate

    print "\n\n-------------------------------------------------------------------------------------------\n";  
    print "        Directory Transfer Finished ($szSourceDir)\n";
    print "-------------------------------------------------------------------------------------------\n";  
   
}



# if ($restore eq 1) {
   # #Borramos el directorio origen del restore
   
    # print "\n\n-------------------------------------------------------------------------------------------\n";  
    # print "        deleting Restore Directory Transfer Finished ($szSourceDir)\n";
    # print "-------------------------------------------------------------------------------------------\n";  
   
   # if ($^O =~ /Win/) {
    
      # rmtree($szSourceDir);
      
       
   # }
   # else {
       
       # unlink $szSourceDir;
       
   # }
# }
                 


#$datelog=yavire21::formatoFechaLog();
print "\n\n==============================================================================================\n";
print "    Finishing yavire File Transfer - Version $versionYAV \n";
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . ")\n";
print "==============================================================================================\n";

#*===========================================================
#* Fin script: yavireSoftwareTransfer.pl]
#*===========================================================


