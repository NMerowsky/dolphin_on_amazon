#!/usr/bin/env perl

#########################################################################################
#                                       stepRSEM.pl
#########################################################################################
# 
#  This program quantify the genes using RSEM 
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
 my $rsemref          = "";
 my $outdir           = "";
 my $params_rsem      = "";
 my $bowtiepath       = "";
 my $rsemCmd          = "/project/umw_biocore/bin/rsem-1.2.3/rsem-calculate-expression";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'cmdrsem=s'      => \$rsemCmd,
        'bowtiepath=s'   => \$bowtiepath,
        'paramsrsem=s'   => \$params_rsem,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
        'rsemref=s'      => \$rsemref,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($bowtiepath eq "") or ($outdir eq "") or ($rsemCmd eq "") );	

 
################### MAIN PROGRAM ####################
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory
 

my $indir   = "$outdir/after_ribosome";
$outdir  = "$outdir/rsem";
$params_rsem =~s/,/ /g;

mkdir $outdir if (! -e $outdir);

opendir D, $indir or die "Could not open $indir\n";
my @files = grep /\.1\.notR$/, readdir(D);
closedir D;
if ($params_rsem=~/NONE/)
{
   $params_rsem="";
}
if (@files>0)
{
  foreach my $e(@files){
    my $sec=$e;
    $sec=~s/\.1\.notR/\.2\.notR/;
    my $str_files ="$indir/$e $indir/$sec";
    #print "$str_files\n";
    $e =~ s/\.1\.notR//;

    my $com="mkdir -p $outdir/pipe.rsem.$e/;$rsemCmd --bowtie-path $bowtiepath -p 4 $params_rsem --output-genome-bam --paired-end $str_files $rsemref $outdir/pipe.rsem.$e/rsem.out.$e";  
   
    my $job=$jobsubmit." -n ".$servicename."_".$e." -c \"$com\"";
    print $job."\n";
    `$job`;
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

	#my $outdir1=$outdir."_1";
        #`mkdir -p $outdir1`;
	#print "$outdir/pipe.tophat.$e/accepted_hits.bam\n";
        my $com="mkdir -p $outdir/pipe.rsem.$e/;$rsemCmd --bowtie-path $bowtiepath -p 4 $params_rsem --output-genome-bam --calc-ci $str_files $rsemref $outdir/pipe.rsem.$e/rsem.out.$e\n"; 
        print "$com\n";
        my $job=$jobsubmit." -s $servicename -n ".$servicename."_".$e." -c \"$com\"";
        `$job`;
   }
}

__END__


=head1 NAME

stepRSEM.pl

=head1 SYNOPSIS  

stepRSEM.pl 
            -o outdir <output directory> 
            -r rsemref <rsemref files> 
            -c cmdrsem <rsem Commandd> 
            -b bowtiepath <ribosome Index file>
            -p paramsrsem <rsem parameters>

stepRSEM.pl -help

stepRSEM.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -c CmdRSEM <bowtie dir and file> 

Fullpath of rsem-calculate-expression file. Ex: /isilon_temp/garber/bin/RSEM/rsem-calculate-expression

=head2  -r rsemref <rsem ref files> 

rsem reference file

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepRSEM.pl 
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




