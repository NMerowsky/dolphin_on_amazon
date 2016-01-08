#!/usr/bin/env perl
#########################################################################################
#                                       stepAfterFastQC.pl
#########################################################################################
#                              This program combines FastQC output.
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
	'servicename=s'       => \$servicename,
	'jobsubmit=s'    => \$jobsubmit,
) or die("Unionation of FastQCstep got unrecognized options.\n");
################### MAIN PROGRAM ####################
$outdir   = "$outdir/fastqc";
$uniteddir = "$outdir/UNITED";
$filesdir="$outdir/UNITED/files";
if (! -e "$filesdir")
{
 `mkdir -p $filesdir`;
 if($? != 0)
 {
  print STDERR "Failed to create output folder for united FastQC output\n";
  exit(1);
 }
}
open outPBQ, ">$uniteddir/per_base_quality.html" or die ("Failed to create per_base_quality.html\n");
print outPBQ "\<body\>\n";
open outPSQ, ">$uniteddir/per_sequence_quality.html"  or die ("Failed to create per_sequence_quality.html\n");
print outPSQ "\<body\>\n";
open outPBSC, ">$uniteddir/per_base_sequence_content.html" or die ("Failed to create per_base_sequence_content.html\n");
print outPBSC "\<body\>\n";
opendir($dir, $outdir);
@files = readdir($dir);
@dirs = grep {/\_fastqc$/} @files;
foreach $e(@dirs)
{
 `cp $outdir/$e/Images/per_base_quality.png $filesdir/pbq_$e.png`;
 $res+=$?;
 `cp $outdir/$e/Images/per_sequence_quality.png $filesdir/psq_$e.png`;
 $res+=$?;
 `cp $outdir/$e/Images/per_base_sequence_content.png $filesdir/pbsc_$e.png`;
 $res+=$?;
 if($res != 0)
 {
  print STDERR "Failed to copy FastQC file into unionized location\n";
  exit(1);
 }
 print outPBQ "\<div class=\"module\"\>\<h2 id=\"M1\"\> $e \<\/h2>\n\<p\>\<img class=\"indented\" src=\"./files/pbq_$e.png\"\>\<\/p\>\n\<\/div\>";
 print outPSQ "\<div class=\"module\"\>\<h2 id=\"M1\"\> $e \<\/h2>\n\<p\>\<img class=\"indented\" src=\"./files/psq_$e.png\"\>\<\/p\>\n\<\/div\>";
 print outPBSC "\<div class=\"module\"\>\<h2 id=\"M1\"\> $e \<\/h2>\n\<p\>\<img class=\"indented\" src=\"./files/pbsc_$e.png\"\>\<\/p\>\n\<\/div\>";
}
print outPBQ "\</body\>\n";
print outPSQ "\</body\>\n";
print outPBSC "\</body\>\n";

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

