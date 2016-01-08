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
 my $prog             = "";
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
	'prog=s'         => \$prog,
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

`mkdir -p $outdir`;

my @prefiles=split(/:/,$input);
print @prefiles."\n";
for(my $i=0;$i<scalar(@prefiles);$i++) 
{
  my @files=split(/[,\s\t]+/,$prefiles[$i]);
  if (scalar(@files)>=2)
  {
    my $libname=$files[0];
    print $libname."\n";
    for (my $j=1; $j<scalar(@files); $j++)
    {
     #print "$files[$j]:[".(-e $files[$j])."]\n";
     if (-e $files[$j] || $files[$j]=~/\*/ )
     {
       my $dir="$outdir/".$libname;
       if (scalar(@files)==3)
       {
         $dir.= "_R".($j-1)
       }
       `mkdir -p $dir`;
       my $casava="";
       if ($files[$j]=~/\*/)
       {
          $casava="--casava ";
       }
       
       #print $files[$j]."\n\n";
       my $com="$prog $casava".$files[$j]." -o $dir";

       print $com."\n";
       my $job=$jobsubmit." -n ".$servicename."_".$libname."_R".($j-1)." -c \"$com\"";
       `$job`;
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





