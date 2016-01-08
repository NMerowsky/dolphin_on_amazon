#!/usr/bin/env perl

#########################################################################################
#                                       stepIGVTDF.pl
#########################################################################################
# 
#  Converts bam files for IGV visualization.
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
 my $genome           = "";
 my $outdir           = "";
 my $samtools         = "";
 my $igvtools         = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'samtools=s'     => \$samtools,
        'igvtools=s'     => \$igvtools,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
        'genome=s'       => \$genome,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($samtools eq "") or ($genome eq "") or ($outdir eq "") );	

 
################### MAIN PROGRAM ####################
#   converts the mapped reads for IGV visualization

my $indir   = "$outdir/tophat";
$outdir  = "$outdir/tdf";

mkdir $outdir if (! -e $outdir);

my @files = <$indir/*.sorted.bam>;

foreach my $d (@files){ 

  my $libname=basename($d, ".sorted.bam");
  
  my $com = "$samtools index $indir/$libname.sorted.bam $indir/$libname.sorted.bam.bai;\n";
  $com.="cp $indir/$libname.sorted.bam $outdir/$libname.bam;\n";
  $com.="cp $indir/$libname.sorted.bam.bai $outdir/$libname.bam.bai;\n";
  $com.="cd $outdir; $igvtools count -w 5 $outdir/$libname.bam  $outdir/$libname.tdf $genome\n"; 
  
  if(@files>1 && $jobsubmit!~/^$/)
  { 
    my $job=$jobsubmit." -n ".$servicename."_".$libname." -c \"$com\"";
    print $job."\n";   
    `$job`;
  }
  else
  { 
    `$com`;
  }
}

__END__


=head1 NAME

stepIGVTDF.pl

=head1 SYNOPSIS  

stepIGVTDF.pl 
            -o outdir <output directory> 
            -g genome <genome files> 
            -s samtools <samtools fullpath> 

stepIGVTDF.pl -help

stepIGVTDF.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome/tdf" 

=head2  -g genome <genome files> 

Genome fasta file. (Full path)

=head2   -t samtools <samtools fullpath> 

Samtools full path

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepIGVTDF.pl 
            -o outdir <output directory> 
            -g genome <genome files> 
            -s samtools <samtools fullpath> 

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



