#!/usr/bin/env perl

open(IN, $ARGV[0]);
$type=$ARGV[1];
my $name="";
my $seq="";
my $i=0;
while(my $line=<IN>)
{
  chomp($line);
  if($line=~/^>(.*)/)
  {
    $i++ if (length($seq)>0);
    print "$name\t1\t".length($seq)."\t$name\t0\t+\n" if (length($seq)>0); 
    $name="$1";
    $seq="";
  }
  else
  {
    $seq.=$line;
  }
}
print "$name\t1\t".length($seq)."\t$name\t0\t+\n" if (length($seq)>0); 


