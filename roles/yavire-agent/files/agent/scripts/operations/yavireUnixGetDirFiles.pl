#!/usr/bin/perl

#* NombreFichero: yavireUnixGetDirFiles.pl
#*=========================================================
#* Fecha Creaci�n: [05/02/2014]
#* Autor: Fernando Oliveros
#* Compa�ia: kronodata
#* Email: 
#* Web: 
#*=============================================
#* Descripci�n:
#*    Devuelve el listado de ficheros de un directorio
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

#*===========================================================
#* Fin de declaraci�n de funciones
#*===========================================================

   
#*===========================================================
#* Definici�n de variables
#*===========================================================

$versionOW = '2.1.0.2_14';

#Se a�ade dos puntos al parametro
$parDirectorio="$ARGV[0]";
$parametrosLS="$ARGV[1]";

#*===========================================================
#* Cuerpo del programa 
#*===========================================================

chdir("$parDirectorio") or die "yavError: Can't find $parDirectorio: $!\n";;

# my @commands = ( "sleep 5 && echo step 1 done",
                 # "sleep 3 && echo step 2 done",
                 # "sleep 7 && echo step 3 done" );
                 
my @commands = ( "${parametrosLS}");


my @pids;
foreach my $cmd( @commands ) {
    my $pid = fork;
    if ( $pid ) {
        # parent process
        push @pids, $pid;
        next;
    }

    # now we're in the child
     @files = `${cmd}`;

     if( scalar(@$files) == 0) {
       # Intentamos de nuevo, si no hay datos
       @files = `${cmd}`;
     }

     foreach (@files) {
        print "$_|\n";
     }
     #system( $cmd );
     exit;            # terminate the child
}

wait for @pids;   # wait for each child to terminate

  

#*===========================================================
#* Fin script: yavireUnixGetDirFiles.pl]
#*===========================================================


