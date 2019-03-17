#!/usr/bin/perl

package yavireUnix;


#* NombreFichero: yavireUnix.pm
#* Version 2.2.0.5_7 - 10/02/2019
#*=========================================================
#* Fecha Creación: [30/10/2014]
#* Autor: Fernando Oliveros
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Libreria de funciones comunes 2.2.0.2_2
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
#* Date: []
#* Problema:  
#* Solucion:  
#*
#*=============================================
#

#*===========================================================
#* Funciones del programa 
#*===========================================================


sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub getSystemManufacturer {
   
   local ($system_manufacturer);
   
   $system_manufacturer=`sudo /usr/sbin/dmidecode -s system-manufacturer`;
   
   chomp $system_manufacturer;
   
   $system_manufacturer = trim($system_manufacturer);
   
   print "System Manufacturer: ${system_manufacturer}\n";
   
   return $system_manufacturer;
   
   
}

sub getSystemModel {
   
   local ($system_model);
   
   $system_model=`sudo /usr/sbin/dmidecode -s system-product-name`;
   
   chomp $system_model;
   
   $system_model = trim($system_model);
   
   # print "System Model: $system_model\n";
   
   return $system_model;
   
   
}

sub getServerSerial {
   
   local ($server_serial);
   $server_serial_all=`sudo /usr/sbin/dmidecode -t system | grep Serial`;
   
   chomp $server_serial_all;
      
   @coresSplit = split(/\:/, $server_serial_all);
   
   $server_serial=$coresSplit[1];
   
   chomp $server_serial;
   
   $server_serial = trim($server_serial);
   
   # print "Server serial:  $server_serial\n";
   
   return $server_serial;
   
   
}

sub getCpuVendor {
   
   local ($hw_cpu_vendor);
   
   $hw_cpu_vendor_all=`sudo /usr/sbin/dmidecode -t processor |grep Manufacturer:`;
   
   chomp $hw_cpu_vendor_all;
      
   @cpuSplit = split(/\Manufacturer:/, $hw_cpu_vendor_all);
   
   # foreach (@cpuSplit) {
      # print "Linea: $_\n";
   # }
   
   $hw_cpu_vendor=$cpuSplit[1];
   
   chomp $hw_cpu_vendor;
   
    $hw_cpu_vendor = trim($hw_cpu_vendor);
   
   print "CPU Vendor: ($hw_cpu_vendor)\n";
   
   return $hw_cpu_vendor;
   
}


sub getCpuModel {
   
   local ($hw_cpu_model);
   local ($hw_cpu_model1);
   local ($hw_cpu_model2);
   
   $hw_cpu_model1_all=`sudo /usr/sbin/dmidecode -t processor |grep Version:`;
   
   chomp $hw_cpu_model1_all;
      
   @model1Split = split(/\Version:/, $hw_cpu_model1_all);
   
   $hw_cpu_model1=$model1Split[1];
   
   chomp $hw_cpu_model1;
   
   $hw_cpu_model1 = trim($hw_cpu_model1);
   
   
   ## Buscamos la familia de procesadores
   
   # $hw_cpu_model2_all=`sudo /usr/sbin/dmidecode -t processor |grep Family:`;
   
   # chomp $hw_cpu_model2_all;
         
   # @model2Split = split(/\Family:/, $hw_cpu_model2_all);
   
   # $hw_cpu_model2=$model2Split[1];
   
   # chomp $hw_cpu_model2;
   
   # $hw_cpu_model2 = trim($hw_cpu_model2);
   
   $hw_cpu_model =  $hw_cpu_model1;
   
   print "CPU Model: $hw_cpu_model\n";
   
   return $hw_cpu_model;
   
}


sub getCpuMHZ {
   
   local ($hw_cpu_mhz);
   
   $hw_cpu_mhz_all=`sudo /usr/sbin/dmidecode -s processor-frequency`;
   
   chomp $hw_cpu_mhz_all;
   
   @mhzSplit = split(/ /, $hw_cpu_mhz_all);
   
   $hw_cpu_mhz=$mhzSplit[0];
   
   # print "CPU Mhz: $hw_cpu_mhz\n";
   
   return $hw_cpu_mhz;
   
   
}

