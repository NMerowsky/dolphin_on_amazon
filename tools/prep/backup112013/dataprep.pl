#!/share/bin/perl -w
# dataprep.pl
#    VERSION: Version 1 (31 August 2011)
#    AUTHOR: Alper Kucukural
#    PURPOSE: Remove adapter from 3' ends of the reads
#		    
#             
#    INPUT ARGUMENTS:  
#        inputfile = Input File
#        adapter   = Adapter Sequence
#        outfile   = Output File
#                         
#    OUTPUT FILES: Description of format of output files 
#        Fasta File
#

############## LIBRARIES AND PRAGMAS ################
 use POSIX;
 use Class::Struct;
 use File::Basename;
 use strict;
 use lib "/home/kucukura/progs/PipeLine";
 require lib::io;
 require lib::func;
#################### CONSTANTS ###################### 
my $dir="/home/kucukura/progs/PipeLine";
#################### VARIABLES ######################
my $inputfile = "";       #Input File
my $adapter = "";       #Adapter Sequence
my $len     = 0;       #len
my $outfile = "";       #Output File
my $trim = 0;       #If it is -1 don't use quality line

################### PARAMETER PARSUING ####################
 my $cmd=$0." ".join(" ",@ARGV); ####command line copy 
 
if(scalar(@ARGV) == 0){
    print "Usage:\n";
    print "$cmd  -i <inputfile> -a adapter -o outfile -t trim\n";
    exit(1);
}

# Parse the command line
while(scalar @ARGV > 0){
    my $next_arg = shift(@ARGV);
    if($next_arg eq "-i"){ $inputfile  = shift(@ARGV); }
    elsif($next_arg eq "-a"){ $adapter = shift(@ARGV); }
    elsif($next_arg eq "-o"){ $outfile = shift(@ARGV); }
    elsif($next_arg eq "-t"){ $trim = shift(@ARGV); }
}

my $name="";
open (IN, $inputfile) || die "can't open $!";
open (OUT,">".$outfile) || die "can't open $!";
my $i=0;
$adapter=substr($adapter, 0, 6);

while (my $line=<IN>)
{ 
  chomp($line);
  #if ($line=~/^@(HWI.*)/)
  if ($line=~/^@(.*)/)  
  {
     my $name="";
     if($trim>=0)
     {
       $name="@".$1;
     }
     else
     {
       $name=">".$1;
     }
     my $seq=<IN>; chomp($seq);
     my $plus=<IN>; chomp($plus);
     my $qual=<IN>; chomp($qual);
   my $alen=index($seq, $adapter);
   my $tag=$seq;
   if($alen>=20)
   { 
     $len=$alen;
   }
   
   if ($len<45 && $len>0)
   {
     $tag=substr($seq, 0, $len);
     $qual=substr($qual, 0, $len);
     $i++;
   }
  $len=length($seq);
  if(length($tag)>13)
  {
   $name=~s/\s+/\:/gi;
   print OUT $name."\n";
   print OUT $tag."\n";
   if ($trim>=0)
   {
    print OUT $plus."\n";
    print OUT $qual."\n";
   }
  }
  }

}

