#!/usr/bin/env perl

#########################################################################################
#                                       stepCuffdiffCount.pl
#########################################################################################
# 
#  This program runs the Cuffdiff after cufflinks
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
 my $conversion       = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions(
	'outdir=s'        => \$outdir,
        'conversion=s'    => \$conversion,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($conversion eq "") or ($outdir eq "") );	

 
################### MAIN PROGRAM ####################++
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory

my $indir   = "$outdir/cuffdiff";
$outdir  = "$outdir/cuffdiff";

mkdir $outdir if (! -e $outdir);

my %nme = ();
open IN,"$conversion";
while(<IN>)
{
 my @v=split;
 $nme{$v[0]}=$v[1];
}
close(IN);

opendir D, $indir or die "Could not open $indir\n";
my @alndirs = grep /output$/, readdir(D);
closedir D;
my $i=0;

foreach my $d (@alndirs){ 
print STDERR "$d\n";
 my $dir = "${indir}/$d";
 $i++;

 open IN,"${dir}/gene_exp.diff";
 $d=~s/pipe.cuffdiff/pair/;
 open OUT, ">${indir}/$d.gene_count_difference";
 print OUT "Genes\ttranscripts\tLocus\tValue1\tValue2\tLog2ratio\tpvalue\tqvalue\n";
 $_=<IN>;
 while(<IN>)
 {
  my @v=split; 
  if((abs($v[9])>=1.5)&&($v[12]<=0.01))
  {
   my @v1=split/\,/, $v[2];
   for(my $j=0;$j<=$#v1;$j++)
   {
    print OUT "$nme{$v1[$j]}\,"
   }
   print OUT "\t$v[2]\t$v[3]\t$v[7]\t$v[8]\t$v[9]\t$v[11]\t$v[12]\n";
  }
 }
 close IN;
 close OUT;
}

__END__


=head1 NAME

stepCuffdiffCount.pl

=head1 SYNOPSIS  

stepCuffdiffCount.pl 
            -o outdir <output directory> 
            -c conversion <ucsc conversion file> 


stepCuffdiffCount.pl -help

stepCuffdiffCount.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be stored "$outdir/after_ribosome/cuffdiff" 

=head2 -c conversion <ucsc conversion> 

Tab delimited ucsc id gene name conversion file

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

This program runs the Cuffdiff after cufflinks

=head1 EXAMPLE

stepCuffdiffCount.pl 
            -o outdir <output directory> 
            -c conversion <ucsc conversion file> 

=head1 AUTHORS

 Hennady Shulha, PhD 

 Alper Kucukural, PhD

 
=head1 LICENSE AND COPYING

 This program is free software; you can redistribute it and / or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, a copy is available at
 http://www.gnu.org/licenses/licenses.html

