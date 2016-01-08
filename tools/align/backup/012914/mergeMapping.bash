#!/bin/bash

INPUTDIR=$1
FILE_EXT=$2
OUTDIR=$3
NAME=$4
MERGETYPE=$5
SAMTOOLS=/isilon_temp/garber/bin/samtools

 NUMOFLINES=$(ls $INPUTDIR/$NAME.*.$FILE_EXT|wc -l|awk '{print $1}')
 if [[ $NUMOFLINES == 1 ]]; then
    cp $INPUTDIR/$NAME.*.$FILE_EXT $OUTDIR/$NAME.tmp.bam
    $SAMTOOLS view -F12 $OUTDIR/$NAME.tmp.bam -b > $OUTDIR/$NAME.bam
    $SAMTOOLS sort $OUTDIR/$NAME.bam $OUTDIR/$NAME.sorted
 else

   if [[ "$MERGETYPE" =~ "cat$" ]]; then
   
      cat $INPUTDIR/$NAME.*.$FILE_EXT > $OUTDIR/$NAME.$FILE_EXT
   elif [[ "$MERGETYPE" =~ "bam$" ]]; then
      $SAMTOOLS merge $OUTDIR/$NAME.tmp.bam $INPUTDIR/$NAME.*.$FILE_EXT -f
      $SAMTOOLS view -F12 $OUTDIR/$NAME.tmp.bam -b > $OUTDIR/$NAME.bam
      $SAMTOOLS sort $OUTDIR/$NAME.bam $OUTDIR/$NAME.sorted
   fi
 fi
