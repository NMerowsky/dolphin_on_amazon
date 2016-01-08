#!/usr/bin/env perl
#########################################################################################
#                                       mapping_wrapper.pl
#########################################################################################
#               This program does wrapping for Bowtie1 mapping, conversion into BAM
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
	'program=s'           => \$param,
	'bowtie=s'           => \$bowtie,
	'mapcommand=s'	=> \$mapper,
	'formatcommand=s'	=> \$formatter,
	'geneindex=s'           => \$geneindex,
	'wrapped=s'           => \$wrapped,
	'servicename=s'       => \$servicename,
	'jobsubmit=s'    => \$jobsubmit,
) or die("Mapping_wrapper step got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
if (! -e "$outdir")
{
 `mkdir -p $outdir`;
 if($? != 0)
 {
  print STDERR "Failed to create output folder for Bowtie mapped files\n";
  exit(1);
 }
}
opendir $dir, "$inputdir" or die "Cannot open directory with files for mapping!";
@files = readdir $dir;
closedir $dir;
foreach $e(@files)
{
  next if ($e =~ m/^\./);
  $fastq="$inputdir/$e";
  if($bowtie eq "bowtie")
  {
   $com="$wrapped -m \\\"$mapper\\\" -p \\\"$param\\\" -g \\\"$geneindex\\\" -f \\\"$fastq\\\" -e \\\"$e\\\" -o \\\"$outdir\\\" -r \\\"$formatter\\\"";
   $job=$jobsubmit." -n ".$servicename."_".$e." -c \"$com\"";
   `$job`;
   if($? != 0)
   {
    print STDERR "Failed to submit mapping for $e\n";
    exit(1);
   }   
   print $job."\n";
  }
}

__END__

=head1 NAME

mapping_wrapper.pl

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
