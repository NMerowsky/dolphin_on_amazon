#!/share/bin/perl 

open in,"input.txt";
 $folder=<in>;
 $_=<in>;
 $diff=<in>;
 $_=<in>;
 @v=split; 
 $genome=$v[0];
 $_=<in>;
 @v=split; 
 $version=$v[0];
close in;

my $indir   = "after_ribosome/cuffdiff";
my $conversion = "/isilon_temp/garber/genome_data/$genome/$version/ucsc_into_genesymbol";

open in,"$conversion";
while(<in>)
{
 @v=split;
 $nme{$v[0]}=$v[1];
}

opendir D, $indir or die "Could not open $indir\n";
my @alndirs = grep /output$/, readdir(D);
closedir D;

foreach my $d (@alndirs){ 
 my $dir = "${indir}/$d";
 $i++;
 $a[$i]=$d;

 open in,"${dir}/genes.read_group_tracking";
 <in>;
 $rmax=0;
 while(<in>)
 {
  @v=split;
  $geneinf{$v[0]}{$v[1]}{$v[2]}{1}=$v[3]; #condi is q1/q2 but replicas many
  $geneinf{$v[0]}{$v[1]}{$v[2]}{2}=$v[6];
  if($rmax<$v[2]){$rmax=$v[2];}
 }
 close in;

 open in,"${dir}/gene_exp.diff";
 $d=~s/pipe.cuffdiff/pair/;
 open out, ">${indir}/$d.gene_count_difference_large";
 print out "Genes\ttranscripts\tLocus\tValue1\tValue2\tLog2ratio\tpvalue\tqvalue";
 for($i1=0;$i1<=$rmax;$i1++)
 {
  print out "\tS1FPKM$i1\tS1RawCount$i1";
 }
 for($i1=0;$i1<=$rmax;$i1++)
 {
  print out "\tS2FPKM$i1\tS2RawCount$i1";
 }
 print out "\n";

 $_=<in>;
 while(<in>)
 {
  @v=split; 
   @v1=split/\,/, $v[2];
   for($i=0;$i<=$#v1;$i++)
   {
    print out "$nme{$v1[$i]}\,"
   }
   print out "\t$v[2]\t$v[3]\t$v[7]\t$v[8]\t$v[9]\t$v[11]\t$v[12]";
   for($i1=0;$i1<=$rmax;$i1++)
   {
    print out "\t$geneinf{$v[0]}{$v[4]}{$i1}{2}\t$geneinf{$v[0]}{$v[4]}{$i1}{1}";
   }
   for($i1=0;$i1<=$rmax;$i1++)
   {
    print out "\t$geneinf{$v[0]}{$v[5]}{$i1}{2}\t$geneinf{$v[0]}{$v[5]}{$i1}{1}";
   }
   print out "\n";
 }
 close in;
 close out;
}
