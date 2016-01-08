#!/share/bin/perl -w
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

 $inputfile=~s/\,/\:/g;
 my @v=split/\:/,$inputfile;
 my %seen=();
 @v = grep { ! $seen{$_} ++ } @v;
`mkdir -p $outdir`;
for (my $i1=0;$i1<=$#v;$i1++)
{
 my $inputfile=$v[$i1];
 print $inputfile."\n";
 open IN, "$inputfile";
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
     my $name="$outdir/$filename.$j";
     open OUT, ">$name";
     $j++;
   }
   print OUT; 
   $i++;
 }
 
 close IN;
}