sub getNumberOfProcessors {
   
   local ($NumberOfProcessors);
   
   $NumberOfProcessors=`sudo cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l`;
   
   chomp $NumberOfProcessors;
   
   # print "Number of Processors: $NumberOfProcessors\n";
   
   return $NumberOfProcessors;
   
   
}

sub getCpuCores {
   
   local ($hw_cpu_cores);
   
   #$hw_cpu_cores=`cat /proc/cpuinfo |grep 'sibling|cores' | grep -i "processor" /proc/cpuinfo | sort -u | wc -l`;
   $hw_cpu_cores=`cat /proc/cpuinfo |grep 'cpu cores' |  sort -u | awk \'{print \$4}\'`;
   
   chomp $hw_cpu_cores;
   
   # print "CPU Cores: $hw_cpu_cores\n";
   
   return $hw_cpu_cores;
   
   
}

sub getCpuVirtualCores {

   local ($hw_cpu_cores);

   $hw_cpu_cores=`sudo cat /proc/cpuinfo | grep processor | wc -l`;

   chomp $hw_cpu_cores;

   # print "CPU Cores: $hw_cpu_cores\n";

   return $hw_cpu_cores;


}


sub getCpuThreads {
   
   local ($hw_cpu_threads);
   $hw_cpu_threads_all=`sudo /usr/bin/lscpu | grep -i thread`;
   
   chomp $hw_cpu_threads_all;
   
   # print "CPU Threads $hw_cpu_threads_all\n";
   
   @coresSplit = split(/\:/, $hw_cpu_threads_all);
   
   $hw_cpu_threads=$coresSplit[1];
   
   chomp $hw_cpu_threads;
   
   # print "CPU Threads $hw_cpu_threads\n";
   
   return $hw_cpu_threads;
   
   
}
  
sub getServerTotalMemory {
   
   local ($server_totalMemory);
   
   $server_totalMemory =`sudo cat /proc/meminfo | grep MemTotal |  awk \'{print \$2}\'`;
   
   chomp $server_totalMemory;
   
   # print "Server Total Memory: $server_totalMemory\n";
   
   return $server_totalMemory;
   
   
}


sub getOSManufacturer {
   
   local ($os_manufacturer);
     
   $os_manufacturer = "UNDEFINED";
      
   if ($^O eq "linux") {
      
      #Oracle Linux
      if (-e  "/etc/oracle-release") {
            $os_manufacturer = "Oracle\n";
      }
      else {
         
         #Red Hat
         if (-e  "/etc/redhat-release") {
            $os_manufacturer_all = `sudo cat /etc/redhat-release` if -f  "/etc/redhat-release";
            chomp $os_manufacturer_all;
   
            @osSplit = split(/ /, $os_manufacturer_all);
   
            $os_manufacturer=$osSplit[0];
   
            chomp $os_manufacturer;
      
            $os_manufacturer = trim($os_manufacturer);
      
            if (index($os_manufacturer, "Red") != -1) {
               $os_manufacturer = "Red Hat\n";
            }

            
         }
         else {
            
            #Amazon AMI
            if (-e  "/etc/system-release") {
               $os_manufacturer_all = `sudo cat /etc/system-release` if -f  "/etc/system-release";
               chomp $os_manufacturer_all;
   
               @osSplit = split(/ /, $os_manufacturer_all);
   
               $os_manufacturer=$osSplit[0];
   
               chomp $os_manufacturer;
      
               $os_manufacturer = trim($os_manufacturer);
      
               if (index($os_manufacturer, "Amazon") != -1) {
                  $os_manufacturer = "Amazon AWS\n";
               }
            }
            else {
               
               #Ubuntu
               if (-e  "/etc/os-release") {
                  
                  $os_manufacturer_all = `sudo cat /etc/os-release | grep PRETTY_NAME` if -f  "/etc/os-release";
                  
                  chomp $os_manufacturer_all;
                  @osSplit = split(/=/, $os_manufacturer_all);
                  $os_manufacturer=$osSplit[1];
                  chomp $os_manufacturer;
                  
                  #Quitamos las comillas del inicio y fin
                  $os_manufacturer = substr( $os_manufacturer, 1, (length($os_manufacturer) - 2) );
                  
                  $os_manufacturer = trim($os_manufacturer);
                  
                  if (index($os_manufacturer, "Ubuntu") != -1) {
                     $os_manufacturer = "Ubuntu\n";
                  }
                  else {
                     
                     if (index($os_manufacturer, "SUSE") != -1) {
                        $os_manufacturer = "SUSE\n";
                     }

                     
                  }

               }
               
            }
            
         }
         
      }
     
       print "OS Manufacturer:  $os_manufacturer\n";
   }
   
   return $os_manufacturer;
   
   
}


