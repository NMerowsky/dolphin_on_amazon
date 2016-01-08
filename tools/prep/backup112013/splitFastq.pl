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

my @arr= fileparse("$inputfile", qr/\.[^.]*/);
print $arr[0].":".$arr[1].":".$arr[2]."\n";
my $name = $arr[0];
my $ext  = $arr[2];
open (IN, $inputfile) || die "can't open $!";
my $i=0;
`mkdir -p $outdir`;
my $j=1;
while (my $line=<IN>)
{ 
  if ($i % $num == 0)
  {
    close(OUT);
    open(OUT, ">$outdir/".$name."_".$j.$ext);
    $j++;
  }
  print OUT $line; 
  $i++;
}

