#!/usr/bin/env perl
#########################################################################################
#                                       mergeMapping_wrapper.pl
#########################################################################################
#                    This program starts merging for mapped Bowtie output
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
	'command=s'       => \$command,
	'mappedout=s'       => \$mappedout,
 	'filext=s'       => \$filext, 
 	'outdir=s'       => \$outdir,
     	'input=s'       => \$input,
	'toolssam=s'	=>\$toolssam,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
) or die("Fastq_split step got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
$input=~s/\,/\:/g;
@v=split/\:/,$input;
@v = grep { ! $seen{$_} ++ } @v;
for($i=0;$i<@v;$i++) 
{
 ($filename, $directories, $suffix) = fileparse($v[$i]);
 $com="$command -i $mappedout -f $filext -o $outdir -n $filename -p \'$toolssam\';\n";
 $job=$jobsubmit." -n ".$servicename."_".$i." -c \"$com\"";
 `$job`;
 if($? != 0)
 {
  print STDERR "Failed to submit file merging job for $filename\n";
  exit(1);
 }
}

__END__

=head1 NAME

mergeMapping_wrapper.pl

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
