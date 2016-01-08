#!/usr/bin/env perl

#########################################################################################
#                                       agg_plot.pl
#########################################################################################
# 
#  This program perform ACT aggregation for the mapped tags
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
 my $path             = "";
 my $genome           = "";
 my $reference        = "";
 my $outdir           = "";
 my $indir            = "";
 my $input            = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

GetOptions(
	'path=s'         => \$path,
	'genome=s'       => \$genome, #(hg19.chromInfo)
 	'reference=s'    => \$reference, #(refseq4col)
 	'outdir=s'       => \$indir,
     	'input=s'        => \$input,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
	'help'           => \$help, 
	'version'        => \$print_version,
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

#pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($bowtie2Ind eq "") or ($outdir eq "") or ($tophatCmd eq "") );	

 
################### MAIN PROGRAM ####################
#    
$outdir="$indir/aggregationout";
mkdir $outdir if (! -e $outdir);

my @prefiles=split(/:/,$input);
  
for(my $i=0;$i<@prefiles;$i++) 
{
  my @file=split(/,/,$prefiles[$i]);
  if (@file eq 2)
  {
   my($filename)  = fileparse($file[0]);
   my $com="$path/samtools sort $indir/$filename.bam $outdir/$filename.sorted;\n"; 
   $com.="$path/bedtoolshpcc/bin/genomeCoverageBed -bga -ibam $outdir/$filename.sorted.bam -g $genome > $outdir/$filename.bed;\n";
   $com.="awk '{print \\\$1\\\"\\\\t\\\"\\\$2\\\"\\\\t\\\"\\\$4}' $outdir/$filename.bed > $outdir/$filename.sig;\n";
   $com.="python $path/ACT/ACT.py --nbins=50 --mbins=50 --radius=5000 --region $reference $outdir/$filename.sig > $outdir/$filename.aggregation_plot.out;\n";
   $com.="R --file=$path/ACT/intopdf.R --args $outdir/$filename.aggregation_plot.out;\n";
   my $a="$filename.aggregation";
   my $job=$jobsubmit." -n ".$servicename."_".$a." -c \"$com\"";
   `$job`;
  }
}


__END__


=head1 NAME

agg_plot.pl

=head1 SYNOPSIS  

agg_plot.pl 

Intended to run ONLY from workflows

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

