#!/usr/bin/env perl

#########################################################################################
#                                       stepRSEMCount.pl
#########################################################################################
# 
#  This program runs the Cuffdiff after cufflinks
#
#########################################################################################
# AUTHORS:
#
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
 my $gene_iso         = "genes";
 my $tpm_fpkm         = "tpm";
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
	'gene_iso=s'      => \$gene_iso,
	'tpm_fpkm=s'      => \$tpm_fpkm,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($outdir eq "") );	

if (!($tpm_fpkm  eq "tpm" || $tpm_fpkm eq "fpkm" || $tpm_fpkm eq "expected_count"))
{
    $tpm_fpkm="tpm";
}

my %tf = (
        expected_count => 4,
        tpm => 5,
        fpkm => 6,
    );
 
################### MAIN PROGRAM ####################++
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory

my $indir   = "$outdir/rsem";
$outdir  = "$outdir/rsem";

opendir D, $indir or die "Could not open $indir\n";
my @alndirs = sort { $a cmp $b } grep /^pipe/, readdir(D);

closedir D;

my @a=();
my %b=();
my %c=();
my $i=0;
foreach my $d (@alndirs){ 
 my $dir = "${indir}/$d";
 print $d."\n";
 my $libname=$d;
 $libname=~s/pipe\.rsem\.//;

 $i++;
 $a[$i]=$libname;
 open IN,"${dir}/rsem.out.$libname.$gene_iso.results";
 $_=<IN>;
 while(<IN>)
 {
  my @v=split; 
  $b{$v[0]}{$i}=$v[$tf{$tpm_fpkm}];
  $c{$v[0]}=$v[1];
 }
 close IN;
}

open OUT, ">${indir}/".$gene_iso."_expression_".$tpm_fpkm.".tsv";

print OUT "gene\ttranscript";


for(my $j=1;$j<=$i;$j++)
{
 print OUT "\t$a[$j]";
}
print OUT "\n";

foreach my $key (keys %b)
{
 if ($gene_iso ne "isoforms") {
   print OUT "$key\t$c{$key}";
 }
 else
 {
    print OUT "$c{$key}\t$key";
 }
 for(my $j=1;$j<=$i;$j++)
 {
  print OUT "\t$b{$key}{$j}";
 }
 print OUT "\n";
}

close OUT;

__END__


=head1 NAME

stepRSEMCount.pl

=head1 SYNOPSIS  

stepRSEMCount.pl 
            -o outdir <output directory> 
            -t tpm_fpkm <tpm or fpkm>
	    -g gene_iso <gene or isoform>


stepRSEMCount.pl -help

stepRSEMCount.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be stored "$outdir/rsem" 

=head2 -c conversion <ucsc conversion> 

Tab delimited ucsc id gene name conversion file

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

This program runs the Cuffdiff after cufflinks

=head1 EXAMPLE

stepRSEMCount.pl 
            -o outdir <output directory> 
            -c conversion <ucsc conversion file> 

=head1 AUTHORS

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

