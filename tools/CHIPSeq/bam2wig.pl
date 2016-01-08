#!/usr/bin/env perl
#########################################################################################
#                                       bam2bw.pl
#########################################################################################
#                    This program creates BigWig files for visualization
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
	'file=s'             => \$file,
	'genomesize=s'           => \$genomesize,
	'username=s'           => \$username,
	'versiongenome=s'	=> \$versiongenome,
	'libname=s'	=> \$libname,
	'publicfolder=s'           => \$publicfolder,
	'bedtoolsgencovbed=s'           => \$bedtoolsGenCovBed,
	'toolsucscwtbw=s'           => \$toolsucscWigToBigwig,
	'httppublicfolder=s'           => \$httppublicfolder,
	'corebrowserucsc=s'           => \$corebrowserucsc,
	'wisualweb=s'             => \$visualweb,
@VISUALWEB
) or die("bam2bw step got unrecognized options.\n");
######################################### MAIN PROGRAM ##################################
$inputbam="$outdir/$file.sorted.bam";
$outputbg="$outdir/$file.bg";
$outputbw="$outdir/$file.bw";
`$bedtoolsGenCovBed -split -bg -ibam $inputbam -g $genomesize > $outputbg`;
if($? != 0)
{
 print STDERR "Failed to create bedgraph for $file\n";
 exit(1);
}
`$toolsucscWigToBigwig -clip -itemsPerSlot=1 $outputbg $genomesize $outputbw`;
if($? != 0)
{
 print STDERR "Failed to create BigWig for $file\n";
 exit(1);
}

##############Public folder is conditioned on its existence###########################
if ((-e "$publicfolder")&&($visualweb eq "1"))
{
 if (! -e "$publicfolder/$libname")
 {
  `mkdir -p $publicfolder/$libname`;
#Manuel asked to do nonstop#  if($? != 0)
#  {
#   print STDERR "Failed to create a folder inside of your public folder\n";
#   exit(1);
#  }
  `cp $outdir/mapstat $publicfolder/$libname/.`;
 }
 `cp $outputbw $publicfolder/$libname/.`;
 $res+=$?;
 `cp $inputbam $publicfolder/$libname/.`;
 $res+=$?;
 `cp $inputbam.bai $publicfolder/$libname/.`;
 $res+=$?;
 `cp $outdir/$file.sorted.tdf $publicfolder/$libname/.`;
 $res+=$?;
 `cp $outdir/fastqc/UNITED $publicfolder/$libname/. -R`;
 $res+=$?;
 #if($res != 0)
 #{
 # print STDERR "Failed to copy stuff into public folder for visualization on UCSC browser\n";
 # exit(1);
 #}
 open out, ">>$outdir/results.html" or die ("Failed to create file with links for UCSC browser\n");
 print out "<a href=\"$corebrowserucsc\/hgTracks?db=$versiongenome&hgct_customText=track%20type=bigWig%20name=$file%20description=%22a%20bigBed%20track%22%20visibility=full%20bigDataUrl=$httppublicfolder\/$file.bw\">$file bigWig on UCSC</a><br><br>";
 print out "<a href=\"$corebrowserucsc\/hgTracks?db=$versiongenome&hgct_customText=track%20type=bam%20name=$file%20description=%22a%20bigBed%20track%22%20visibility=dense%20bigDataUrl=$httppublicfolder\/$file.sorted.bam\">$file bam on UCSC</a><br><br>";
 print out "<a href=\"$httppublicfolder\/$file.sorted.tdf\">A link with location of TDF file for IGV for $file</a><br><br>";
 close out;
}
__END__

=head1 NAME

bam2bw.pl

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
