#!/usr/bin/env perl


open(IN, $ARGV[0]);

my $index=1;
while (my $line=<IN>)
{
  if ($line=~/>/)
  {
     $bas=1;
  }
  else
  {
    if ($bas==0)
    {
      goto NEXT;
    }
    else
    {
      `cp $ARGV[0] $ARGV[0].converted`;
    }
    $bas=0;
  }
}

NEXT:

open(IN, $ARGV[0]);

my $index=1;
while (my $line=<IN>)
{
  chomp($line);
  if ($line=~/>/)
  {
    $name=$line;
  }
  else
  {
    if (length($line)==50)
    {
      print $name."_".$index."\n$line\n";
    }
  }
  
  $index+=25;
}
