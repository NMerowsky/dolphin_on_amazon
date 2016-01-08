#!/bin/bash

input=$1
outdir=$2

mkdir -p $outdir
module load fastqc/0.10.1
fastqc $input -o $outdir
