#!/usr/bin/env perl

#########################################################################################
#                                       stepSubSample.pl
#########################################################################################
# 
# It sub sample the file into many small parts
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
 my $input                      = "";
 my $outdir                     = "";
 my $jobsubmit                  = "";
 my $subsample_size             = "";
 my $number_of_subsamples       = 3;
 my $execdir                    = "";
 my $servicename                = "";
 my $help                       = "";
 my $print_version              = "";
 my $version                    = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'input=s'                 => \$input,
	'outdir=s'                => \$outdir,
	'execdir=s'               => \$execdir,
        'subsample_size=s'        => \$subsample_size,
        'number_of_subsamples=s'  => \$number_of_subsamples,
        'servicename=s'           => \$servicename,
        'jobsubmit=s'             => \$jobsubmit,
	'help'                    => \$help, 
	'version'                 => \$print_version,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($input eq "") or ($outdir eq "") or ($number_of_subsamples eq "") );	

 print "[$servicename]\n";
################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

$outdir   = "$outdir/input";
`mkdir -p $outdir`; 

my @s_size=split(/:/,$subsample_size);
my @prefiles=split(/:/,$input);  
for(my $i=0;$i<@prefiles;$i++) 
{
  my @files=split(/,/,$prefiles[$i]);
  for (my $n=0; $n<$number_of_subsamples; $n++)
  {
    foreach my $subsamplesize (@s_size)
    {
      my $libname=$files[1];
      my $str_file=$files[2];
      my $outd=$outdir."/$libname";
      `mkdir -p $outd`;
      my $com="";
      if (@files==3)
      {
        $com="module load python/2.7.5;python $execdir/subSampler.py $str_file $outd/lib.$libname.$n.$subsamplesize.fastq $subsamplesize";
      }
      elsif (@files==4)
      {
	$com="module load python/2.7.5;python $execdir/subSamplerPaired.py $str_file $files[3] $outd/lib.$libname.$n.$subsamplesize.R1.fastq $outd/lib.$libname.$n.$subsamplesize.R2.fastq $subsamplesize";
      }
      my $job=$jobsubmit." -n $servicename.$libname.$n.$subsamplesize -c \"$com\"";
      print $job."\n";   
      `$job`;
    }
  }
}


__END__


=head1 NAME

stepSubSample.pl

=head1 SYNOPSIS  

stepSubSample.pl -i input <fastq> 
            -o outdir <output directory> 
            -b bowtieCmd <bowtie dir and file> 
            -p params <bowtie params> 
            -r ribosomeInd <ribosome Index file>

stepSubSample.pl -help

stepSubSample.pl -version

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

=head2 -b bowtieCmd <bowtie dir and file> 

Fullpath of bowtie executable file. Ex: ~/bowtie_dir/bowtie

=head2  -p params <bowtie params> 

Bowtie running parameteres. Ex: "-p 8 -n 2 -l 20 -M 1 -a --strata --best"

=head2  -r ribosomeInd <ribosome Index file>

Ribosomal index files. Ex: ~/bowtie_ind/rRNA


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program map the reads to rRNAs and put the rest into other files 

=head1 EXAMPLE


stepSubSample.pl -i test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq
            -o ~/out
            -b ~/bowtie_dir/bowtie
            -p "-p 8 -n 2 -l 20 -M 1 -a --strata --best"
            -r ~/bowtie_ind/rRNA

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


