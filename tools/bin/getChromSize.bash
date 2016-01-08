#!/bin/bash
# ALPER KUCUKURAL
# USAGE:
# getChromSize.bash hg18 OUT_DIR/hg18.chrom.sizes

genome=$1
outname=$2

mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e "select chrom, size from "$genome".chromInfo order by chrom"> $outname
