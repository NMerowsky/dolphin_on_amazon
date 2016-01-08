#!/usr/bin/env perl

#########################################################################################
#                                       stepTophat2.pl
#########################################################################################
# 
#  This program maps the reads to with tophat2 ti a given genome.
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
 my $gtf              = "";
 my $outdir           = "";
 my $bowtie2Ind       = "";
 my $tophatCmd        = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'tophatCmd=s'    => \$tophatCmd,
        'bowtie2Ind=s'   => \$bowtie2Ind,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
        'gtf=s'          => \$gtf,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($bowtie2Ind eq "") or ($outdir eq "") or ($tophatCmd eq "") );	

 
################### MAIN PROGRAM ####################
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory


my $indir   = "$outdir/after_ribosome";
$outdir  = "$outdir/tophat";

mkdir $outdir if (! -e $outdir);

opendir D, $indir or die "Could not open $indir\n";
my @files = grep /1.notR$/, readdir(D);
closedir D;
if (@files>0)
{
  foreach my $e(@files){
    my $sec=$e;
    $sec=~s/1\./2\./;
    my $str_files ="$indir/$e $indir/$sec";
    #print "$str_files\n";
    $e =~ s/_1.notR//;
    
    my $ucsc=$gtf;
    $ucsc=~s/\.gtf/\.fa/;
    my $ti="";
    if (-s $ucsc) {
	$ucsc=~s/\.fa//;
	$ti=" --transcriptome-index=$ucsc";
    }
    
    if (!(-s "$outdir/pipe.tophat.$e/accepted_hits.bam"))
    {
       #my $outdir1=$outdir."_2";
       #`mkdir -p $outdir1`;
       #print "$outdir/pipe.tophat.$e/accepted_hits.bam\n";
       my $com="$tophatCmd -p 8 -g 15 -r 300 -N 2 --no-coverage-search --keep-tmp -G $gtf $ti -o $outdir/pipe.tophat.$e $bowtie2Ind $str_files\n"; 
       if(@files>1)
       {
         my $job=$jobsubmit." -n ".$servicename."_".$e." -c \"$com\"";
	 print $job."\n";
         `$job`;
       }
       else
       { 
        `$com`;
       }
    }
  }
}
else
{
   opendir D, $indir or die "Could not open $indir\n";
   @files = grep /notR$/, readdir(D);
   closedir D;

   foreach my $e(@files){
      my $str_files ="$indir/$e";
      #print "$str_files\n";
      $e =~ s/\.notR//;
      if (!(-s "$outdir/pipe.tophat.$e/accepted_hits.bam"))
      {
	#my $outdir1=$outdir."_1";
        #`mkdir -p $outdir1`;
	#print "$outdir/pipe.tophat.$e/accepted_hits.bam\n";
        my $com="$tophatCmd  -p 8 -g 15 -r 300 -N 2 --no-coverage-search -G $gtf -o $outdir/pipe.tophat.$e $bowtie2Ind $str_files\n";
        if(@files>1 && $jobsubmit!~/^$/)
        {
          my $job=$jobsubmit." -s $servicename -n ".$servicename."_".$e." -c \"$com\"";
          `$job`;
        }
        else
        {  
          `$com`;
        }
      }
   }
}


__END__


=head1 NAME

stepTophat2.pl

=head1 SYNOPSIS  

stepTophat2.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -t tophatCmd <tophat dir and file> 
            -b bowtie2Ind <ribosome Index file>

stepTophat2.pl -help

stepTophat2.pl -version

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

stepTophat2.pl 
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



