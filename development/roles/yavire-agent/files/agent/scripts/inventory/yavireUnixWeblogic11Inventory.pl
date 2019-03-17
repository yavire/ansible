#!/usr/bin/perl

# use module
#use XML::Simple;
#
use lib  '/opt/krb/yavire/agent/perl/lib';
use Data::Dumper;
use Socket;

use XML::Parser;

# use lib  'C:\\krb\\yavire\\agent\\scripts';

# require yavire21;

require yavireUnix;

use lib  '/opt/krb/yavire/agent/scripts';

#* NombreFichero: yavireUnixWeblogic11Inventory.pl
#*=========================================================
#* Fecha Creación: [29/11/2015] - 2.2.0.2_1
#* Autor: Fernando Oliveros
#* Compañia: Kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripción:
#*    Genera el inventario diario de Weblogic 11 para Unix
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


sub process_getWeblogicVersion {
  
   my ($type, $content) = @_;
   
   my $ind = ' ' x $level;
   
   if ($type) {
     
       my $attrs = shift @$content;
       # print LOG "Type: $type\n"; 
             
       if ($type eq 'domain-version') {
              
         print LOG "Encontrada la version \n";
         $subversionWeblogic = @$content[1];
         $bEncontradoVersion = 1;
       }

       ++$level;
       while (my @node = splice(@$content, 0, 2)) {
           process_getWeblogicVersion(@node);
       }
     --$level;
   } else {
       $content =~ s/\n/ /;
       $content =~ s/^\s+//;
       $content =~ s/\s+$//;
       # print LOG $ind, $content, "\n";
     
   }
}

sub process_getAdminInstanceName {
  
   my ($type, $content) = @_;
   
   my $ind = ' ' x $level;
   
   if ($type) {
     
       my $attrs = shift @$content;
       # print LOG "Type: $type\n"; 
             
       if ($type eq 'admin-server-name') {
              
         print LOG "Encontrada la version \n";
         $adminInstanceName = @$content[1];
         $bEncontradoAdminInstance = 1;
       }

       ++$level;
       while (my @node = splice(@$content, 0, 2)) {
           process_getAdminInstanceName(@node);
       }
     --$level;
   } else {
       $content =~ s/\n/ /;
       $content =~ s/^\s+//;
       $content =~ s/\s+$//;
       # print LOG $ind, $content, "\n";
     
   }
}

