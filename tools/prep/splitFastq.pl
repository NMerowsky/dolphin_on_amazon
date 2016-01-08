#!/usr/bin/env perl
# dataprep.pl
#    VERSION: Version 1 (31 August 2011)
#    AUTHOR: Alper Kucukural
#    PURPOSE: split FASTQ file 10million reads and write the output into output directory
#		    
#             
#    INPUT ARGUMENTS:  
#        inputfile = Input File
#        outfile   = Output Dir
#                         
#    OUTPUT FILES: 
#        Fasta Files
#

############## LIBRARIES AND PRAGMAS ################
use POSIX;
use Class::Struct;
use File::Basename;
use strict;
#################### CONSTANTS ###################### 
#################### VARIABLES ######################
 my $inputfile = "";       #Input File
 my $num = 1e+7;
 my $outdir = "";       #Output File

################### PARAMETER PARSUING ####################
 my $cmd=$0." ".join(" ",@ARGV); ####command line copy 
 
if(scalar(@ARGV) == 0){
    print "Usage:\n";
    print "$cmd  -i <inputfile> -n #of reads in each file -o outdir\n";
    exit(1);
}

# Parse the command line
while(scalar @ARGV > 0){
    my $next_arg = shift(@ARGV);
    if($next_arg eq "-i"){ $inputfile  = shift(@ARGV); }
    elsif($next_arg eq "-o"){ $outdir = shift(@ARGV); }
    elsif($next_arg eq "-n"){ $num = shift(@ARGV); }
}

 my @v1=split/\./,$inputfile;
 my $inputfile1=$inputfile;
 if($v1[$#v1] eq "z" || $v1[$#v1] eq "gz")
 {
  $inputfile1="$inputfile1.unz";
  `gunzip -c -d $inputfile > $inputfile1`;
 }
 print $inputfile1."\n";
 open IN, "$inputfile1";
 my  $i=0;
 my $j=1;

 while(<IN>)
 { 
   if (($i % $num)==0)
   {
     if ($i>0)
     {
       close OUT;
     }
     my($filename, $directories, $suffix) = fileparse($inputfile);
     `mkdir $outdir`;
     my $name="$outdir/$filename.$j";
     open OUT, ">$name";
     $j++;
   }
   print OUT; 
   $i++;
 }
 
 close IN;
