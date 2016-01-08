#!/bin/bash

mappingtype=$1
params=$2
inputdir=$3
MAPPINGOUTDIR=$4
GENINDEX=$5
SERVICENAME=$6
JOBS=$7


edir="/project/umw_biocore/bin/workflow"
mkdir -p $MAPPINGOUTDIR

for k in $( ls $inputdir ); do
  file=$inputdir/$k

  echo $file
#  if [[ "$file"=~".fastq$" ]]; then
     fname=$(basename $file)
     s=${fname%.*}
     if [[ "$mappingtype" == "bwa" ]]; then
	BWA="module load bwa/0.7.5a;bwa"
        SAMTOOLS="module load samtools/0.0.19;samtools"
        command="$BWA aln $params $file > $MAPPINGOUTDIR/$s.sai; $BWA samse $params $MAPPINGOUTDIR/$s.sai $file > $MAPPINGOUTDIR/$s.sam;$SAMTOOLS view -bT $GENINDEX.fa $MAPPINGOUTDIR/$s.sam > $MAPPINGOUTDIR/$s.bam; $SAMTOOLS sort $MAPPINGOUTDIR/$s.bam $MAPPINGOUTDIR/$s.sorted"
        #echo $command
     elif [[ "$mappingtype" == "tophat1" ]]; then
        echo "Write Tophat with bowtie 1 support"
     elif [[ "$mappingtype" == "tophat2" ]]; then
	TOPHAT="module load tophat/2.0.9;tophat2"
	mkdir -p "$MAPPINGOUTDIR/$s"
 	command="$TOPHAT -o "$MAPPINGOUTDIR/$s" $params $file"

     elif [[ "$mappingtype" == "bowtie" ]]; then
        BOWTIE="module load bowtie/1.0.0;bowtie"
        SAMTOOLS="module load samtools/0.0.19;samtools"
        command="$BOWTIE $params $GENINDEX $file $MAPPINGOUTDIR/$k.sam > $MAPPINGOUTDIR/bowtie.res.$k 2>&1;$SAMTOOLS view -bT $GENINDEX.fa $MAPPINGOUTDIR/$k.sam > $MAPPINGOUTDIR/$k.bam; $SAMTOOLS sort $MAPPINGOUTDIR/$k.bam $MAPPINGOUTDIR/$k.sorted"
     fi
     echo $command
     $JOBS -n $SERVICENAME$k -c "$command"

  #fi 
done


