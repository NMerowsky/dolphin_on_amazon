#!/usr/bin/env perl

#########################################################################################
#                                       stepCufflinksCount.pl
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

my $indir   = "$outdir/cufflinks";
$outdir  = "$outdir/cufflinks";

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
my @alndirs = grep /^pipe/, readdir(D);
closedir D;

my @a=();
my %b=();
my %c=();
my $i=0;
foreach my $d (@alndirs){ 
print STDERR "$d\n";
 my $dir = "${indir}/$d";
 $i++;
 $a[$i]=$d;
 open IN,"${dir}/genes.fpkm_tracking";
 $_=<IN>;
 while(<IN>)
 {
  my @v=split; 
  $b{$v[0]}{$i}=$v[9];
  $c{$v[0]}=$v[6];
 }
 close IN;
}

open OUT, ">${indir}/transcript_expression_fpkm";

print OUT "gene\ttranscript\tLocation";
for(my $j=1;$j<=$i;$j++)
{
 print OUT "\t$a[$j]";
}
print OUT "\n";

foreach my $key (keys %b)
{
 print OUT "$nme{$key}\t$key\t$c{$key}";
 for(my $j=1;$j<=$i;$j++)
 {
  print OUT "\t$b{$key}{$j}";
 }
 print OUT "\n";
}

close OUT;

__END__


=head1 NAME

stepCufflinksCount.pl

=head1 SYNOPSIS  

stepCufflinksCount.pl 
            -o outdir <output directory> 
            -c conversion <ucsc conversion file> 


stepCufflinksCount.pl -help

stepCufflinksCount.pl -version

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

stepCufflinksCount.pl 
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

