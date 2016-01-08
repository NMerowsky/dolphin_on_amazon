#!/usr/bin/env perl
#########################################################################################
#                                       rundeleter.pl
#########################################################################################
#                          This program removes all large temporary files.
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
	'delete=s'           => \$delete,
	'servicename=s'       => \$servicename,
	'jobsubmit=s'    => \$jobsubmit,
) or die("Deleter step got unrecognized options.\n");
########################################## MAIN PROGRAM ##################################
if($delete eq "1")
{
 $com="rm $outdir/aggregationout/*bed; rm $outdir/aggregationout/*sig;rm -r $outdir/files; rm -r $outdir/mappings; rm $outdir/*bg; rm $outdir/*sam; rm $outdir/*tmp.bam\n";
 $job=$jobsubmit." -n ".$servicename." -c \"$com\"";
 `$job`;
 if($? != 0)
 {
  print STDERR "Failed to submit deleting job\n";
  exit(1);
 }
 print $job."\n";
}

__END__

=head1 NAME

rundeleter.pl

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
