#!/share/bin/perl 
#use strict;

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

my $indir   = "after_ribosome/cufflinks";
my $conversion = "/isilon_temp/garber/genome_data/$genome/$version/ucsc_into_genesymbol";

open in,"$conversion";
while(<in>)
{
 @v=split;
 $nme{$v[0]}=$v[1];
}

opendir D, $indir or die "Could not open $indir\n";
my @alndirs = grep /notR$/, readdir(D);
closedir D;

foreach my $d (@alndirs){ 
print STDERR "$d\n";
 my $dir = "${indir}/$d";
 $i++;
 $a[$i]=$d;
 open in,"${dir}/genes.fpkm_tracking";
 $_=<in>;
 while(<in>)
 {
  @v=split; 
  $b{$v[0]}{$i}=$v[9];
  $c{$v[0]}=$v[6];
 }
 close in;
}

open out, ">${indir}/transcript_expression_fpkm";

print out "gene\ttranscript\tLocation";
for($j=1;$j<=$i;$j++)
{
 print out "\t$a[$j]";
}
print out "\n";

foreach $key (keys %b)
{
 print out "$nme{$key}\t$key\t$c{$key}";
 for($j=1;$j<=$i;$j++)
 {
  print out "\t$b{$key}{$j}";
 }
 print out "\n";
}

close out;