sub process_getWeblogicDomainName {
  
   my ($type, $content) = @_;
   
   my $ind = ' ' x $level;
   
   if ($type) {
     my $attrs = shift @$content;
     # print LOG "Type: $type\n"; 
     # print LOG "bEncontradoServer: $bEncontradoServer\n\n";
     
     if ($type eq 'domain') {
            
       print LOG "Encontrado nodo domain \n";
       $bEncontradoDomain = 1;
     }
     
      if ($bEncontradoDomain == 1) {
                
         if ($type eq 'name') {
           
            print LOG "\nHE ENCONTRADO EL NAME  DEL DOMINIO \n\n";
          
            # print LOG "\npaso1.1: @$content[1]\n";
            
            $dominio = @$content[1];
       
            # print LOG "\nPaso1.2:\n\n";
            
                              
             $bEncontradoDomain = 0;
         }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_getWeblogicDomainName(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}


sub process_nodeServers {
  
   my ($type, $content) = @_;
   
   my $ind = ' ' x $level;
   
   if ($type) {
     my $attrs = shift @$content;
     # print LOG "Type: $type\n"; 
     # print LOG "bEncontradoServer: $bEncontradoServer\n\n";
     
     if ($type eq 'server') {
            
       print LOG "Encontrado nodo server \n";
       $bEncontradoServer = 1;
     }
     
      if ($bEncontradoServer == 1) {
                
         if ($type eq 'name') {
           
            print LOG "\nHE ENCONTRADO EL NAME  DEL SERVER \n\n";
          
            
            # print LOG join(", ", @$content); #Contiene <application> , <bindings> y sus arrays..
       
            # print LOG "\npaso1.1: @$content[1]\n";
            
            push @servers, @$content[1];
       
            # print LOG "\nPaso1.2:\n\n";
            
                              
             $bEncontradoServer = 0;
         }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeServers(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeMachines {
  
   # <machine>
    # <name>yavire1</name>
    # <node-manager>
      # <name>yavire1</name>
      # <nm-type>Plain</nm-type>
      # <listen-address>pvyavap01</listen-address>
      # <listen-port>5556</listen-port>
      # <debug-enabled>false</debug-enabled>
    # </node-manager>
  # </machine>
  
   my ($type, $content) = @_;
   
   my $ind = ' ' x $level;
   
   if ($type) {
     my $attrs = shift @$content;
     # print LOG "Type: $type\n"; 
     # print LOG "bEncontradoServer: $bEncontradoServer\n\n";
     
     if ($type eq 'machine') {
       
       #Si tiene un valor, descartamos como nodo machine, pertenece a un nodo server
       $machineName = @$content[1];
       #Eliminamos blancos
       $machineName =~ s/^\s+|\s+$//g;
       $len = length($machineName);
       
       # print LOG "\npasoA.A: $len\n";
       
       if ( $machineName eq "") {
          $bEncontradoMachine = 1;  
          print LOG "Encontrado nodo machine \n";
          
       }
       
     }
     
       if ($bEncontradoMachine == 1) {
                
          if ($type eq 'name') {
           
             print LOG "HE ENCONTRADO EL NAME  DE LA MACHINE \n";
            
             #print LOG join(", ", @$content); #Contiene <application> , <bindings> y sus arrays..
       
             print LOG "PASO A.3: @$content[1]\nºn";
            
             push @machines, @$content[1];
       
             #print LOG "\nPaso1.2:\n\n";
                              
              $bEncontradoMachine = 0;
          }
         
       }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeMachines(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeGetMachineIP {
   
  # <machine>
    # <name>yavire1</name>
    # <node-manager>
      # <name>yavire1</name>
      # <nm-type>Plain</nm-type>
      # <listen-address>pvyavap01</listen-address>
      # <listen-port>5556</listen-port>
      # <debug-enabled>false</debug-enabled>
    # </node-manager>
  # </machine>
   
   my ($type, $content) = @_;
   my $ind = ' ' x $level;
  
   if ($type) {
     my $attrs = shift @$content;
     
     if ($type eq 'machine') {
         print LOG "\nHE ENCONTRADO UNA MACHINE \n\n";
         $bEncontradaMachine = 1;
         if ($bEncontradaMachineBuena == 1) {
            $bEncontradaMachineBuena = 0;
         }
     }
     
     if ($bEncontradaMachine == 1) {
       
       if ($type eq 'name') {
          if ($machine eq @$content[1]) {
            print LOG "\nHE ENCONTRADO LA MACHINE $machine BUENA: @$content[1] \n\n";
            $bEncontradaMachineBuena = 1;
          }
       }
       
       if ($bEncontradaMachineBuena == 1) {
           print LOG "\nBUSCAMOS EL LISTEN-ADDRESS DE LA MACHINE $machine \n\n";
           # Ahora buscamos el listen-port
           if ($type eq 'listen-address') {
              
              if  (@$content[1] eq  "") {
                print LOG "\nHE ENCONTRADO EL LISTEN-ADDRESS DE LA MACHINE VACIO $machine : @$content[1] \n\n";
                push @ipMachines, $ip_server;
              }
              else {
                print LOG "\nHE ENCONTRADO EL LISTEN-ADDRESS DE LA MACHINE $machine : @$content[1] \n\n";
                push @ipMachines, @$content[1];
              }
            
              
            
              $bEncontradaIP = 1;
              $bEncontradaMachineBuena = 0;
           }
        }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeGetMachineIP(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeGetServerPort {
   
   # <server>
    # <name>new_ManagedServer_1</name>
    # <machine>new_Machine_1</machine>
    # <listen-port>7003</listen-port>
    # <cluster>new_Cluster_1</cluster>
    # <listen-address></listen-address>
    # <jta-migratable-target>
    #   <name>new_ManagedServer_1</name>
      # <user-preferred-server>new_ManagedServer_1</user-preferred-server>
      # <cluster>new_Cluster_1</cluster>
    # </jta-migratable-target>
  # </server>
   
   my ($type, $content) = @_;
   my $ind = ' ' x $level;
  
   # print LOG "process_nodeGetServerPort ($type, $content)\n\n";
   # print LOG "ENCONTRADOSERVERBUENO: ($bEncontradoServerBueno)\n\n";

   if ($type) {
     my $attrs = shift @$content;
     
     if ($type eq 'server') {
         print LOG "\nHE ENCONTRADO UN SERVER1 \n\n";
         $bEncontradoServer = 1;
         if ($bEncontradoServerBueno == 1) {
            $bEncontradoServerBueno = 0;
         }
     }
     
     if ($bEncontradoServer == 1) {
       
       if ($type eq 'name') {
          if ($server eq @$content[1]) {
            print LOG "\nHE ENCONTRADO EL SERVER $server BUENO: @$content[1] \n\n";
            $bEncontradoServerBueno = 1;
          }
       }
       
       if ($bEncontradoServerBueno == 1) {
           print LOG "\nBUSCAMOS EL LISTEN-PORT DEL SERVER $server \n\n";
           # Ahora buscamos el listen-port
           if ($type eq 'listen-port') {
                     
              print LOG "\nHE ENCONTRADO EL LISTEN-PORT DEL SERVER $server : @$content[1] \n\n";
            
              push @portsServers, @$content[1];
            
              $bEncontradoPuerto = 1;
              $bEncontradoServerBueno = 0;
           }
        }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeGetServerPort(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeGetInstanceIP {
   
   # <server>
    # <name>new_ManagedServer_1</name>
    # <machine>new_Machine_1</machine>
    # <listen-port>7003</listen-port>
    # <cluster>new_Cluster_1</cluster>
    # <listen-address></listen-address>
    # <jta-migratable-target>
    #   <name>new_ManagedServer_1</name>
      # <user-preferred-server>new_ManagedServer_1</user-preferred-server>
      # <cluster>new_Cluster_1</cluster>
    # </jta-migratable-target>
  # </server>
   
   my ($type, $content) = @_;
   my $ind = ' ' x $level;
  
   # print LOG "process_nodeGetInstanceIP ($type, $content)\n\n";
   # print LOG "ENCONTRADOSERVERBUENO: ($bEncontradoServerBueno)\n\n";

   if ($type) {
     my $attrs = shift @$content;
     
     if ($type eq 'server') {
         print LOG "\nHE ENCONTRADO UN SERVER1 \n\n";
         $bEncontradoServer = 1;
         if ($bEncontradoServerBueno == 1) {
            $bEncontradoServerBueno = 0;
         }
     }
     
     if ($bEncontradoServer == 1) {
       
       if ($type eq 'name') {
          if ($server eq @$content[1]) {
            print LOG "\nHE ENCONTRADO EL SERVER $server BUENO: @$content[1] \n\n";
            $bEncontradoServerBueno = 1;
          }
       }
       
       if ($bEncontradoServerBueno == 1) {
           print LOG "\nBUSCAMOS EL LISTEN-ADDRESS DEL SERVER $server \n\n";
           # Ahora buscamos el listen-port
           if ($type eq 'listen-address') {
                     
              
              
              if  (@$content[1] eq  "") {
                print LOG "\nHE ENCONTRADO EL LISTEN-ADDRESS DEL SERVER  VACIO $server : @$content[1] \n\n";
                push @ipServers, $ip_server;
              }
              else {
                print LOG "\nHE ENCONTRADO EL LISTEN-ADDRESS DEL SERVER $server : @$content[1] \n\n";
                push @ipServers, @$content[1];
              }
            
              
            
              $bEncontradaIP = 1;
              $bEncontradoServerBueno = 0;
           }
        }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeGetInstanceIP(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}


sub process_nodeGetInstanceCluster {
   
   # <server>
    # <name>new_ManagedServer_1</name>
    # <machine>new_Machine_1</machine>
    # <listen-port>7003</listen-port>
    # <cluster>new_Cluster_1</cluster>
    # <listen-address></listen-address>
    # <jta-migratable-target>
    #   <name>new_ManagedServer_1</name>
      # <user-preferred-server>new_ManagedServer_1</user-preferred-server>
      # <cluster>new_Cluster_1</cluster>
    # </jta-migratable-target>
  # </server>
   
   my ($type, $content) = @_;
   my $ind = ' ' x $level;
  
   # print LOG "process_nodeGetInstanceIP ($type, $content)\n\n";
   # print LOG "ENCONTRADOSERVERBUENO: ($bEncontradoServerBueno)\n\n";

   if ($type) {
     my $attrs = shift @$content;
     
     if ($type eq 'server') {
         print LOG "\nHE ENCONTRADO UN SERVER1 \n\n";
         $bEncontradoServer = 1;
         if ($bEncontradoServerBueno == 1) {
            $bEncontradoServerBueno = 0;
         }
     }
     
     if ($bEncontradoServer == 1) {
       
       if ($type eq 'name') {
          if ($server eq @$content[1]) {
            print LOG "\nHE ENCONTRADO EL SERVER $server BUENO: @$content[1] \n\n";
            $bEncontradoServerBueno = 1;
          }
       }
       
       if ($bEncontradoServerBueno == 1) {
           print LOG "\nBUSCAMOS EL CLUSTER DEL SERVER $server \n\n";
           # Ahora buscamos el listen-port
           if ($type eq 'cluster') {
                     
              
              
              if  (@$content[1]  eq "") {
                print LOG "\nHE ENCONTRADO EL CLUSTER DEL SERVER  VACIO $server : @$content[1] \n\n";
                push @clusterServers, "-";
              }
              else {
                print LOG "\nHE ENCONTRADO EL CLUSTER DEL SERVER $server : @$content[1] \n\n";
                push @clusterServers, @$content[1];
              }
            
              
            
              $bEncontradoCluster = 1;
              $bEncontradoServerBueno = 0;
           }
        }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeGetInstanceCluster(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeGetInstanceMachine {
   
   # <server>
    # <name>new_ManagedServer_1</name>
    # <machine>new_Machine_1</machine>
    # <listen-port>7003</listen-port>
    # <cluster>new_Cluster_1</cluster>
    # <listen-address></listen-address>
    # <jta-migratable-target>
    #   <name>new_ManagedServer_1</name>
      # <user-preferred-server>new_ManagedServer_1</user-preferred-server>
      # <cluster>new_Cluster_1</cluster>
    # </jta-migratable-target>
  # </server>
   
   print LOG "\nCOMENZAMOS LA BUSQUEDA DE LAS MACHINE \n\n";
   
   my ($type, $content) = @_;
   my $ind = ' ' x $level;
  
   # print LOG "process_nodeGetInstanceIP ($type, $content)\n\n";
   # print LOG "ENCONTRADOSERVERBUENO: ($bEncontradoServerBueno)\n\n";

   if ($type) {
     my $attrs = shift @$content;
     
     if ($type eq 'server') {
         print LOG "\nHE ENCONTRADO UN SERVER1 \n\n";
         $bEncontradoServer = 1;
         if ($bEncontradoServerBueno == 1) {
            $bEncontradoServerBueno = 0;
         }
     }
     
     if ($bEncontradoServer == 1) {
       
       if ($type eq 'name') {
          if ($server eq @$content[1]) {
            print LOG "\nHE ENCONTRADO EL SERVER $server BUENO: @$content[1] \n\n";
            $bEncontradoServerBueno = 1;
          }
       }
       
       if ($bEncontradoServerBueno == 1) {
           print LOG "\nBUSCAMOS EL PARAMETRO MACHINE DEL SERVER $server \n\n";
           # Ahora buscamos el listen-port
           if ($type eq 'machine') {
              
              if  (@$content[1]  eq "") {
                print LOG "\nHE ENCONTRADO EL PARAMETRO MACHINE DEL SERVER  VACIO $server : @$content[1] \n\n";
                push @machineServers, "-";
              }
              else {
                print LOG "\nHE ENCONTRADO EL PARAMETRO MACHINE DEL SERVER $server : @$content[1] \n\n";
                push @machineServers, @$content[1];
              }
            
              $bEncontradoMachine = 1;
              $bEncontradoServerBueno = 0;
           }
        }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeGetInstanceMachine(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeGetMachine {
   
   # <server>
    # <name>new_ManagedServer_1</name>
    # <machine>new_Machine_1</machine>
    # <listen-port>7003</listen-port>
    # <cluster>new_Cluster_1</cluster>
    # <listen-address></listen-address>
    # <jta-migratable-target>
    #   <name>new_ManagedServer_1</name>
      # <user-preferred-server>new_ManagedServer_1</user-preferred-server>
      # <cluster>new_Cluster_1</cluster>
    # </jta-migratable-target>
  # </server>
  
   # <machine>
    # <name>yavire1</name>
    # <node-manager>
      # <name>yavire1</name>
      # <nm-type>Plain</nm-type>
      # <listen-address>pvyavap01</listen-address>
      # <listen-port>5556</listen-port>
      # <debug-enabled>false</debug-enabled>
    # </node-manager>
  # </machine>
   
   print LOG "\nCOMENZAMOS LA BUSQUEDA DE LAS MACHINES  \n\n";
   
   my ($type, $content) = @_;
   my $ind = ' ' x $level;
  
   # print LOG "process_nodeGetInstanceIP ($type, $content)\n\n";
   # print LOG "ENCONTRADOSERVERBUENO: ($bEncontradoServerBueno)\n\n";

   if ($type) {
     my $attrs = shift @$content;
     
     if ($type eq 'server') {
         print LOG "\nHE ENCONTRADO UN SERVER1 \n\n";
         $bEncontradoServer = 1;
         if ($bEncontradoServerBueno == 1) {
            $bEncontradoServerBueno = 0;
         }
     }
     
     if ($bEncontradoServer == 1) {
       
       if ($type eq 'name') {
          if ($server eq @$content[1]) {
            print LOG "\nHE ENCONTRADO EL SERVER $server BUENO: @$content[1] \n\n";
            $bEncontradoServerBueno = 1;
          }
       }
       
       if ($bEncontradoServerBueno == 1) {
           print LOG "\nBUSCAMOS EL PARAMETRO MACHINE DEL SERVER $server \n\n";
           # Ahora buscamos el listen-port
           if ($type eq 'machine') {
              
              if  (@$content[1]  eq "") {
                print LOG "\nHE ENCONTRADO EL PARAMETRO MACHINE DEL SERVER  VACIO $server : @$content[1] \n\n";
                push @machineServers, "-";
              }
              else {
                print LOG "\nHE ENCONTRADO EL PARAMETRO MACHINE DEL SERVER $server : @$content[1] \n\n";
                push @machineServers, @$content[1];
              }
            
              
            
              $bEncontradoMachine = 1;
              $bEncontradoServerBueno = 0;
           }
        }
         
      }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeGetMachine(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     # print LOG $ind, $content, "\n";
     
   }
}

sub process_nodeGENERICO {
   my ($type, $content) = @_;
   
   my $ind = ' ' x $level;
   
  
   #print LOG "process_Node ($type, $content)\n\n";

   if ($type) {
     my $attrs = shift @$content;

     # if ($type eq 'sites') {
       # print LOG "HE ENCONTRADO LA SECCION QUE QUIERO ($type, $content)\n";
     
     # }
     
     # print LOG $ind, $type, ' [';
     # print LOG join(', ', map { "$_: $attrs->{$_}" } keys %{$attrs});
     # print LOG "]\n";
     
     
     if ($type eq 'site') {
       # print LOG "\nHE ENCONTRADO EL SITE QUE QUIERO ($type, $attrs)\n\n";
       
     
       
       # print LOG "\nHola1\n";
            
       # #Contiene name, id <site name="Default Web Site" id="1">
       # while( my( $key, $value ) = each $attrs ){
          # print LOG "$key: $value\n";
          # # if  ($key eq 'name') {
             # # push @sites, $value;
          # # }
          
       # }
       
       # print LOG "\nHola2\n";
       
       # print LOG join(", ", @$content); #Contiene <application> , <bindings> y sus arrays..
       
       # print LOG "paso1.1: @$content[2]\n";
       
       # print LOG "Paso1.2:\n\n";
       
       # foreach (@$content[3]) {
          # print LOG "$_\n";
          
          # print LOG "(I)=======\n";
          # foreach (@$_) {
             # print LOG "$_\n";
          # }
          # print LOG "(F)=======\n";
          
       # }
            
       # print LOG  "\nHola2\n\n";
     
     }

     ++$level;
     while (my @node = splice(@$content, 0, 2)) {
       process_nodeServers(@node);
     }
     --$level;
   } else {
     $content =~ s/\n/ /;
     $content =~ s/^\s+//;
     $content =~ s/\s+$//;
     print LOG $ind, $content, "\n";
     
   }
}


sub leerXml {
	local($xmlfile) = $_[0];
	
        print LOG "Fichero a parsear v1.0: ($xmlfile)\n";
        
       
        # initialize parser object and parse the string
       my $parser = XML::Parser->new( ErrorContext => 2 );
       eval { $parser->parsefile( $xmlfile ); };
 
       # report any error that stopped parsing, or announce success
       if( $@ ) {
          $@ =~ s/at \/.*?$//s;               # remove module line number
          print LOG "\nERROR in '$xmlfile':\n$@\n";
       } else {
          print LOG "'$xmlfile' is well-formed\n";
       }
       
       
       print LOG "=====================================================\n";    
       
         $bEncontradoAdminInstance = 0;
         
        $parser = new XML::Parser( Style => 'Tree' );
        
        my $tree = $parser->parsefile(  $xmlfile );
        $level = 0;
        process_getAdminInstanceName(@$tree);
        if ($bEncontradoAdminInstance == 0) {
          print LOG "NO HEMOS ENCONTRADO EL NOMBRE DE INSTANCIA DE ADMINISTRACION\n\n\n\n";
          $adminInstanceName="-";;
        }
        else {
            
             print LOG "HEMOS ENCONTRADO EL NOMBRE DE INSTANCIA DE ADMINISTRACION: $adminInstanceName \n\n";
          }
      
        print LOG "=====================================================\n";  
       
      
       $parser = new XML::Parser( Style => 'Tree' );
       my $tree = $parser->parsefile(  $xmlfile );
       my $level = 0;
       process_nodeServers(@$tree);
       
       $i= 0;
       foreach (@servers) {
          print LOG "$_\n";
          $parser = new XML::Parser( Style => 'Tree' );
          my $tree = $parser->parsefile(  $xmlfile );
          $level = 0;          
          $server = $_;
          print LOG "SERVER A TRATAR: $server\n";
          $bEncontradoPuerto = 0;
          $bEncontradoServerBueno = 0;
          process_nodeGetServerPort(@$tree);
          
          if ($bEncontradoPuerto == 0) {
           print LOG "NO HEMOS ENCONTRADO PUERTO\n\n\n\n";
           push @portsServers, "7001";
          }
          else {
            
             print LOG "HEMOS ENCONTRADO PUERTO\n\n";
          }
          
          $i++;
       }
      
      print LOG "=====================================================\n";
      
       $i= 0;
       foreach (@servers) {
          print LOG "$_\n";
          $parser = new XML::Parser( Style => 'Tree' );
          my $tree = $parser->parsefile(  $xmlfile );
          $level = 0;          
          $server = $_;
          print LOG "SERVER A TRATAR: $server\n";
          
          $bEncontradaIP = 0;
          $bEncontradoServerBueno = 0;
          
          process_nodeGetInstanceIP(@$tree);
          
          if ($bEncontradaIP == 0) {
           print LOG "NO HEMOS ENCONTRADO LA IP\n\n\n\n";
           push @ipServers, $ip_server;
          }
          else {
            
             print LOG "HEMOS ENCONTRADO LA IP.\n\n\n\n";
          }
                 
          $i++;
       }
       
       print LOG "=====================================================\n";
       
        $i= 0;
       foreach (@servers) {
          print LOG "$_\n";
          $parser = new XML::Parser( Style => 'Tree' );
          my $tree = $parser->parsefile(  $xmlfile );
          $level = 0;          
          $server = $_;
          print LOG "SERVER A TRATAR: $server\n";
          
          $bEncontradoMachine = 0;
          $bEncontradoServerBueno = 0;
          
          process_nodeGetInstanceMachine(@$tree);
          
          if ($bEncontradoMachine == 0) {
           print LOG "NO HEMOS ENCONTRADO EL PARAMETRO MACHINE\n\n\n\n";
           push @machineServers, "-";
          }
          else {
            
             print LOG "HEMOS ENCONTRADO EL PARAMETRO MACHINE\n\n\n\n";
          }
                 
          $i++;
       }
       
       print LOG "=====================================================\n";
       
        $i= 0;
       foreach (@servers) {
          print LOG "$_\n";
          $parser = new XML::Parser( Style => 'Tree' );
          my $tree = $parser->parsefile(  $xmlfile );
          $level = 0;          
          $server = $_;
          print LOG "SERVER A TRATAR: $server\n";
          
          $bEncontradoCluster = 0;
          $bEncontradoServerBueno = 0;
          
          process_nodeGetInstanceCluster(@$tree);
          
          if ($bEncontradoCluster == 0) {
           print LOG "NO HEMOS ENCONTRADO EL CLUSTER\n\n\n\n";
           push @clusterServers, "-";
          }
          else {
            
             print LOG "HEMOS ENCONTRADO EL CLUSTER\n\n\n\n";
          }
                 
          $i++;
       }
           
        print LOG "=====================================================\n";    
                
        $parser = new XML::Parser( Style => 'Tree' );
        my $tree = $parser->parsefile(  $xmlfile );
        $level = 0;
        process_getWeblogicVersion(@$tree);
        if ($bEncontradoVersion == 0) {
          print LOG "NO HEMOS ENCONTRADO LA VERSION\n\n\n\n";
          $subversionWeblogic="11.1";;
        }
        else {
             print LOG "HEMOS ENCONTRADO LA VERSION \n\n\n\n";
        }
      
        print LOG "=====================================================\n";  
      
     
        $parser = new XML::Parser( Style => 'Tree' );
        my $tree = $parser->parsefile(  $xmlfile );
        $level = 0;
        process_getWeblogicDomainName(@$tree);
        
        print LOG "=====================================================\n";  
        print LOG "FINDING MACHINES \n";
        print LOG "=====================================================\n";  
        
        $parser = new XML::Parser( Style => 'Tree' );
        my $tree = $parser->parsefile(  $xmlfile );
        $level = 0;
        $bEncontradoMachine = 0;
        process_nodeMachines(@$tree);
        
        foreach (@machines) {
          print LOG "$_\n";
          $parser = new XML::Parser( Style => 'Tree' );
          my $tree = $parser->parsefile(  $xmlfile );
          $level = 0;          
          $machine = $_;
          print LOG "MACHINE A TRATAR: ($machine)\n";
          
          $bEncontradaIP = 0;
          $bEncontradaMachineBuena = 0;
          
          #Rellenamos la lista de listen-address de las machines
          process_nodeGetMachineIP(@$tree);
          
          if ($bEncontradaIP == 0) {
           print LOG "NO HEMOS ENCONTRADO LA IP\n\n\n\n";
           push @ipMachines, $ip_machine;
          }
          else {
            
             print LOG "HEMOS ENCONTRADO LA IP.\n\n\n\n";
          }
                
          $i++;
       }
       
       
       foreach (@ipMachines) {
          print LOG "IMPRIMIMOS LISTEN-ADDRESS DE MACHINE: $_\n";
          $name = $_;
          
          $address = inet_ntoa(inet_aton($name));
         
          print LOG "IP ADDRESS: $address\n";
          
       }
	
}



#*===========================================================
#* Fin de declaración de funciones
#*===========================================================

   
#*===========================================================
#* Definición de variables
#*===========================================================

$versionYAV = '2.2.0.2';
$ficheroInventarioSemanal="yavireWeblogic8.1_0to11.0_FileInventory.txt";
$ficheroInventarioDiario="yavireInv_weblogic11.data";

$vendor="Oracle Corporation";
$producto="weblogic";
$subversionWeblogic="11.1";
$puerto="80";
$memoria_min="64";
$memoria_max="64";
$maxThreads="150";
$cluster="-";
$dominio="-";
$instancia="";
$TipoInstancia="SOFTWARE";
$subTipoInstancia="APPSERVER";
$LogAccess="-";
# $ruta_a_localizar='/config/server.xml';
$fichero_a_localizar='config.xml';

$baseAgentDirWin="C:\\krb\\yavire\\agent";
$baseAgentDirUnix="/opt/krb/yavire/agent";

@servers = ();
@portsServers = ();
@ipServers = ();
@clusterServers = ();

@machineServers = ();
@machines = ();
@ipMachines = ();


#$site = "";

$bEncontradoServer = 0;
$bEncontradoPuerto = 1;

#*===========================================================
#* Cuerpo del programa 
#*===========================================================


print "Ejecutando programa yavireUnixWeblogic11Inventory.pl\n";

# Si es una máquina windows.
# $^O : devuelve el sistema operativo
if ($^O =~ /Win/) {
    $szFichLog="$baseAgentDirWin\\log\\inventory\\yavireWinWeblogic11Inventory.log"; 
}
else {
   $szFichLog="$baseAgentDirUnix/log/inventory/yavireUnixWeblogic11Inventory.log"; 
  
}
 
open(LOG,">$szFichLog") || die "problemas abriendo log  $szFicheroLog\n";

$fecha=yavireUnix::formatoFechaLog();
print LOG "$fecha: Iniciando programa yavireUnixWeblogic11Inventory.pl $versionYAV\n";
 
if ($^O =~ /Win/) {
	
    ($system_name, $os_name, $os_version) = yavire21::getDatosWindows();
    ( $system_name, $system_type, $system_manufacturer, $system_model, $NumberOfProcessors, $DNSHostName) = yavire21::getHardwareData();
    
    ($uuid) = yavire21::getComputerSystemUUID();
    
    ($ip_server) = yavire21::getIPServer();
        
    $dirFichDataSemanal="$baseAgentDirWin\\inventory\\weekly\\"; 
    $rutaFicheroInventarioSemanal="$dirFichDataSemanal$ficheroInventarioSemanal"; 
    if (-d $dirFichDataSemanal) {
       print LOG "El directorio $dirFichDataSemanal existe\n";
    } 
    else {
       print LOG "Creamos directorio  $dirFichDataSemanal \n";
       print "$dirFichDataSemanal\n";
       system 1, "mkdir $dirFichDataSemanal";
    
   }
   
    $dirFichDataDiario="$baseAgentDirWin\\inventory\\data\\weblogic11\\$uuid\\"; 
    $rutaFicheroInventarioDiario="$dirFichDataDiario$ficheroInventarioDiario"; 
    if (-d $dirFichDataDiario) {
       print LOG "El directorio $dirFichDataDiario existe\n";
    } 
    else {
       print LOG "Creamos directorio  $dirFichDataDiario \n";
       print "$dirFichDataDiario\n";
       system 1, "mkdir $dirFichDataDiario";
       sleep 5;
           
   }
}
else {

   
  ($uuid) = yavireUnix::getServerUUID(); 
  
  print $server_uuid;

  ($system_manufacturer) = yavireUnix::getSystemManufacturer();
 
  ($ip_server) = yavireUnix::getIPServer();
  
  $dirFichDataSemanal="$baseAgentDirUnix/inventory/weekly/"; 
  $rutaFicheroInventarioSemanal="$dirFichDataSemanal$ficheroInventarioSemanal"; 
    if (-d $dirFichDataSemanal) {
       print LOG "El directorio $dirFichDataSemanal existe\n";
    } 
    else {
       print LOG "Creamos directorio  $dirFichDataSemanal \n";
       print "$dirFichDataSemanal\n";
       system 1, "mkdir $dirFichDataSemanal";
    
   }
   
    $dirFichDataDiario="$baseAgentDirUnix/inventory/data/weblogic11/$uuid/"; 
    $rutaFicheroInventarioDiario="$dirFichDataDiario$ficheroInventarioDiario"; 
    if (-d $dirFichDataDiario) {
       print LOG "El directorio $dirFichDataDiario existe\n";
    } 
    else {
       print LOG "Creamos directorio  $dirFichDataDiario \n";
       print "$dirFichDataDiario\n";
       # system 1, "mkdir $dirFichDataDiario";
       `mkdir -p "${dirFichDataDiario}"` unless (-d "${dirFichDataDiario}");
       sleep 5;
           
   }
  

}


#Directory%%Domain%%Version%%Propietario
#=========%%=======%%=======%%=========


open(INVENTARIO_DIARIO,">$rutaFicheroInventarioDiario") || die "problemas abriendo fichero de inventario inst $rutaFicheroInventarioDiario\n";

open(INVENTARIO_SEMANAL,"<$rutaFicheroInventarioSemanal") || die "problemas abriendo fichero de inventario $rutaFicheroInventarioSemanal\n";



#Ejemplo de la salida del fichero de inventario diario

#versionYAV= 3.4.0.0_1 %% TipoInstancia= WEB %% maquina= dnrbd1 %% producto= IIS %% version= 7.5 %% instancia= Default %% ip= 10.98.69.150 %% puerto= 7020 %%
#memoriaMin= 64  %% memoriaMax= 64  %% maxThreads= 150 %% ssl= NO %% snmp= - %% acronimo= -  %% dominio= - %% cluster= - %% deploy= Si %% propietario= yavire %%
#LogAccess= C:\windows... %% directorioBase= C:\windows... %%


print LOG "Leyendo fichero: $rutaFicheroInventarioSemanal\n";


#Comenzamos a leer el fichero de inventario semanal
while (<INVENTARIO_SEMANAL>) {	
	$linea=$_;
	print LOG "Leyendo linea: ($linea)\n\n";
      
	@linea_troceada = split(/%%/, $linea);
	$directorio="$linea_troceada[0]";
	
	#No utilizamos el dominio del inventario semanal, lo dejamos como UNDEFINED, el núcleo de yavire le pondrá el dominio dependiendo de la máquina.
	#$dominio="$linea_troceada[1]";
	$nombreinstancia2="$linea_troceada[1]";
	$nombreinstancia2=lc($nombreinstancia2);
	
	$esta_version="$linea_troceada[2]";
	$propietario="$linea_troceada[3]";
	chomp $propietario;
	
	
	print LOG "propietario=(${propietario})\n";
	print LOG "fichero_a_localizar=(${fichero_a_localizar})\n";
	print LOG "directorio=($directorio)\n";
	print LOG "version=($esta_version)\n";
	print LOG "nombre instancia=($nombreinstancia2)\n";
	
	
	
	next if ($esta_version !~ /11\./);
	
	print LOG "Es una instalacion de weblogic 11\n";
	
	$fecha=yavireUnix::formatoFechaLog();
	
	my $xmlfile = "";
	
	if ($^O =~ /Win/) {
          $xmlfile = "$directorio\\config\\$fichero_a_localizar\n";
        }
        else {
          $xmlfile = "$directorio//config//$fichero_a_localizar\n";
        }
        
        leerXml($xmlfile);
        
        foreach (@machines) {
          
           $name = $_;
           print "MACHINE: ($name)\n";
         
        }
        
        #Ya obtenido el listado de Machines del fichero de configuración, analizamos en cual machine estamos
        $i= 0; 
        foreach (@ipMachines) {
          
           $name = $_;
           $address = inet_ntoa(inet_aton($name));
          
           #Comparamos las IP´s 
           print "IP SERVER: ($ip_server)\n";
           print "IP WEBLOGIC MACHINE: ($address)\n";
           
           if (${address} eq ${ip_server}) {
             
             $machineWeblogic = $machines[$i];
             print "ESTAMOS EN MACHINE: $machineWeblogic\n";
             print "I: $i\n";
           }
           else{
             
             print "SON IPS DIFERENTES\n";
             
           }
           $i++;
         
        }
                   
        $fecha=yavireUnix::formatoFechaLog();
        
        $i= 0;
        
        foreach (@servers) {
           
           $instancia = $servers[$i];
           $instancePort = $portsServers[$i];
           $ip_address = $ipServers[$i];
           $cluster = $clusterServers[$i];
           $machine = $machineServers[$i];
          
           print "INSTANCIA: $instancia\n";
           
           if ($instancia eq $adminInstanceName) {
                $isAdmin = 1;
           }
           else {
                $isAdmin = 0;
           }
          
          
            #Añadimos la instancia si estamos en la machine de la misma
           if ($machineWeblogic eq $machine) {
              print INVENTARIO_DIARIO "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${uuid} \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${subversionWeblogic} \%\% instanceDomain= ${dominio} \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% instancePort= ${instancePort} \%\% isAdminInstance= ${isAdmin} \%\% memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\% machineInstance= ${machine} \%\% propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";
           }              
           else {
             print LOG "NO SE AÑADE, NO ES LA MACHINE DE LA INSTANCIA\n";
             print LOG "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${uuid} \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${subversionWeblogic} \%\% instanceDomain= ${dominio} \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% instancePort= ${instancePort} \%\% isAdminInstance= ${isAdmin} \%\% memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\% machineInstance= ${machine} \%\% propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";
           }
           
           # print INVENTARIO_DIARIO "versionYAV= ${versionYAV} \%\% instanceType= ${TipoInstancia} \%\% instanceSubType= ${subTipoInstancia} \%\% serverUUID= ${uuid} \%\% productVendor= ${vendor} \%\% productName= ${producto} \%\% productVers= ${subversionWeblogic} \%\% instanceDomain= ${dominio} \%\% instanceName= ${instancia} \%\% instanceIP= ${ip_address} \%\% instancePort= ${instancePort} \%\% isAdminInstance= ${isAdmin} \%\% memoryMin= ${memoria_min} \%\% memoryMax= ${memoria_max} \%\% maxThreads= ${maxThreads} \%\% clusterInstance= ${cluster} \%\% propietary= ${propietario} \%\% LogAccess=${LogAccess} \%\% instanceDir= $directorio \%\%\n";

           
           $i++;
        }     
	
	

}#while

$fecha=yavireUnix::formatoFechaLog();
print LOG "$fecha: Finalizando programa yavireUnixWeblogic11Inventory.pl $versionYAV\n";

close LOG;
close INVENTARIO_SEMANAL;
close INVENTARIO_DIARIO;


#*===========================================================
#* Fin script: yavireUnixWeblogic11Inventory.pl]
#*===========================================================

