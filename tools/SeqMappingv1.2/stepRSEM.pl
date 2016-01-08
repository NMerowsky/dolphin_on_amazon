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
 my $previous         = "";
 my $bowtiepath       = "";
 my $spaired          = "";
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
        'dspaired=s'       => \$spaired,
        'paramsrsem=s'   => \$params_rsem,
        'previous=s'     => \$previous,
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
#    maps the reads to the the genome and put the files under $outdir directory


my $inputdir="";
print "$previous\n";
if ($previous=~/NONE/g)
{
  $inputdir = "$outdir/input";
}
else
{
  $inputdir = "$outdir/seqmapping/".lc($previous);
}

$outdir   = "$outdir/rsem";
`mkdir -p $outdir`;
$params_rsem=~s/,+/ /g;
$params_rsem=~s/:+/ /g;
$params_rsem=~s/[\s\t]+/ /g;
$params_rsem=~s/_/-/g;
my $com="";
if ($spaired eq "single")
{
  $com=`ls $inputdir/*.fastq`;
}
else
{
  $com=`ls $inputdir/*.1.fastq`;
}

print $com;
my @files = split(/[\n\r\s\t,]+/, $com);

if ($params_rsem=~/NONE/)
{
   $params_rsem="";
}

foreach my $file (@files)
{ 
 $file=~/.*\/(.*).fastq/;
 my $bname=$1;
 $bname=~s/[\s\t\n]+//g;
 if (length($bname) > 1 )
 {
  die "Error 64: please check the file:".$file unless (checkFile($file));
  print "spaired = $spaired\n";
  
  if ($spaired eq "paired")
  {
    $file=~/(.*\/(.*)).1.fastq/;
    $bname=$2;
    my $file2=$1.".2.fastq";
    die "Error 64: please check the file:".$file2 unless (checkFile($file2));
    my $str_files ="$file $file2";

    $com="mkdir -p $outdir/pipe.rsem.$bname/;$rsemCmd --bowtie-path $bowtiepath -p 4 $params_rsem --output-genome-bam --paired-end $str_files $rsemref $outdir/pipe.rsem.$bname/rsem.out.$bname";  
   
  }
  else
  {
    $com="mkdir -p $outdir/pipe.rsem.$bname;$rsemCmd --bowtie-path $bowtiepath -p 4 $params_rsem --output-genome-bam --calc-ci $file $rsemref $outdir/pipe.rsem.$bname/rsem.out.$bname\n"; 
  }
  my $job=$jobsubmit." -n ".$servicename."_".$bname." -c \"$com\"";
  print $job."\n";
  `$job`;
 }
}


sub checkFile
{
 my ($file) = $_[0];
 return 1 if (-e $file);
 return 0;
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




