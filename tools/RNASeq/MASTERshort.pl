#!/usr/bin/perl

if($#ARGV eq -1)
{
 print STDERR "\n";
 print STDERR "This set of scripts will map RNA-seq and\n";
 print STDERR "count number of tags in your region of interest.\n";
 print STDERR "After that differential expression will be called and\n";
 print STDERR "data will be prepared for visualization.\n";
 print STDERR "Usage:\n";
 print STDERR "perl MASTER.pl input.txt (from the folder with files description)\n";
 print STDERR "The script expects to see input.txt as in attached example.\n";
 print STDERR "The first line is a folder with executables, do not change unless use custom version.\n";
 print STDERR "The second line is description how data are grouped (pairs, experiments).\n";
 print STDERR "The third line is description how to do differential expression analysis.\n";
 print STDERR "The fourth line is organism.\n";
 print STDERR "The fifth line is genomic version for the organism.\n";
 print STDERR "Be sure that input.txt is written as txt file.\n";
 print STDERR "If you use some special software like Word select save as txt \n";
 print STDERR "and select put LF at the end of line.\n";

 exit(0);
}
else
{
 ##########################Update input ##########################
 open in,"input.txt";
 open out, ">aaaaaaaaa";
 while(<in>)
 {
  if(/\n/){}
  else
  {
   s/\r/\n/g;
  }
  print out;
 }
 
 `mv aaaaaaaaa input.txt`;
  ##########################Read input ##########################
 open in,"input.txt";
 $_=<in>;
 @folder=split;
 close in;
 ##########################Perform mapping ##########################
 `perl $folder[0]/uhoPBScreatorHPCCbowtie.pl`;
 $temp=`qstat | wc -l`;
 while($temp > 0)
  {
   sleep 100;
   $temp=`qstat | wc -l`;
  }
 ##########################Perform tophating ##########################
 `perl $folder[0]/uhoPBScreatorHPCCtophat2.pl`;
 $temp=`qstat | wc -l`;
 while($temp > 0)
  {
   sleep 100;
   $temp=`qstat | wc -l`;
  }
 sleep 100;
 ##########################Perform igv browser ##########################
 `perl $folder[0]/uhoPBScreatorHPCCigvTDF.pl`;
 $temp=`qstat | wc -l`;
 while($temp > 0)
  {
   sleep 100;
   $temp=`qstat | wc -l`;
  }
 ##########################Perform cufflinking ##########################
 #`perl $folder[0]/uhoPBScreatorHPCCcufflinks.pl`;
 #$temp=`qstat | wc -l`;
 #while($temp > 0)
 # {
 #  sleep 100;
 #  $temp=`qstat | wc -l`;
 # }
 ##########################Perform cuffdiff ##########################
 `perl $folder[0]/uhoPBScreatorHPCCcuffdiff.pl`;
 $temp=`qstat | wc -l`;
 while($temp > 0)
  {
   sleep 100;
   $temp=`qstat | wc -l`;
  }
 ##########################Perform Picard statistics ##########################
 `perl $folder[0]/uhoPBScreatorHPCCpicard.pl`;
 $temp=`qstat | wc -l`;
 while($temp > 0)
  {
   sleep 100;
   $temp=`qstat | wc -l`;
  }
 `perl $folder[0]/picard_count.pl`;
 ##########################Isoforms FPKM ##########################
 #`perl $folder[0]/cufflinks_count.pl`;
 ##########################Genes difference ##########################
 `perl $folder[0]/cuffdiff_count.pl`;
 `perl $folder[0]/cuffdiff_count_large.pl`;
 ##########################Ribosome mapping ##########################
 `perl $folder[0]/ribosome_count.pl`;
}
