#!/bin/bash

OUTDIR=$1
TARFILE=$2

cd $OUTDIR
tar cvfz $TARFILE CRISPRSeek offtargetanalysis.R 
