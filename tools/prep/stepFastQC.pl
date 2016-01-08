#!/usr/bin/env perl

#########################################################################################
#                                       stepFastQC.pl
#########################################################################################
# 
#  This program runs FastQC analysis.
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
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'input=s'        => \$input,
	'outdir=s'       => \$outdir,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($input eq "") or ($outdir eq "") );	

 
################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

$outdir   = "$outdir/fastqc";

mkdir $outdir if (! -e $outdir);

my @prefiles=split(/:/,$input);
  
for(my $i=0;$i<@prefiles;$i++) 
{
  my @files=split(/,/,$prefiles[$i]);
  if (@files>=3)
  {
    my $libname=$files[1];

    for (my $j=2; $j<@files; $j++)
    {
     print "$files[$j]:[".(-e $files[$j])."]\n";
     if (-e $files[$j])
     {
       my $dir="$outdir/".$libname;
       if (@files==4)
       {
         $dir.= "_R".($j-1)
       }
       `mkdir -p $dir`;
       my $casava="";
       if ($files[$j]=~/\*/)
       {
          $casava="--casava ";
       }
       my $com="module load fastqc/0.10.1; fastqc $casava".$files[$j]." -o $dir";
       print $com."\n";
       if(((@files-2)+@prefiles)>1 && $jobsubmit!~/^$/)
       {
         my $job=$jobsubmit." -n ".$servicename."_".$libname."_R".($j-1)." -c \"$com\"";
         `$job`;
       }
       else
       {
         `$com`;
       }
     }
     else
     {
        print "ERROR:Please check the file:".$files[$j].", and try again!!!\n";
        exit 1;
     }
    }
  }
}

__END__


=head1 NAME

stepFastQC.pl

=head1 SYNOPSIS  

stepFastQC.pl 
            -i input <fastq> 
            -o outdir <output directory> 


stepFastQC.pl -help

stepFastQC.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be stored "$outdir/after_ribosome/fastqc" 

=head2 -i  input file <fastq format> 

fastq files has to be separated with ":". If it is paired end the paired end files has to ber separated by ","

Ex: For single end;

test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq

for paired end;

test1_R1.fastq,test1_R2.fastq:ctrl1_R1.fastq,ctrl1_R2.fastq

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

This program runs FastQC analysis.

=head1 EXAMPLE

stepFastQC.pl 
            -i input <fastq> 
            -o outdir <output directory> 


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





