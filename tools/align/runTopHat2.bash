#!/bin/bash

$inputdir=$1
$outdir=$2
$inputannot=$2

$dir=/isilon_temp/garber/bin/workflow
G=$d"/gtf/hg19.gtf"
I=$d"/bowtie/indexes/hg18"

for k in $( ls $inputdir ); do
 file=$inputdir/$k

 `mkdir -p $outd`
 tophatdir=/isilon_temp/garber/bin/tophat-2.0.8.Linux_x86_64
 $tophatdir/tophat -p 1 --segment-length 20 -g 1 --bowtie1 --no-coverage-search -o $outdir -G $G $I $file
 
done
