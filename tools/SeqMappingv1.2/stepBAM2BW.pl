#!/usr/bin/env perl

#########################################################################################
#                                       stepBAM2BW.pl
#########################################################################################
# 
#  Converts bam files for UCSC visualization.
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
 my $genomesize       = "";
 my $type             = "";
 my $GCB              = "";
 my $W2BW             = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'type=s'         => \$type,
        'coverage=s'     => \$GCB,
	'wig2bigwig=s'   => \$W2BW,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
        'genomesize=s'   => \$genomesize,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($W2BW eq "") or ($genomesize eq "") or ($outdir eq "") );	

 
################### MAIN PROGRAM ####################
#   converts the mapped reads for IGV visualization

my $name=basename($outdir);
 
`mkdir -p $outdir/ucsc_$type`;
my @files=();
my $indir="";

if ($type eq "RSEM")
{
   $indir   = "$outdir/rsem";
   @files = <$indir/*/*.genome.sorted.bam>;
}
elsif ($type eq "chip")
{ 
   my $indir   = "$outdir/seqmapping/chip";
   @files = <$indir/*.sorted.bam>;
}
elsif ($type eq "mergechip")
{ 
   my $indir   = "$outdir/seqmapping/mergechip";
   @files = <$indir/*.bam>;
}
else
{
   $indir   = "$outdir/tophat";
   @files = <$indir/*/*.sorted.bam>;
}

foreach my $d (@files){ 
  my $libname="";
  if ($type eq "RSEM")
  {
     $libname=basename($d, ".genome.sorted.bam");
  }
  elsif ($type eq "mergechip")
  {
     $libname=basename($d, ".bam");
  }
  else
  {
     $libname=basename($d, ".sorted.bam");
  }
  my $outputbg="$outdir/ucsc_$type/$libname.bg";
  my $outputbw="$outdir/ucsc_$type/$libname.bw";

  my $com = "$GCB -split -bg -ibam $d -g $genomesize > $outputbg;";
  $com.= "$W2BW -clip -itemsPerSlot=1 $outputbg $genomesize $outputbw;";
  $com.="rm -rf $outputbg;";
  my $job=$jobsubmit." -n ".$servicename."_".$libname." -c \"$com\"";
  print "\n".$job."\n";   
  `$job`;
}

__END__


=head1 NAME

stepBAM2BW.pl

=head1 SYNOPSIS  

stepBAM2BW.pl 
            -o outdir <output directory> 
            -g genomesize <genome size file> 

stepBAM2BW.pl -help

stepBAM2BW.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome/tdf" 

=head2  -g genomesize <genome size file> 

Genome size file. (Full path)

Samtools full path

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepBAM2BW.pl 
            -o outdir <output directory> 
            -g genome <genome files> 
            -s samtools <samtools fullpath> 

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



