#!/usr/bin/env perl
#########################################################################################
#                                       splitFastq.pl
#########################################################################################
#                          This program doess fastq splitting for each fastq file.
#########################################################################################
# AUTHORS:
# Hennady Shulha, PhD 
# Alper Kucukural, PhD 
#########################################################################################
####################################### LIBRARIES AND PRAGMAS ###########################
use File::Basename;
use Getopt::Long;
################### PARAMETER PARSUING ####################
GetOptions( 
	'outdir=s'            => \$outdir,
	'input=s'             => \$inputfile,
	'numberlines=s'           => \$num,
) or die("Fastq splitting step got unrecognized options.\n");
########################################## MAIN PROGRAM ##################################
@v1=split/\./,$inputfile;
$inputfile1=$inputfile;
if($v1[$#v1] eq "z" || $v1[$#v1] eq "gz")
{
 ($filename, $directories, $suffix) = fileparse($inputfile1);
 $inputfile1="$outdir/$filename.unz";
 `gunzip -c -d $inputfile > $inputfile1`;
 if($? != 0)
 {
  print STDERR "Failed to unzip your initial file\n";
  exit(1);
 }
}
print $inputfile1."\n";
open IN, "$inputfile1";
$i=0;
$j=1;
while(<IN>)
{ 
 if (($i % $num)==0)
 {
  if ($i>0)
  {
   close OUT;
  }
  ($filename, $directories, $suffix) = fileparse($inputfile);
  $name="$outdir/$filename.$j";
  open OUT, ">$name";
  $j++;
 }
 print OUT; 
 $i++;
}
close IN;
if($v1[$#v1] eq "z" || $v1[$#v1] eq "gz")
{
 `rm $inputfile1`;
}

__END__

=head1 NAME

splitFastq.pl

=head1 LICENSE AND COPYING

 This program is free software; you can redistribute it and / or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, a copy is available at
 http://www.gnu.org/licenses/licenses.html

