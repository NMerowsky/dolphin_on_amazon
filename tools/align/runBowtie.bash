#!/bin/bash

$inputdir=$1
$outdir=$2

$dir=/isilon_temp/garber/bin/workflow
I=$d"/bowtie/indexes/hg18"

for k in $( ls $inputdir ); do
 file=$inputdir/$k

 `mkdir -p $outd`
 bowtiedir=/isilon_temp/garber/bin/bowtie
 bowtiedir/bowtie -n 1 -q $I $file
 
done
