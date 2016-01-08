#!/usr/bin/env perl

#########################################################################################
#                                       stepPicard.pl
#########################################################################################
# 
#  This program runs the picard 
#
#########################################################################################
# AUTHORS:
#
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
# 
#########################################################################################

############## LIBRARIES AND PRAGMAS ################

 use List::Util qw[min max];
 use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 
 
#################### VARIABLES ######################
 my $refflat          = "";
 my $outdir           = "";
 my $picardCmd        = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions(
	'outdir=s'        => \$outdir,
        'jobsubmit=s'     => \$jobsubmit,
        'servicename=s'   => \$servicename,
	'help'            => \$help, 
	'version'         => \$print_version,
) or die("Unrecognized optioins.\nFor help, run this script with -help option.\n");

if($help){
    pod2usage( {
		'-verbose' => 2, 
		'-exitval' => 1,
	} );
}

if($print_version){
  print "Version ".$version."\n";
  exit;
}

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($refflat eq "") or ($outdir eq "") or ($picardCmd eq "") );	

################### MAIN PROGRAM ####################
# runs the picard program

my $indir   = "$outdir/after_ribosome/picard";

opendir D, $indir or die "Could not open $indir\n";
my @outs = grep /out$/, readdir(D);
closedir D;

open out, ">$indir/picard_map_stat";

foreach my $d (@outs){ 
 open in,"$indir/$d";
 <in>;<in>;<in>;<in>;<in>;<in>;
 $head=<in>;
 $a{$d}=<in>; 
 close in;
}

print out "Name\t$head";
foreach $key(keys %a)
{
 $_=$key;
 s/pipe.tophat.//;
 s/_1.notR.out//;
 print out "$_\t$a{$key}";
}

close out;