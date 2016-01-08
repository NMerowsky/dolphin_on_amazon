#!/bin/bash

params=$1
inputfile=$2
outfile=$3

/share/bin/bwa aln $params $inputfile > $outfile

