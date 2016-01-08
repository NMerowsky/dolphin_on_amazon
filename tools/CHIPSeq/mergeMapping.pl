#!/usr/bin/env perl
#########################################################################################
#                                       mergeMapping.pl
#########################################################################################
#                    This program does merging and sorting output of Bowtie
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
	'input=s'             => \$inputdir,
	'program=s'           => \$program,
	'fileext=s'           => \$file_ext,
	'name=s'		=> \$name,
) or die("Fastq_split step got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
$a=`ls $inputdir/$name.*.$file_ext|wc -l|awk '{print $1}'`;
if($a == 1)
{
 `cp $inputdir/$name.*.$file_ext $outdir/$name.tmp.bam`;
}
else
{
 `$program merge $outdir/$name.tmp.bam $inputdir/$name.*.$file_ext -f`;
 if($? != 0)
 {
  print STDERR "Failed to merge files related to $name\n";
  exit(1);
 }
}
`$program sort $outdir/$name.tmp.bam $outdir/$name.sorted`;
if($? != 0)
{
 print STDERR "Failed to sort merged file related to $name\n";
 exit(1);
}
`$program view -h $outdir/$name.sorted.bam > $outdir/$name.sorted.sam`;
if($? != 0)
{
 print STDERR "Failed to create sam from sorted bam for $name\n";
 exit(1);
}
if(! -e "$outdir/mapstat")
{
 open out, ">$outdir/mapstat" or die ("Failed to create a file for mapping statistics\n");
 print out "Filename\tTotal\tAligned\tFailed\tMultimappers\n";
 close out;
}
opendir $dir, "$inputdir" or die "Cannot open directory with mapped files!";
@files = readdir $dir;
closedir $dir;
foreach $e(@files)
{
  if (($e =~ /^$name/)&&($e =~ /mapstat$/))
  {
   open in, "$inputdir/$e" or die ("Failed to read mapping statistics $e\n");
   @v=split/\s/,<in>;
   $tot+=$v[3];
   @v=split/\s/,<in>;
   $mapped+=$v[8];
   @v=split/\s/,<in>;
   $failed+=$v[6];
   @v=split/\s/,<in>;
   $multiple+=$v[8];
   close in;
  } 
}
open out, ">>$outdir/mapstat" or die ("Failed to write into a file for mapping statistics\n");
print out "$name\t$tot\t$mapped\t$failed\t$multiple\n";
close out;

__END__

=head1 NAME

mergeMapping.pl

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
