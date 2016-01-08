#!/bin/bash
#ALPER KUCUKURAL sam2bam Nov 20 2012


genome=$1
inputsam=$2
outputbam=$3

/isilon_temp/garber/bin/workflow/scripts/tools/bin/samtools view -bT $genome $inputsam > $outputbam.pre
/isilon_temp/garber/bin/workflow/scripts/tools/bin/samtools sort $outputbam.pre > $outputbam
if [ -f $outputbam.pre ]
  then
    rm -rf $outputbam.pre
fi
if [ -f $inputsam ]
  then
    rm -rf $inputsam
fi

