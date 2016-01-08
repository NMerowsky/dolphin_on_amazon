#!/usr/bin/env perl

#########################################################################################
#                                       stepSplit.pl
#########################################################################################
# 
#  This program trims the reads in the files. 
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
 my $number           = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $previous         = ""; 
 my $spaired          = "";
 my $cmd              = ""; 
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
        'number=s'       => \$number,
	'outdir=s'       => \$outdir,
        'previous=s'     => \$previous,
        'dspaired=s'     => \$spaired,
        'cmd=s'          => \$cmd,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($number eq "") or ($outdir eq "") );	

################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

my $inputdir="";
print "$previous\n";
if ($previous=~/NONE/g)
{
  $inputdir = "$outdir/input";
}
else
{
  $inputdir = "$outdir/seqmapping/".lc($previous);
}

$outdir  = "$outdir/seqmapping/split";
`mkdir -p $outdir`;
my $com="";
$com=`ls $inputdir/*.fastq`;
print $com;
my @files = split(/[\n\r\s\t,]+/, $com);

foreach my $file (@files)
{
 die "Error 64: please check the file:".$file unless (checkFile($file));
 $file=~/.*\/(.*).fastq/;
 my $bname=$1;
 my $pairednum="";
 if ($spaired eq "paired")
 {
    $file=~/.*\/(.*)(.[12]).fastq/;
    $bname=$1;
    $pairednum=$2;
 }
 $com = "split -l ".($number*4)." --numeric-suffixes $file $outdir/$bname$pairednum._;\n";
 $com.= "ls $outdir/$bname$pairednum._*|awk '{split(\\\$1,a,\\\".\\\");system(\\\"mv \\\"\\\$1\\\" $outdir/$bname\\\"a[length(a)]\\\"$pairednum.fastq\\\")}';\n"; 
 #$com = "split -l ".($number*4)." --numeric-suffixes $file $outdir/$bname^$pairednum^_; ls $outdir/$bname^$pairednum^_*|grep -v fastq|awk '{split(\$1,a,\"^\");system(\"mv \"\$1\" \"a[1]a[3]\"$pairednum.fastq\")}'"; 
 print $com."\n\n";  
 #`$com`;
 my $job=$jobsubmit." -n ".$servicename."_".$bname.$pairednum." -c \"$com\"";
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

stepSplit.pl

=head1 SYNOPSIS  

stepSplit.pl -o outdir <output directory> 
            -p previous 
            -n #reads

stepSplit.pl -help

stepSplit.pl -version

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


stepSplit.pl 
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


