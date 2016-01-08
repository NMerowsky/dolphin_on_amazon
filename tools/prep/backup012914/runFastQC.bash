#!/bin/bash

input=$1
outdir=$2

mkdir -p $outdir
/share/bin/FastQC/fastqc $input -o $outdir
