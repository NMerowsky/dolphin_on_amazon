#!/usr/bin/env perl
#########################################################################################
#                                       fastqc_wrapper.pl
#########################################################################################
#                          This program runs FASQC for each fastq file.
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
##################################### LIBRARIES AND PRAGMAS #############################
use Getopt::Long;
######################################## PARAMETER PARSING ##############################
GetOptions( 
	'outdir=s'            => \$outdir,
	'input=s'             => \$input,
	'command=s'           => \$command,
	'servicename=s'       => \$servicename,
        'jobsubmit=s'    => \$jobsubmit,
) or die("FastQC step got unrecognized options.\n");
########################################## MAIN PROGRAM ##################################
if (! -e "$outdir/fastqc")
{
 `mkdir -p $outdir/fastqc`;
 if($? != 0)
 {
  print STDERR "Failed to create output folder for FastQC\n";
  exit(1);
 }
}
$input=~s/\,/\:/g;
@files=split(/:/,$input);
@files = grep { ! $seen{$_} ++ } @files;  
for($i=0;$i<@files;$i++) 
{
 $com="$command $files[$i] -o $outdir/fastqc\n";
 $job=$jobsubmit." -n ".$servicename."_".$i." -c \"$com\"";
 `$job`;
 if($? != 0)
 {
  print STDERR "Failed to submit FastQC job for $files[$i]\n";
  exit(1);
 }
 print $job."\n";
}

__END__

=head1 NAME

fastqc_wrapper.pl

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
