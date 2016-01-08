#!/usr/bin/env perl
#########################################################################################
#                                       rerun.pl
#########################################################################################
#        This program removes step-files to indicate from what step to rerun
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
	'rerun=s'           => \$rerun,
	'servicename=s'       => \$servicename,
	'jobsubmit=s'    => \$jobsubmit,
) or die("Deleter step got unrecognized options.\n");
########################################## MAIN PROGRAM ##################################
if($rerun eq "0"){}
elsif($rerun eq "1"){`rm $outdir/tmp/track/Bam2BW* $outdir/tmp/track/igvConverter* $outdir/tmp/track/StepMapping* $outdir/tmp/track/stepMerge* $outdir/tmp/track/stepSplitFastQ* $outdir/tmp/track/submitAgg* $outdir/tmp/track/submitMacs*;`}
elsif($rerun eq "2"){`rm $outdir/tmp/track/Bam2BW* $outdir/tmp/track/igvConverter* $outdir/tmp/track/submitAgg* $outdir/tmp/track/submitMacs*;`}
elsif($rerun eq "3"){`rm $outdir/tmp/track/Bam2BW* $outdir/tmp/track/submitAgg* $outdir/tmp/track/submitMacs*;`}
elsif($rerun eq "4"){`rm $outdir/tmp/track/submitAgg* $outdir/tmp/track/submitMacs*;`}
elsif($rerun eq "5"){`rm $outdir/tmp/track/submitAgg*;`}
else
{
 print STDERR "Weired input in Rerun field\n";
 exit(1);
}
if($? != 0)
{
 print STDERR "Failed to initiate rerun. Check that the output folder still exists as well as double check that input is the same as before.\n";
 exit(1);
}

__END__

=head1 NAME

rerun.pl

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
