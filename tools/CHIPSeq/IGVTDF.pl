#!/usr/bin/env perl
#########################################################################################
#                                       stepIGVTDF.pl
#########################################################################################
#                    This program converts bam files for IGV visualization.
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### LIBRARIES AND PRAGMAS ###########################
use Getopt::Long;
####################################### PARAMETER PARSUING ##############################
GetOptions( 
	'input=s'        => \$input,
	'outdir=s'       => \$outdir,
        'samtools=s'     => \$samtools,
        'fastagenome=s'  => \$genome,
        'mtools=s'       => \$mtools,
) or die("Unrecognized optioins.\n");
######################################### MAIN PROGRAM ##################################
`$samtools index $input.bam $input.bam.bai`;
if($? != 0)
{
 print STDERR "Failed to index bam file for submitting IGV conversion for $input\n";
 exit(1);
}
`cd $outdir; $mtools count -w 5 $input.bam $input.tdf $genome`; 
if($? != 0)
{
 print STDERR "Failed to submit IGV conversion for $input\n";
 exit(1);
}

__END__

=head1 NAME

stepIGVTDF.pl

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
