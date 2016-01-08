#!/usr/bin/env perl

#########################################################################################
#                                       stepTophat2.pl
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
 my $gtf              = "";
 my $outdir           = "";
 my $params_tophat    = "";
 my $previous         = "";
 my $bowtie2Ind       = "";
 my $spaired          = "";
 my $tophatCmd        = "";
 my $samtools         = ""; 
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'tophatcmd=s'    => \$tophatCmd,
        'dspaired=s'     => \$spaired,
        'paramstophat=s' => \$params_tophat,
        'bowtie2Ind=s'   => \$bowtie2Ind,
        'previous=s'     => \$previous,
        'jobsubmit=s'    => \$jobsubmit,
        'samtools=s'     => \$samtools,
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

$outdir   = "$outdir/tophat";
`mkdir -p $outdir`;
$params_tophat =~s/,/ /g;
$params_tophat=~s/_/-/g;
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

my $ucsc=$gtf;
$ucsc=~s/\.gtf/\.fa/;
my $ti="";
if (-s $ucsc) {
  $ucsc=~s/\.fa//;
  $ti=" --transcriptome-index=$ucsc";
}

if ($params_tophat=~/NONE/)
{
   $params_tophat="";
}
foreach my $file (@files)
{ 
 $file=~/.*\/(.*).fastq/;
 my $bname=$1;
 my $str_files=$file;
 die "Error 64: please check the file:".$file unless (checkFile($file));
 if ($spaired ne "single")
 {
    $file=~/(.*\/(.*)).1.fastq/;
    $bname=$2;
    my $file2=$1.".2.fastq";
    die "Error 64: please check the file:".$file2 unless (checkFile($file2));

    $str_files ="$file $file2";
 }

 if (!(-s "$outdir/pipe.tophat.$bname/accepted_hits.bam"))
 {
   $com="$tophatCmd -p 4 $params_tophat --keep-tmp -G $gtf $ti -o $outdir/pipe.tophat.$bname $bowtie2Ind $str_files;\n";
   $com.="$samtools sort $outdir/pipe.tophat.$bname/accepted_hits.bam $outdir/pipe.tophat.$bname/$bname.sorted;\n";
   $com.="$samtools index $outdir/pipe.tophat.$bname/$bname.sorted.bam;\n"; 
 }     
 print "$com\n";
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

stepTophat2.pl

=head1 SYNOPSIS  

stepTophat2.pl 
            -o outdir <output directory> 
            -r tophatref <tophatref files> 
            -c cmdtophat <tophat Commandd> 
            -p paramstophat <tophat parameters>

stepTophat2.pl -help

stepTophat2.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -c CmdRSEM <bowtie dir and file> 

Fullpath of tophat-calculate-expression file. Ex: /isilon_temp/garber/bin/RSEM/tophat-calculate-expression

=head2  -r tophatref <tophat ref files> 

tophat reference file

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




