#!/usr/bin/env perl

#########################################################################################
#                                       stepCuffdiff.pl
#########################################################################################
# 
#  This program runs the Cuffdiff after cufflinks
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
 my $cuffcmp          = "";
 my $input            = "";
 my $outdir           = "";
 my $cuffdiffCmd      = "";
 my $diff_str         = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions(
        'input=s'         => \$input,
	'outdir=s'        => \$outdir,
        'cuffdiffCmd=s'   => \$cuffdiffCmd,
        'fileCuffCmp=s'   => \$cuffcmp,
        'diff=s'          => \$diff_str,
        'jobsubmit=s'     => \$jobsubmit,
        'servicename=s'   => \$servicename,
	'help'            => \$help, 
	'version'         => \$print_version,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($diff_str eq "") or ($outdir eq "") or ($cuffdiffCmd eq "") );	

 
################### MAIN PROGRAM ####################++
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory

my $indir   = "$outdir/tophat";
$outdir  = "$outdir/cuffdiff";

mkdir $outdir if (! -e $outdir);

my @diff=split(/:/,$diff_str);


#smallR1,smallR2:ctrlR1,ctrlR2
my @prefiles=split(/:/,$input);
my %filearr=();

for(my $i=0;$i<@prefiles;$i++) 
{
  my @files=split(/,/,$prefiles[$i]);
  
  if (@files>=3)
  {
    my $groupid=$files[0];
    my $libname=$files[1];
    print $groupid.":".$libname."\n";
    print "$indir/$libname.sorted.bam\n";
    if (-s "$indir/$libname.sorted.bam")
    {
     if (exists $filearr{$groupid}) {
	$filearr{$groupid}.="\,$indir/$libname.sorted.bam";
      }
      else
      { 
        $filearr{$groupid}="$indir/$libname.sorted.bam";
      }
    }
    print $filearr{$groupid}."\n";
  }
}


foreach my $d (@diff)
{

  my @indx=split(/,/, $d);
  if (@indx==2) {
   $d=~s/,/_/;
   if ($filearr{$indx[0]}!~/^$/ && $filearr{$indx[1]}!~/^$/)
   {  
     my $comm=$filearr{$indx[0]}." ".$filearr{$indx[1]};
     print $comm."\n";
     my $cmd="$cuffdiffCmd -p 8 -o $outdir/pipe.cuffdiff.$d.output --library-type fr-unstranded -m 300 --no-update-check $cuffcmp $comm\n";
     print $cmd."\n";
     if(@diff>1 && $jobsubmit!~/^$/)
     {
       my $job=$jobsubmit." -n ".$servicename."_".$d." -c \"$cmd\"";
       `$job`;
     }
     else
     { 
      `$cmd`;
     }
   }
  }
}
__END__


=head1 NAME

stepCuffdiff.pl

=head1 SYNOPSIS  

stepCuffdiff.pl 
            -o outdir <output directory> 
            -f fileCuffCmp <ucsc gtf files> 
            -c cuffdiffCmd <cuffdiff full path> 
            -d diff <library comparison definitions> 


stepCuffdiff.pl -help

stepCuffdiff.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be stored "$outdir/after_ribosome/cuffdiff" 

=head2 -c cuffdiffCmd <cufflinks full path> 

Fullpath of cuffdiff executable file. Ex: ~/cuffdiff_dir/cuffdiff

=head2  -f fileCuffCmp <cuffcmp file>  

cuffcmp file. It has to be prepared beforhand and put into the necessary directory.

=head2  -d diff <library comparison definitions> 
To find diff using cuffdiff the file base names should be given. For example the files are like below 
treat_rep1_R1.fastq, treat_rep1_R2.fastq
treat_rep2_R1.fastq, treat_rep2_R2.fastq
ctrl_rep1_R1.fastq, ctrl_rep1_R2.fastq
ctrl_rep2_R1.fastq, ctrl_rep2_R2.fastq

the @DIFF=treat_rep1,treat_rep2:ctrl_rep1,ctrl_rep2 

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

This program runs the Cuffdiff after cufflinks

=head1 EXAMPLE

stepCuffdiff.pl 
            -o outdir <output directory> 
            -f fileCuffCmp <ucsc gtf files> 
            -c cuffdiffCmd <cuffdiff full path> 
            -d diff <library comparison definitions> 

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





