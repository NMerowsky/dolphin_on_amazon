#!/usr/bin/env perl
#########################################################################################
#                                       splitFastq_wrapper.pl
#########################################################################################
#                          This program runs fastq_splitter for each fastq file.
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### LIBRARIES AND PRAGMAS ###########################
use Getopt::Long;
####################################### PARAMETER PARSUING ##############################
GetOptions( 
	'outdir=s'            => \$outdir,
	'input=s'             => \$inputfile,
	'program=s'           => \$prog,
	'numberlines=s'           => \$num,
	'servicename=s'       => \$servicename,
	'jobsubmit=s'    => \$jobsubmit,
) or die("Fastq_split step got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
$inputfile=~s/\,/\:/g;
@v=split/\:/,$inputfile;
@v = grep { ! $seen{$_} ++ } @v;
if (! -e "$outdir")
{
 `mkdir -p $outdir`;
 if($? != 0)
 {
  print STDERR "Failed to create output folder for splitted fastq files\n";
  exit(1);
 }
}
for ($i1=0;$i1<=$#v;$i1++)
{
 $inputfile=$v[$i1];
 $com="$prog -i $inputfile -o $outdir -n $num";
 $job=$jobsubmit." -n ".$servicename."_".($i1+1)." -c \"$com\"";
 `$job`;
 if($? != 0)
 {
  print STDERR "Failed to submit Fastq split job for $inputfile\n";
  exit(1);
 }
 print $job."\n";
}

__END__

=head1 NAME

splitFastq_wrapper.pl

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
