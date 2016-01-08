#!/bin/bash

INPUTDIR=$1
FILE_EXT=$2
OUTDIR=$3
NAME=$4
MERGETYPE=$5

module load samtools/0.0.19

SAMTOOLS=samtools

 NUMOFLINES=$(ls $INPUTDIR/$NAME.*.$FILE_EXT|wc -l|awk '{print $1}')
 if [[ $NUMOFLINES == 1 ]]; then
    cp $INPUTDIR/$NAME.*.$FILE_EXT $OUTDIR/$NAME.tmp.bam
    $SAMTOOLS view -F12 $OUTDIR/$NAME.tmp.bam -b > $OUTDIR/$NAME.bam
    $SAMTOOLS sort $OUTDIR/$NAME.bam $OUTDIR/$NAME.sorted
    $SAMTOOLS view -h $OUTDIR/$NAME.sorted.bam > $OUTDIR/$NAME.sorted.sam
 else

   if [[ "$MERGETYPE" == "cat" ]]; then
   
      cat $INPUTDIR/$NAME.*.$FILE_EXT > $OUTDIR/$NAME.$FILE_EXT
   elif [[ "$MERGETYPE" == "bam" ]]; then
      echo "Merging..."
      echo "$SAMTOOLS merge $OUTDIR/$NAME.tmp.bam $INPUTDIR/$NAME.*.$FILE_EXT -f"
      $SAMTOOLS merge $OUTDIR/$NAME.tmp.bam $INPUTDIR/$NAME.*.$FILE_EXT -f
      echo "Eliminate unmapped reads"
      echo "$SAMTOOLS view -F12 $OUTDIR/$NAME.tmp.bam -b > $OUTDIR/$NAME.bam"
      $SAMTOOLS view -F12 $OUTDIR/$NAME.tmp.bam -b > $OUTDIR/$NAME.bam
      echo "Sorting..."
      echo "$SAMTOOLS sort $OUTDIR/$NAME.bam $OUTDIR/$NAME.sorted"
      $SAMTOOLS sort $OUTDIR/$NAME.bam $OUTDIR/$NAME.sorted
      echo "Sam conversion"
      echo "$SAMTOOLS view -h $OUTDIR/$NAME.sorted.bam > $OUTDIR/$NAME.sorted.sam"
      $SAMTOOLS view -h $OUTDIR/$NAME.sorted.bam > $OUTDIR/$NAME.sorted.sam
   fi
 fi
