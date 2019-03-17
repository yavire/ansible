#!/usr/bin/perl
#openwebActualizarEstadisticas.pl version 3.1.0.0 

$fich_logs="/opt/openweb/log/openwebActualizarEstadisticas.log";
$fecha=localtime();

open(LOGS,">>$fich_logs") || die "problemas abriendo fichero de log $fich_logs\n";
print LOGS "$fecha: Iniciamos ejecucion de openwebActualizarEstadisticas.pl version 3.1.0.0\n";
my $path="/opt/openweb/stats/awstats/conf";

    opendir(DIR, $path) or die $!; #se abre el directorio
    my @files = grep(!/^\./,readdir(DIR));
    closedir(DIR);
    foreach $file (@files){
        print LOGS "tratando  el fichero: $file\n";
	my @var=split(/\.conf/,$file);
	$instancia=@var[0];

        my @var2=split(/awstats\./,$instancia);
        #print "var2 = @var2, var0 = @var2[0], var1=@var2[1]";
        $instancia=@var2[1];
        print LOGS "valor instancia $instancia\n";


	`/usr/bin/perl /opt/openweb/stats/awstats/awstats.pl -config=$instancia -update -showdropped > sal.txt`;
        
    }
print LOGS "**************************************************************************\n";
close LOGS;
