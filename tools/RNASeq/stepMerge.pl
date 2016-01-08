#!/usr/bin/env perl

#########################################################################################
#                                       stepMerge.pl
#########################################################################################
# 
#  This program merges tophat results.
#
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
 my $input            = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $samtools        = ""; 
 my $servicename      = "";
 my $param            = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'input=s'        => \$input,
	'outdir=s'       => \$outdir,
	'samtools=s'     => \$samtools,
        'servicename=s'  => \$servicename,
        'jobsubmit=s'    => \$jobsubmit,
        'param=s'        => \$param,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($input eq "") or ($outdir eq "") or ($samtools eq "") );	

 print "[$servicename]\n";
################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

$outdir   = "$outdir/tophat";

mkdir $outdir if (! -e $outdir);

my @prefiles=split(/:/,$input);
  
for(my $i=0;$i<@prefiles;$i++) 
{
  my @files=split(/,/,$prefiles[$i]);
  if (@files>=3)
  {
    my $libname=$files[1];
    my $str_file=$files[2];
    
    
    if ((-s $files[2])==0 && $files[2]!~/\*/)
    {
        print "ERROR:Please check the file:".$files[2].", and try again!!!\n";
        exit 1;
   
    }
        
    if ($files[2]=~/\*/) {
	mergeMultipleFiles(\@files, $jobsubmit, $servicename, $samtools, $outdir);
    }
    else
    {

	my $fstr="$outdir/*\.".$libname.".*/accepted_hits.bam";

	my $com="cp $fstr $outdir/$libname.sorted.bam";
	my $job=$jobsubmit." -n ".$servicename."_".$libname." -c \"$com\"";
        print $job."\n";   
        `$job`;
    }
  }
}

sub mergeMultipleFiles
{
    my ($files, $jobsubmit, $servicename, $samtools, $outdir) = @_;
    my $libname=@{$files}[1];
    my @f1=<${$files}[2]>;
    my $str_file ="";
    for (my $i=0; $i<@f1; $i++)
    {
     my $fstr="$outdir/*\.".$libname."*".($i+1)."\.*/accepted_hits.bam"; 
     my $fil= `ls $fstr 2>&1 `;
     chomp($fil);
     if ($fil!~/No such file/)
     {   
       $str_file.="$outdir/*\.".$libname."*".($i+1)."*/accepted_hits.bam ";
     }
     else
     {
        $str_file.="$outdir/*\.".$libname."*/accepted_hits.bam ";
     }
    }
    my $com ="$samtools merge $outdir/$libname.tmp.bam $str_file -f;";
    $com.="$samtools view -F12 $outdir/$libname.tmp.bam -b > $outdir/$libname.bam;";
    $com.="$samtools sort $outdir/$libname.bam $outdir/$libname.sorted";

    my $job=$jobsubmit." -n ".$servicename."_".$libname." -c \"$com\"";
    print $job."\n";   
    `$job`;
}

__END__


=head1 NAME

stepMerge.pl

=head1 SYNOPSIS  

stepMerge.pl -i input <fastq> 
            -o outdir <output directory> 
            -sa samtools <samtools> 

stepMerge.pl -help

stepMerge.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -i  input file <fastq format> 

fastq files has to be separated with ":". If it is paired end the paired end files has to ber separated by ","

Ex: For single end;

test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq

for paired end;

test1_R1.fastq,test1_R2.fastq:ctrl1_R1.fastq,ctrl1_R2.fastq

    
=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program merges bam files

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


