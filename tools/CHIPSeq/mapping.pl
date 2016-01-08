#!/usr/bin/env perl
#########################################################################################
#                                       mapping.pl
#########################################################################################
#                    This program does Bowtie1 mapping, conversion into BAM
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### LIBRARIES AND PRAGMAS ###########################
use Getopt::Long;
####################################### PARAMETER PARSUING ##############################
GetOptions( 
	'mapcommand=s'	=> \$mapper,
	'program=s'           => \$param,
	'geneindex=s'           => \$geneindex,
	'fastq=s'            => \$fastq,
	'e=s'            => \$e,
	'outdir=s'            => \$outdir,
	'rmatcommand=s'	=> \$formatter,
) or die("Mapping step got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
my $com="$mapper $param $geneindex $fastq $outdir/$e.temp 2>$outdir/$e.mapstat";
print $com."\n";
`$com`;
if($? != 0)
{
 print STDERR "Failed to do Bowtie mapping for $fastq\n";
 exit(1);
}
`cat $outdir/$e.temp | awk \'\{if(\$4 != 0) print(\$0)\}\' > $outdir/$e.sam`;
if($? != 0)
{
 print STDERR "Failed to clean Bowtie mapped file for $fastq\n";
 exit(1);
}
`rm $outdir/$e.temp; $formatter view -b -S $outdir/$e.sam > $outdir/$e.bam`; 
if($? != 0)
{
 print STDERR "Failed to convert sam to bam for $e\n";
 exit(1);
}
`$formatter sort $outdir/$e.bam $outdir/$e.sorted`;
if($? != 0)
{
 print STDERR "Failed to sort bam for $e\n";
 exit(1);
}

__END__

=head1 NAME

mapping.pl

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
