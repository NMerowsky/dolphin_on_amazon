#!/usr/bin/env perl

open(IN, $ARGV[0]);
my $seq="";
my $name="";
while (my $line=<IN>)
{
  chomp($line);
  if ($line=~/>/)
  {
     print splitToSeq($seq, $name);
     $seq="";
     $name=$line;
  }
  else
  {
     $seq.=$line;
  }
}
print splitToSeq($seq, $name);
 
sub splitToSeq
{
 my ($seq, $name) = @_;
 my $index=1;
 for($i=0; $i<length($seq); $i+=25)
 {
    my $line=substr($seq, $i, 50);
   
    if (length($line)==50)
    {
      print $name."_".$index."\n$line\n";
    }
    $index++;
 }
}
