#!/share/bin/perl

open(IN, $ARGV[0]);

while($line=<IN>)
{
 chop($line);
 
 if($line=~/^+$/)
 {
   print $line."\n";
 }
 elsif($line=~/^[ACGTN]+$/)
 {
   $line=reverse($line);
   $line=~tr/ACGT/TGCA/;
   print $line."\n";
 }
 else
 {
   print $line."\n";
 }
}