sub getOSVersion {
   
   local ($os_version);
   
   $os_version = "UNDEFINED";
      
   if ($^O eq "linux") {
      
      ($system_manufacturer) = getSystemManufacturer();
      
       if (-e  "/etc/oracle-release") {
          $os_version = `sudo cat /etc/oracle-release`
       }   
       else {
          if (-e  "/etc/redhat-release") {
             
             $os_version = `sudo cat /etc/redhat-release` if -f  "/etc/redhat-release";
             
          }
          else {
             #Amazon AMI
            if (-e  "/etc/system-release") {
               $os_version = `sudo cat /etc/system-release` if -f  "/etc/system-release";
            }
            else {
               
               #Ubuntu
               if (-e  "/etc/os-release") {
                  
                  $os_version_all = `sudo cat /etc/os-release | grep PRETTY_NAME` if -f  "/etc/os-release";
                  
                  chomp $os_version_all;
                  @osSplit = split(/=/, $os_version_all);
                  $os_version=$osSplit[1];
                  chomp $os_version;
                  
                  #Quitamos las comillas del inicio y fin
                  $os_version = substr( $os_version, 1, (length($os_version) - 2) );
                  
                  $os_version = trim($os_version);
             
               }
               
            }
          }
      }
      chomp $os_version;
    
      # print "OS Version:  $os_version\n";
   }
   
   return $os_version;
   
}

sub getOSLevel {
   
   local ($os_level);
   
   $os_level = "UNDEFINED";
      
   if ($^O eq "linux") {
      $os_level = `sudo uname -r`;
      chomp $os_level;
    
      # print "OS Level  $os_level\n";
   }
   
   return $os_level;
   
}


sub getOSArchitecture {
   
   local ($os_architecture);
   
   $os_architecture = "UNDEFINED";
      
   if ($^O eq "linux") {
      $os_architecture = `sudo arch`;
      chomp $os_architecture;
       if ($os_architecture eq "x86_64") {
          $os_architecture = 64;
       }
       else {
          $os_architecture = 32;
       }
    
      
    
      # print "OS Architecture:  $os_architecture\n";
   }
   
   return $os_architecture;
   
}

sub getServerUUID {
   
   local ($server_uuid);
   $server_uuid_all=`sudo /usr/sbin/dmidecode -t system | grep UUID`;
   
   chomp $server_uuid_all;
      
   @uuidSplit = split(/\:/, $server_uuid_all);
   
   $server_uuid=$uuidSplit[1];
   
   chomp $server_uuid;
   
   $server_uuid = trim($server_uuid);
   
   # print "Server UUID:  ($server_uuid)\n";
   
   return $server_uuid;
   
   
}

sub getIPServer {
   #Halla la IP de la máquina
   #Genera las ips de la máquina
   local ($ip);
   local ($SO)=`sudo uname -s`;
   chop $SO;
	
   $ip="127.0.0.1";

   
   ($os_manufacturer) = getOSManufacturer(); 
     
   ($os_version) = getOSVersion();   
     
   ($os_level) = getOSLevel();   

   print "Version: $os_version\n";
   print "Level: $os_level\n";
   print "Manufacturer: $os_manufacturer\n";
		
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
                  
      #my @ips = (`sudo /sbin/ifconfig -a` =~ /inet addr:(\S+)/g);
       $ip = `sudo ip route get 1.2.3.4 | awk \'{print \$7}\'`;
      $ip =~ s/^\s+|\s+$//g;
      chomp $ip;

      my $string = "Fred\nWilma\Betty\n";
      open my($fh), "<", \$ip; # reading from the data in $string
      my $first_line = <$fh>; # gives "Fred"
      close $fh;
      $first_line =~ s/^\s+|\s+$//g;
      $ip = $first_line;
		
	} else  {
		#("$SO" eq "Solaris (SunOS)")
		$ip=`/usr/sbin/nslookup $maquina \|tail \-2 \|head \-1 \|cut \-d\":\" \-f2 \|cut -d\" \" \-f3`;
		if ($ip !~ /\d+\.\d+\.\d+\.\d+/) {
			$ip=`ifconfig -a \| grep \"inet\" \| head \-1 \| awk \'{print \$2}\'`;
			chomp $ip;
		}#if	
	}#if (SO)

   print "IP founded: [${ip}] \n";

	return $ip;
}

