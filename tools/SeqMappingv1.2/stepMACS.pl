#!/usr/bin/env perl

#########################################################################################
#                                       stepMACS.pl
#########################################################################################
# 
#  This program trims the reads in the files. 
#
#
#########################################################################################
# AUTHORS:
#
# Alper Kucukural, PhD 
# Aug 18, 2014
#########################################################################################

############## LIBRARIES AND PRAGMAS ################

 use List::Util qw[min max];
 use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 

#################### VARIABLES ######################
 my $chipinput        = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $previous         = ""; 
 my $acmd             = ""; 
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
        'inputchip=s'    => \$chipinput,
	'outdir=s'       => \$outdir,
        'previous=s'     => \$previous,
        'acmd=s'         => \$acmd,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($chipinput eq "") or ($outdir eq "") );	

################### MAIN PROGRAM ####################
#  It runs macs14 to find the peaks using alined peaks   

print "$previous\n";
my $sorted=".sorted";
my $inputdir = "$outdir/seqmapping/chip";
if ($previous=~/SPLIT/g)
{
  $inputdir = "$outdir/seqmapping/mergechip";
  $sorted="";
}

$outdir  = "$outdir/macs";
`mkdir -p $outdir`;

my @chiplibs=split(/:/,$chipinput);

foreach my $chipline (@chiplibs)
{
 my @chips=split(/,/,$chipline);
 my $first=$chips[0];
 my $bname=$first;
 my $file1=$inputdir."/".$first."$sorted.bam";
 die "Error 64: please check the file:".$file1 unless (checkFile($file1));
 my $com="$acmd -t $file1 --name=$outdir/$first\n";
 
 if (@chips>1 && length($chips[1])>=1)
 {
    my $second=$chips[1];
    my $file2=$inputdir."/".$second."$sorted.bam";
    die "Error 64: please check the file:".$file2 unless (checkFile($file2));
    $bname="$first.vs.$second";
    $com="$acmd -t $file1 -c $file2 --name=$outdir/$first.vs.$second\n";
 }
 #print $com;  
 #`$com`;
 my $job=$jobsubmit." -n ".$servicename."_".$bname." -c \"$com\"";
 print $job."\n";   
 `$job`;
}

sub checkFile
{
 my ($file) = $_[0];
 return 1 if (-e $file);
 return 0;
}

__END__


=head1 NAME

stepMACS.pl

=head1 SYNOPSIS  

stepMACS.pl -o outdir <output directory> 
            -p previous 
            -n #reads

stepMACS.pl -help

stepMACS.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/split" 

=head2  -p previous

previous step


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program map the reads to rRNAs and put the rest into other files 

=head1 EXAMPLE


stepMACS.pl 
            -o ~/out
            -n 1000
            -p previous

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


