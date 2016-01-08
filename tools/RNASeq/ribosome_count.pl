#!/share/bin/perl 

my $indir   = "after_ribosome";

opendir D, $indir or die "Could not open $indir\n";
my @pbss = grep /pbs$/, readdir(D);
closedir D;

open out, ">$indir/ribosome_map_stat";
print out "Sample\tTotal_pairs\tMapped_to_ribosome\n";

foreach my $d (@pbss){ 
 open in,"$indir/$d";
 <in>;<in>;<in>;<in>;<in>;
 $_=<in>; 
 @v=split;
 <in>;
 $_=<in>;
 s/\//\t/g;
 s/\.yesR/\t/g;
 @v1=split;
 print out "$v1[$#v1]";
 open in1, "$v[2]";
 $_=<in1>; 
 @v=split; 
 print out "\t$v[3]";
 $_=<in1>; 
 @v=split; 
 print out "\t$v[8]\n";
 close in;
}

close out;