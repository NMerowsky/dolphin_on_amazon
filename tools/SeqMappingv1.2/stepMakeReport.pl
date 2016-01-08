#!/usr/bin/env perl

#########################################################################################
#                                       stepMakeReport.pl
#########################################################################################
# 
#  This program removes adapter sequence. 
#
#
#########################################################################################
# AUTHORS:
#
# Alper Kucukural, PhD 
# Jul 4, 2014
#########################################################################################


############## LIBRARIES AND PRAGMAS ################

 use List::Util qw[min max];
 use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 

#################### VARIABLES ######################
 my $outfile          = "";
 my $outdir           = "";
 my $mappingnames     = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'foutfile=s'     => \$outfile,
        'mappingnames=s' => \$mappingnames,
	'outdir=s'       => \$outdir,
        'servicename=s'  => \$servicename,
        'jobsubmit=s'    => \$jobsubmit,
	'help'           => \$help, 
	'version'        => \$print_version,
) or die("Unrecognized optioins.\nFor help, run this script with -help option.\n");

if($help){
    pod2usage( {
		'-verbose' => 2, 
		'-exitval' => 1,
	} );
}

if($print_version){
  print "Version ".$version."\n";
  exit;
}

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ( $outfile eq "") or ($outdir eq "") );	

################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

my $inputdir="";

$inputdir = "$outdir/counts";
$outdir   = "$outdir/counts";
`mkdir -p $outdir`;
open(OUT, ">$outdir/index.html");

my $com=`ls $inputdir/*.summary.tsv`;

my @mnames=split(/,/,$mappingnames);

print $com;
my @files = split(/[\n\r\s\t,]+/, $com);

print OUT "<html>\n";
print OUT "<link href=\"http://bioinfo.umassmed.edu/dist/css/bootstrap.css\" rel=\"stylesheet\">\n";
print OUT "<script src=\"http://bioinfo.umassmed.edu/dist/lib/jquery-1.7.2.min.js\" type=\"text/javascript\"></script>\n";
print OUT "<style type=\"text/css\">
table.gridtable {
	font-family: verdana,arial,sans-serif;
	font-size:11px;
	color:#333333;
	border-width: 1px;
	border-color: #666666;
	border-collapse: collapse;
}
table.gridtable th {
	border-width: 1px;
	padding: 8px;
	border-style: solid;
	border-color: #666666;
	background-color: #dedede;
}
table.gridtable td {
	border-width: 1px;
	padding: 8px;
	border-style: solid;
	border-color: #666666;
	background-color: #ffffff;
}
</style>";
   
print OUT "<body>\n";
print OUT "<br><h4>Count files:</h4><br>\n";
print OUT "All the count files are in the following directory: $outdir</h4><br>\n";
print OUT "<div class=\"container\">";

my %orderedmap=();
foreach my $file (@files)
{
   open(IN, $file);
   $file=~/.*\/(.*).summary.tsv/;
   my $name=$1;
   my $j=0;
   $orderedmap{$name}="<br><h4>$name </h4><br>\n";
   $orderedmap{$name}.= "<table class=\"table.colored\">\n";
   while (my $line=<IN>)
   {
      $orderedmap{$name}.="<tr>\n";
      my @arr=split(/\t/, $line);
      my $i=0;
      foreach my $val (@arr)
      {
         $orderedmap{$name}.="<th>$val</th>" if ($j==0 || $i ==0);
         $orderedmap{$name}.="<td>$val</td>" if ($j>0 && $i>0);
         $i++;
      }
      $j++;
      $orderedmap{$name}.="</tr>\n";
   }
   $orderedmap{$name}.="</table>\n";
}

foreach my $mapname (@mnames)
{
    print OUT $orderedmap{$mapname};
}
print OUT "</div>";
print OUT "<script src=\"http://bioinfo.umassmed.edu/dist/js/bootstrap.min.js\"></script>\n";

close(OUT);

`cp $outdir/index.html $outfile`;

__END__


=head1 NAME

stepMakeReport.pl

=head1 SYNOPSIS  

stepMakeReport.pl -i input <fastq> 
            -o outdir <output directory> 
            -b bowtieCmd <bowtie dir and file> 
            -p params <bowtie params> 
            -r ribosomeInd <ribosome Index file>

stepMakeReport.pl -help

stepMakeReport.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -i  input file <fastq format> 

fastq files has to be separated with ":". If it is paired end the paired end files has to ber separated by ","

Ex: For single end;

test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq

for paired end;

test1_R1.fastq,test1_R2.fastq:ctrl1_R1.fastq,ctrl1_R2.fastq

    
=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -b bowtieCmd <bowtie dir and file> 

Fullpath of bowtie executable file. Ex: ~/bowtie_dir/bowtie

=head2  -p params <bowtie params> 

Bowtie running parameteres. Ex: "-p 8 -n 2 -l 20 -M 1 -a --strata --best"

=head2  -r ribosomeInd <ribosome Index file>

Ribosomal index files. Ex: ~/bowtie_ind/rRNA


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program map the reads to rRNAs and put the rest into other files 

=head1 EXAMPLE


stepMakeReport.pl -i test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq
            -o ~/out
            -b ~/bowtie_dir/bowtie
            -p "-p 8 -n 2 -l 20 -M 1 -a --strata --best"
            -r ~/bowtie_ind/rRNA

=head1 AUTHORS

 Alper Kucukural, PhD

 
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


