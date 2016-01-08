#!/bin/bash
#ALPER KUCUKURAL bam2bw Nov 20 2012

outdir=$1
name=$2
genomesize=$3
#galaxyout=$4
username=$4
version=$5
lname=$6

inputbam=$outdir/$name.sorted.bam
outputbg=$outdir/$name.bg
outputbw=$outdir/$name.bw

GCB=/project/umw_biocore/bin/bedtools/bin/genomeCoverageBed
W2BW=/project/umw_biocore/bin/wigToBigWig
module load bedtools/2.17.0 
#export PATH=$PATH:/project/umw_biocore/bin/bedtools/
echo $outputbg
$GCB -split -bg -ibam $inputbam -g $genomesize > $outputbg
$W2BW -clip -itemsPerSlot=1 $outputbg $genomesize $outputbw

#visdir=/isilon_temp/garber/genomeBrowser/$username/$lname

#mkdir -p $visdir

#cp $outputbw $visdir/.
#cp $inputbam $visdir/.
#cp $inputbam.bai $visdir/.
#cp $outputbg $visdir/.
#cp $outdir/$name.sorted.tdf $visdir/.
#cp $outdir/fastqc $visdir/. -R

echo "<a href=\"http://biocore.umassmed.edu/cgi-bin/hgTracks?db=$version&hgct_customText=track%20type=bigWig%20name=myBigBedTrack%20description=%22a%20bigBed%20track%22%20visibility=full%20bigDataUrl=http://biocore.umassmed.edu/genome/$username/$lname/$name.bw\">$name bigWig example  </a><br><br>" >> $outdir/results.html
echo "<a href=\"http://biocore.umassmed.edu/cgi-bin/hgTracks?db=$version&hgct_customText=track%20type=bam%20name=myBigBedTrack%20description=%22a%20bigBed%20track%22%20visibility=dense%20bigDataUrl=http://biocore.umassmed.edu/genome/$username/$lname/$name.sorted.bam\">$name bam example  </a><br><br>" >> $outdir/results.html

#cp $outdir/results.html $visdir/.
 

