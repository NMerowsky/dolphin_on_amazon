#!/usr/bin/env perl
#########################################################################################
#                                       macs14.pl
#########################################################################################
#                    This program runs MACS software to call peaks for the mapped reads.
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### LIBRARIES AND PRAGMAS ###########################
use Getopt::Long;
use File::Basename;
####################################### PARAMETER PARSUING ##############################
GetOptions( 
	'macsoutdir=s'       => \$outdir,
	'outdirbowtie=s'       => \$indir,
	'acommand=s'       => \$command,
	'input=s'       => \$input,
	'jobsubmit=s'    => \$jobsubmit,
	'servicename=s'  => \$servicename,
) or die("Unrecognized optioins for MACS\n"); 
################### MAIN PROGRAM ####################
if (! -e "$outdir")
{
 `mkdir -p $outdir`;
 if($? != 0)
 {
  print STDERR "Failed to create output folder for MACS output\n";
  exit(1);
 }
}
@prefiles=split(/:/,$input);
for($i=0;$i<@prefiles;$i++) 
{
 @file=split(/,/,$prefiles[$i]);
 if (@file eq 2)
 {
  ($filename1)  = fileparse($file[0]);
  ($filename2)  = fileparse($file[1]);
  $com="$command -t $indir/$filename1.sorted.sam -c $indir/$filename2.sorted.sam --name=$outdir/$filename1.vs.$filename2\n";
  $a="$filename1.$filename2";
  $job=$jobsubmit." -n ".$servicename."_".$a." -c \"$com\"";
  `$job`;
  if($? != 0)
  {
   print STDERR "Failed to submit MACS for $filename1 vs $filename2\n";
   exit(1);
  } 
  print $job."\n";
 }
 else
 {
  print STDERR "Failed to parse your filenames for MACS, check that they are in pairs and nothing else is there";
  exit(1);
 }
}

__END__

=head1 NAME

macs14.pl

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
