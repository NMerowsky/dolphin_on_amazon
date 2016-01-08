#!/usr/bin/env perl
#########################################################################################
#                                       bam2bw_wrapper.pl
#########################################################################################
#                    This program in charge of initiating BW creation.
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### LIBRARIES AND PRAGMAS ###########################
use Getopt::Long;
####################################### PARAMETER PARSUING ##############################
GetOptions( 
	'command=s'           => \$command,
	'outdir=s'            => \$outdir,
	'input=s'             => \$input,
	'genomesize=s'             => \$genomesize,
	'username=s'             => \$username,
	'wversion=s'             => \$wersion,
	'libname=s'             => \$libname,
	'publicfolder=s'           => \$publicfolder,
	'bedtoolsgencovbed=s'           => \$bedtoolsGenCovBed,
	'toolsucscwtbw=s'           => \$toolsucscWigToBigwig,
	'httppublicfolder=s'           => \$httppublicfolder,
	'acorebrowserucsc=s'           => \$acorebrowserucsc,
	'visualweb=s'             => \$visualweb,
	'servicename=s'       => \$servicename,
	'jobsubmit=s'    => \$jobsubmit,
) or die("Bam2bw wrapper got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
$input=~s/\,/\:/g;
@files=split(/:/,$input);
@files = grep { ! $seen{$_} ++ } @files;
for($i=0;$i<@files;$i++) 
{
 @fullp=split/\//,$files[$i];
 $com="$command -o $outdir -f $fullp[$#fullp] -g $genomesize -u $username -v $wersion -w $visualweb -l $libname -p $publicfolder -b \'$bedtoolsGenCovBed\' -t \'$toolsucscWigToBigwig\' -h \'$httppublicfolder\' -c \'$acorebrowserucsc\'\n";
 $job=$jobsubmit." -n ".$servicename."_".$i." -c \"$com\"";
 `$job`;
 if($res != 0)
 {
  print STDERR "Failed to submit BigWig creation wrapper for $fullp[$#fullp]\n";
  exit(1);
 } 
 print $job."\n";
}

__END__

=head1 NAME

bam2bw_wrapper.pl

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
