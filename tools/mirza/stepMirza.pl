#!/usr/bin/env perl

#########################################################################################
#                                       stepMirza.pl
#########################################################################################
# 
# This program runs mirza for all the files in $outdir/files directory
# Inputs of the program is  
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
 my $outdir           = ""; 
 my $exp              = "";
 my $miRNAseq         = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $dir              = "";
 my $type             = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'exp=s'          => \$exp,
        'mirnaseq=s'     => \$miRNAseq,
        'jobsubmit=s'    => \$jobsubmit,
	'type=s'         => \$type,
        'servicename=s'  => \$servicename,
	'dir=s'          => \$dir,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($exp eq "") or ($outdir eq "") or ($miRNAseq eq "") );	

 
################### MAIN PROGRAM ####################
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory


my $indir   = "$outdir/files";
my $odir  = "$outdir/mirza";

`mkdir -p $odir`;

opendir D, $indir or die "Could not open $indir\n";
my @files = grep /.fa/, readdir(D);
closedir D;

if (@files>0)
{
  foreach my $file(@files){
    my $ofdir="$odir/$file";
    `mkdir -p $ofdir`;
    my $com="cd  $ofdir;nohup $dir/launch_MIRZA $exp $miRNAseq $indir/$file $type $dir > /dev/null 2>&1\n"; 
    if(@files>1)
    {
      my $job=$jobsubmit." -s $servicename -n ".$servicename."_".$file." -c \"$com\"";
      `$job`;
    }
    else
    { 
      `$com`;
    }
  }
}



__END__


=head1 NAME

stepMirza.pl

=head1 SYNOPSIS  

stepMirza.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -t tophatCmd <tophat dir and file> 
            -b bowtie2Ind <ribosome Index file>

stepMirza.pl -help

stepMirza.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -b tophatCmd <bowtie dir and file> 

Fullpath of tophat executable file. Ex: ~/tophat_dir/tophat

=head2  -g gtf <ucsc gtf files> 

Transcript annotation file

=head2  -r bowtie2Ind <ribosome Index file>

Bowtie2 index files. Ex: ~/bowtie_ind/hg18

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepMirza.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -t tophatCmd <tophat dir and file> 
            -b bowtie2Ind <ribosome Index file>

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



