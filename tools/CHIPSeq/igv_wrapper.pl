#!/usr/bin/env perl
#########################################################################################
#                                       igv_wrapper.pl
#########################################################################################
#                    This program runs IGV converter for each output file
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
	'outdir=s'            => \$outdir,
	'input=s'             => \$input,
	'samtools=s'          => \$samtools,
	'perlscript=s'        => \$perlscript,
	'nameservice=s'       => \$servicename,
	'fastagenome=s'       => \$fastagenome,
        'mtools=s'       => \$mtools,
        'jobsubmit=s'    => \$jobsubmit,
) or die("Unrecognized optioins.\n");
######################################### MAIN PROGRAM ##################################
$input=~s/\,/\:/g;
@files=split(/:/,$input);
@files = grep { ! $seen{$_} ++ } @files;  
for($i=0;$i<@files;$i++) 
{
 ($filename, $directories, $suffix) = fileparse($files[$i]);
 $com="$perlscript -i $outdir/$filename.sorted -o $outdir -f $fastagenome -s \'$samtools\' -m \'$mtools\'\n";
 $job=$jobsubmit." -n ".$servicename."_".$i." -c \"$com\"";
 `$job`;
 if($? != 0)
 {
  print STDERR "Failed to run IGV conversion for $filename\n";
  exit(1);
 } 
}

__END__

=head1 NAME

igv_wrapper.pl

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
