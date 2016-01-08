#!/usr/bin/env perl
#########################################################################################
#                                       zinba_exec.pl
#########################################################################################
#                                  Running R script
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### PARAMETER PARSUING ##############################
$GENOME =$ARGV[0];
$MAPPABILITY =$ARGV[1];
$REFINEPEAKS =$ARGV[2];
$FOLDER =$ARGV[3];
$FOLDERI =$ARGV[4];
$FOLDERP =$ARGV[5];
$FILETYPE =$ARGV[6];
$THRESHOLD =$ARGV[7];
$EXTENSION =$ARGV[8];
$BROAD =$ARGV[9];
$PRINTFULLOUT =$ARGV[10];
$INTERACTION =$ARGV[11];
$MODE =$ARGV[12];
$FDR =$ARGV[13];
$ATHRESH =$ARGV[14];
$BIN =$ARGV[15];
$DATASETS =$ARGV[16];
$GENOMEVERSION =$ARGV[17];
$OUTDIR =$ARGV[18];
$FOLDERPA=$ARGV[19];
$OUTFILE=$ARGV[20];
$STEPNAME =$ARGV[21];
$JOBID =$ARGV[22];
######################################### MAIN PROGRAM ##################################

$JOBID=~s/,/ /g;

print "OUTDIR".$OUTDIR."\n";

open out, ">$OUTDIR/zinba.R" or die "Failed to open a file for Zinba R script writing";

print out "library(zinba)\n";
#print out "generateAlignability(\n";
#print out "  mapdir=\"$DATASETS/$GENOME/$GENOMEVERSION/\",\n"; 	#mappability directory from unpacked mappability files
#print out "  outdir=$OUTDIR,\n"; 	#directory for processed files, used later in analysis
#print out "  athresh=$ATHRESH,\n"; 	#number of hits per read allowed during mapping process
#print out "  extension=$EXTENSION,\n"; 	#average fragment library length
#print out "  twoBitFile=\"$DATASETS/$GENOME/$GENOMEVERSION/$GENOMEVERSION.2bit\"\n"; 	#path to downloaded genome build file in .2bit format
#print out ")\n";

print out "basealigncount(\n";
print out "  inputfile=\"$FOLDER\",\n"; 	#mapped sample reads
print out "  outputfile=\"$OUTDIR/basecount.file\",\n"; 	# output path
print out "  extension=$EXTENSION,\n"; 	#average fragment library length
print out "  filetype=\"$FILETYPE\",\n"; 	#either "bed", "bowtie", or "tagAlign"
print out "  twoBitFile=\"$DATASETS/$GENOME/$GENOMEVERSION/$GENOMEVERSION.2bit\"\n"; 	#path to downloaded genome build file in .2bit format
print out ")\n";

print out "zinba(\n";
print out "  refinepeaks=$REFINEPEAKS,\n"; 	#refine peaks? 1 for yes, 0 for no
print out "  seq=\"$FOLDER\",\n"; 	#path to mapped experimental reads
print out "  input=\"$FOLDERI\",\n"; 	#path to mapped input reads if available (default is "none")
print out "  filetype=\"$FILETYPE\",\n"; 	#either 'bed', 'bowtie', or 'tagAlign'
print out "  numProc=4,\n"; 	#Number of processors
print out "  threshold=$THRESHOLD,\n"; 	#FDR threshold, default is 0.05
print out "  align=\"$FOLDERPA\",\n"; 	#path to alignability directory
print out "  twoBit=\"$DATASETS/$GENOME/$GENOMEVERSION/$GENOMEVERSION.2bit\",\n"; 	#path to genome build in .2bit format
print out "  outfile=\"$OUTDIR/$OUTFILE\",\n"; 	#prefix for outputted files
print out "  extension=$EXTENSION,\n"; 	#average fragment library length (size selected)
print out "  basecountfile=\"$OUTDIR/basecount.file\",\n"; 	#path to basecount file if refinepeaks is 1
print out "  broad=".uc(substr($BROAD,0,1)).",\n"; 	#broad setting, TRUE or FALSE (default)
print out "  printFullOut=".(uc(substr($PRINTFULLOUT,0,1))).",\n"; 	#print original data with enrichment estimates, 1 for yes (more space required), 0 for no (default)
print out "  interaction=".uc(substr($INTERACTION,0,1)).",\n"; 	#whether or not to considering interaction during model selection, TRUE (default) or FALSE
print out "  mode=\"$MODE\",\n"; 	#either "peaks" for peak calling (default) or "CNV" for calling likely amplified CNV regions for reads in "seq" (input reads are best)
print out "  FDR=".uc(substr($FDR,0,1))."\n"; 	#either TRUE (default) or FALSE. If false, then uses posterior probability to threshold peaks using 1-threshold
print out ")\n";
close out;

  $com="module load R/3.0.2;R --no-save < $OUTDIR/zinba.R";
  $job=$JOBID." -n ".$STEPNAME." -c \"$com\"";
  $q=" ";
  $job=~s/\,/$q/g;
  `$job`;
  print $job."\n";
  if($? != 0)
  {
   print STDERR "Failed to submit job\n";
   exit(1);
  }

__END__

=head1 NAME

zinba_exec.pl

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