sub getIPServerOLD {
	#Halla la IP de la máquina
	#Genera las ips de la máquina
	local ($ip);
	local ($SO)=`sudo uname -s`;
	chop $SO;
	
	$ip="127.0.0.1";

   
   ($os_manufacturer) = getOSManufacturer(); 
     
   ($os_version) = getOSVersion();   
      
     ($os_level) = getOSLevel();   

   print "Version: $os_version\n";
   print "Level: $os_level\n";
   print "Manufacturer: $os_manufacturer\n";
		
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
		
		
		#NUEVAS OPCIONES.... A PROBAR
		#[yavagent@dvyavmaster scripts]$ ip route | grep src|grep metric
                #192.168.11.0/24 dev ens33 proto kernel scope link src 192.168.11.131 metric 100
                
                #hostname --all-ip-addresses
                  
                  
		my @ips = (`sudo /sbin/ifconfig -a` =~ /inet addr:(\S+)/g);
		my $size = @ips;
		print "Array lengthF: $size\n";
		
		if ($size == 0) { 
		
		   #my @lines = `ifconfig -a | perl -ne 'if ( m/^\s*inet (?:addr:)?([\d.]+).*?cast/ ) { print qq($1\n); exit 0; }'`;
		   #print system(`ifconfig -a | perl -ne 'if ( m/^\s*inet (?:addr:)?([\d.]+).*?cast/ ) { print qq(\$1\n); exit 0; }'`);
		   
		   my @ipsInet = (`sudo /sbin/ifconfig -a` =~ /inet (\S+)/g);
		   
		   foreach (@ipsInet) {
                      my $ipTmp =$_;
                  
                      if ($ipTmp ne '127.0.0.1') {
                         $ip = $ipTmp ;
                         last;
                      }
                   }
		   
		   
		   # my @lines = `ifconfig -a`;
		   # my $size2 = @lines;
		   # print "Array lengthX: $size2\n";
		   
		   print "IP: $ip\n";
		   
		}   
		else {
		   foreach (@ips) {
                      my $ipTmp =$_;
                  
                      if ($ipTmp ne '127.0.0.1') {
                         $ip = $ipTmp ;
                         last;
                      }
                   }
		}
		
               print "IP founded: ${ip} \n";
               
		
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


sub getConfFilesFromFilesystems {
   
   #local (%results);
   
   my $ficheroLog = $_[0];
   my $ficheroToLocate = $_[1];
   
   my @arrFiles = ();
   
   my $osname = $^O;

   my @result;	

     
   print "Comando: sudo find / -fstype nfs -type d -prune -o -name '$ficheroToLocate'\n";
   my @subResult=`sudo find / -fstype nfs -type d -prune -o -name '$ficheroToLocate' 2> /dev/null`;
   push(@result, @subResult);

   
  print "Se han encontrado los siguientes ficheros\n";

   my @arrFiles = uniq(@result);

    foreach(@arrFiles)
    {
        print "$_\n";
    }   

   return @arrFiles;

   
}

#Elimina lineas duplicadas del array
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

sub formatoFechaLog {
	
	local($fechaseg) = time;
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

#Reemplaza un substring por otro
sub replace {
      my ($from,$to,$string) = @_;
      $string =~s/$from/$to/ig;                          #case-insensitive/global (all occurrences)

      return $string;
}

#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================


1;

#*===========================================================
#* Fin script: [yavireUnix.pm]
#*===========================================================
