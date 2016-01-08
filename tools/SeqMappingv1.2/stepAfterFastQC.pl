#!/usr/bin/env perl

#########################################################################################
#                                       stepAfterFastQC.pl
#########################################################################################
# 
#  This program runs FastQC analysis, combines FastQC output.
#
#
#########################################################################################
# AUTHORS:
#
# Alper Kucukural, PhD 
# 
#########################################################################################


############## LIBRARIES AND PRAGMAS ################

 use List::Util qw[min max];
 use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 
 
#################### VARIABLES ######################
 my $outd             = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
 ################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outd,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($outd eq "") );	

################### MAIN PROGRAM ####################
#    combines FastQC output


my $outdir   = "$outd/fastqc";
my $uniteddir = "$outdir/UNITED";
my $filesdir="$outdir/UNITED/files";

`mkdir -p $uniteddir`;
`mkdir -p $filesdir`;

open outPBQ, ">$uniteddir/per_base_quality.html";
print outPBQ "\<body\>\n";
open outPSQ, ">$uniteddir/per_sequence_quality.html";
print outPSQ "\<body\>\n";
open outPBSC, ">$uniteddir/per_base_sequence_content.html";
print outPBSC "\<body\>\n";
opendir(my $dir, $outdir);
my @files = readdir($dir);

my @dirs = grep {/\_fastqc$/} @files;
foreach my $e(@files)
{
 if(!(($e eq ".")||($e eq "..")||($e eq "UNITED")) )
 {
  `cp $outdir/$e/*/Images/per_base_quality.png $filesdir/pbq_$e.png`;
  `cp $outdir/$e/*/Images/per_sequence_quality.png $filesdir/psq_$e.png`;
  `cp $outdir/$e/*/Images/per_base_sequence_content.png $filesdir/pbsc_$e.png`;
  print outPBQ "\<div class=\"module\"\>\<h2 id=\"M1\"\> $e \<\/h2>\n\<p\>\<img class=\"indented\" src=\"./files/pbq_$e.png\"\>\<\/p\>\n\<\/div\>";
  print outPSQ "\<div class=\"module\"\>\<h2 id=\"M1\"\> $e \<\/h2>\n\<p\>\<img class=\"indented\" src=\"./files/psq_$e.png\"\>\<\/p\>\n\<\/div\>";
  print outPBSC "\<div class=\"module\"\>\<h2 id=\"M1\"\> $e \<\/h2>\n\<p\>\<img class=\"indented\" src=\"./files/pbsc_$e.png\"\>\<\/p\>\n\<\/div\>";
 }
}

print outPBQ "\</body\>\n";
print outPSQ "\</body\>\n";
print outPBSC "\</body\>\n";

__END__


=head1 NAME

stepAfterFastQC.pl

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





