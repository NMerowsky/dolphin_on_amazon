#!/usr/bin/env perl
#########################################################################################
#                                       agg_plot.pl
#########################################################################################
#                    This program perform ACT aggregation for the mapped tags
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
 	'bedtoolsgencov=s'       => \$bedtoolsgencov,
 	'indir=s'       => \$indir,
 	'filename=s'       => \$filename,
	'genome=s'       => \$genome, #(hg19.chromInfo)
 	'outdir=s'       => \$outdir,
	'program=s'         => \$program,
	'reference=s'    => \$reference, #(refseq4col)
 	'creationpdf=s'       => \$creationpdf,
) or die("Unrecognized optioins for ACT aggregator.\n");
################### MAIN PROGRAM ####################
`$bedtoolsgencov -bga -ibam $indir/$filename.sorted.bam -g $genome > $outdir/$filename.bed`;
if($? != 0)
{
 print STDERR "Failed to create a bedfile for ACT for $filename\n";
 exit(1);
}
`awk '{print \$1\"\\t\"\$2\"\\t\"\$4}' $outdir/$filename.bed > $outdir/$filename.sig`;
if($? != 0)
{
 print STDERR "Failed to reformat a bedfile for ACT for $filename\n";
 exit(1);
}
`python $program --nbins=50 --mbins=50 --radius=5000 --region $reference $outdir/$filename.sig > $outdir/$filename.aggregation_plot.out`;
if($? != 0)
{
 print STDERR "Failed to run ACT for $filename\n";
 exit(1);
}
`$creationpdf --args $outdir/$filename.aggregation_plot.out`;
if($? != 0)
{
 print STDERR "Failed to create PDF after running ACT for $filename\n";
 exit(1);
}

__END__

=head1 NAME

agg_plot.pl

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