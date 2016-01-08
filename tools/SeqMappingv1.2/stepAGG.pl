#!/usr/bin/env perl

#########################################################################################
#                                       stepAGG.pl
#########################################################################################
# 
#  This program trims the reads in the files. 
#
#
#########################################################################################
# AUTHORS:
#
# Alper Kucukural, PhD 
# Aug 18, 2014
#########################################################################################

############## LIBRARIES AND PRAGMAS ################

 use List::Util qw[min max];
 use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 

#################### VARIABLES ######################
 my $bedtoolsgencov   = "";
 my $genome           = "";
 my $act              = "";
 my $reference        = "";
 my $creationpdf      = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $previous         = ""; 
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
 	'bedtoolsgencov=s' => \$bedtoolsgencov,
	'genome=s'         => \$genome, #(hg19.chromInfo)
	'reference=s'      => \$reference, #(refseq4col)
        'act=s'            => \$act,
 	'creationpdf=s'    => \$creationpdf,
	'outdir=s'         => \$outdir,
        'previous=s'       => \$previous,
        'servicename=s'    => \$servicename,
        'jobsubmit=s'      => \$jobsubmit,
	'help'             => \$help, 
	'version'          => \$print_version,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($act eq "") or ($outdir eq "") );	

################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

print "$previous\n";
my $sorted=".sorted";
my $inputdir = "$outdir/seqmapping/chip";
if ($previous=~/SPLIT/g)
{
  $inputdir = "$outdir/seqmapping/mergechip";
  $sorted="";
}

$outdir  = "$outdir/agg";
`mkdir -p $outdir`;
my $com="";
$com=`ls $inputdir/*$sorted.bam`;
print $com;
my @files = split(/[\n\r\s\t,]+/, $com);

foreach my $file (@files)
{
 die "Error 64: please check the file:".$file unless (checkFile($file));
 $file=~/.*\/(.*)$sorted.bam/;
 my $bname=$1;
 $com = "$bedtoolsgencov -bga -ibam $file -g $genome > $outdir/$bname.bed;\n";
 $com.= "awk '{print \\\$1\\\"\\\\t\\\"\\\$2\\\"\\\\t\\\"\\\$4}' $outdir/$bname.bed > $outdir/$bname.sig;\n";
 $com.= "$act --output=$outdir/$bname.agg_plot.out $reference $outdir/$bname.sig;\n";
 $com.= "$creationpdf --args $outdir/$bname.agg_plot.out;\n";
 #print $com."\n\n";  
 #`$com`;
 my $job=$jobsubmit." -n ".$servicename."_".$bname." -c \"$com\"";
 print $job."\n";   
 `$job`;
}

sub checkFile
{
 my ($file) = $_[0];
 return 1 if (-e $file);
 return 0;
}

__END__


=head1 NAME

stepAGG.pl

=head1 SYNOPSIS  

stepAGG.pl -o outdir <output directory> 
            -p previous 
            -n #reads

stepAGG.pl -help

stepAGG.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/split" 

=head2  -p previous

previous step


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program map the reads to rRNAs and put the rest into other files 

=head1 EXAMPLE


stepAGG.pl 
            -o ~/out
            -n 1000
            -p previous

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


