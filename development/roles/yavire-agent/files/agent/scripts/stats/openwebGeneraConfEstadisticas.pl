#!/usr/bin/perl
#openwebGeneraConfEstadisticas.pl version 3.1.0.0 _1

use File::Copy;
use File::Temp qw/ tempfile /;

$fich_logs="/opt/openweb/log/estadisticas/openwebEstadisticas.log";
$fecha=localtime();

open(LOGS,">>$fich_logs") || die "problemas abriendo fichero de log $fich_logs\n";
print LOGS "$fecha: Iniciamos ejecucion de openwebGeneraConfEstadisticas.pl version 3.1.0.0\n";


$entorno = $ARGV[0];
$directorio_origen="/opt/openweb/inventario/data/$entorno";
print LOGS " directorio  origen = $directorio_origen\n";
&open_dir($directorio_origen);
print LOGS "*********************************************************\n";

sub open_dir{
	my ($path) = ($_[0]);
	opendir(DIR, $path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach $file (@files){
		$file = $path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ..
	   	if( -d $file){
			open_dir($file,$hash);
		}else{
	   		print LOGS "Prcesando el fichero: $file\n"
                        &proc_fich($file);
		}		
	}
}

sub proc_fich{
    my ($fich) = ($_[0]);
    open (IN, $fich);
    while($linea = <IN>) { 
	    #chop($linea); #quitamos el salto de linea 
            #print "$linea\n";
            @elementos = split(/%%/, $linea);
            foreach $elemento (@elementos)
		{
     		#print "$elemento\n";
                $val1 = obtener_valor_campo($elemento,"instancia");
			if ($val1 ne "0"){
			$instancia = obtener_valor_campo($elemento,"instancia"); 
			} 

                $val1 = obtener_valor_campo($elemento,"dominio");
                        if ($val1 ne "0"){
			  $dominio = &obtener_valor_campo($elemento,"dominio");
			}
	   
		$val1 = obtener_valor_campo($elemento,"LogAccess");
                        if ($val1 ne "0"){
                          $log = obtener_valor_campo($elemento,"LogAccess");
                        }
		}
                $archivo_conf="/opt/openweb/stats/awstats/conf/awstats.$instancia-$dominio.conf";
                if (-e $archivo_conf) {
			print LOGS "el fichero $archivo_conf ya existe \n";
  		}
		else {
			print (LOGS "tenemos que crear el fichero $archivo_conf\n");
			&crear_fich_conf($archivo_conf,$log,$instancia,$dominio);
		}

    #print $linea;
    }
    close (IN);

}
sub obtener_valor_campo {
    # Entrada elemento de linea
    # nombre del campo
    my ($elto) = ($_[0]);
    my ($campo) = ($_[1]);
    @val = split(/=/, $elto); 
    #print "val 0 = @val[0] y el elto es = $campo\n ";
    if (trim(@val[0]) eq  $campo){
      do
      #print "el valor de @val[0] es ********@val[1] \n";
      return trim(@val[1]);
    }
    else{
      return 0;
    }
}

sub crear_fich_conf{
	my ($fich)=($_[0]);
	my ($log)=($_[1]);
	my ($instancia)=($_[2]);
	my ($dominio)=($_[3]);

  	$plantilla="/opt/openweb/stats/awstats/plantilla-awstats.conf";
	if (-e $plantilla){

  	copy ("$plantilla","$fich");

	open my $in, '<', $fich  or die "Cannot open file for reading: $!\n";

	my ($out, $temp_file_name) = tempfile();

	print $out "LogFile=\"$log\"\n";
	print $out "SiteDomain=\"$instancia.$dominio\"\n";
	my $l;
	print $out $l while defined( $l = <$in> );

	close $in;
	close $out;

	move( $temp_file_name, $fich );
        }
        else{
          print LOGS "no existe la plantilla $plantilla\n";
        }
}

sub trim {
 my $string = shift;
 $string =~ s/^\s+//;
 $string =~ s/\s+$//;
 return $string;
}
