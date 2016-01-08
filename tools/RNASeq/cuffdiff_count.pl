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
print STDERR "$d\n";
 my $dir = "${indir}/$d";
 $i++;
 $a[$i]=$d;
 open in,"${dir}/gene_exp.diff";
 $d=~s/pipe.cuffdiff/pair/;
 open out, ">${indir}/$d.gene_count_difference";
 print out "Genes\ttranscripts\tLocus\tValue1\tValue2\tLog2ratio\tpvalue\tqvalue\n";
 $_=<in>;
 while(<in>)
 {
  @v=split; 
  if((abs($v[9])>=1.5)&&($v[12]<=0.01))
  {
   @v1=split/\,/, $v[2];
   for($i=0;$i<=$#v1;$i++)
   {
    print out "$nme{$v1[$i]}\,"
   }
   print out "\t$v[2]\t$v[3]\t$v[7]\t$v[8]\t$v[9]\t$v[11]\t$v[12]\n";
  }
 }
 close in;
 close out;
}
