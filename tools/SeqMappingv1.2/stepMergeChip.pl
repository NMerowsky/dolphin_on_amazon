#!/usr/bin/env perl

#########################################################################################
#                                       stepMergeChip.pl
#########################################################################################
# 
#  This program trims the reads in the files. 
#
#
#########################################################################################
# AUTHORS:
#
# Alper Kucukural, PhD 
# Aug 14, 2014
#########################################################################################

############## LIBRARIES AND PRAGMAS ################

 use List::Util qw[min max];
 use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 

#################### VARIABLES ######################
 my $outdir           = "";
 my $samtools         = "";
 my $jobsubmit        = "";
 my $spaired          = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'samtools=s'     => \$samtools,
        'dspaired=s'     => \$spaired,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($samtools eq "") or ($outdir eq "") );	

################### MAIN PROGRAM ####################

my $inputdir = "$outdir/seqmapping/chip";
$outdir  = "$outdir/seqmapping/mergechip";
`mkdir -p $outdir`;
my $com="";
$com=`ls $inputdir/*.bam`;
print $com;
my @files = split(/[\n\r\s\t,]+/, $com);

my %mergeCmd=();
foreach my $file (@files)
{
 $file=~/(.*\/(.*))_[\d]+.sorted.bam/;
 my $bpath=$1;
 my $bname=$2;
 $mergeCmd{$bpath."*.sorted.bam"}=$bname;
}

foreach $cmd (keys %mergeCmd)
{
 my $bname=$mergeCmd{$cmd};
 my $outfile=$outdir."/$bname.bam"; 
 my $fcount=`ls $cmd|wc -l`;
 chomp($fcount);
 if ($fcount>1)
 {
   $com ="$samtools merge $outfile $cmd -f;\n";
   $com .="$samtools index $outfile;\n";
 }
 else
 {
   $com ="cp $cmd $outfile;\n";
   $com .="cp $cmd.bai $outfile.bai;\n";
 }
 print $com."\n\n";
 `$com`;
 #my $job=$jobsubmit." -n ".$servicename."_".$bname." -c \"$com\"";
 #print $job."\n";   
 #`$job`;
}

__END__


=head1 NAME

stepMergeChip.pl

=head1 SYNOPSIS  

stepMergeChip.pl -o outdir <output directory> 
            -p previous 
            -n #reads

stepMergeChip.pl -help

stepMergeChip.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/MergeChip" 

=head2  -p previous

previous step


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program map the reads to rRNAs and put the rest into other files 

=head1 EXAMPLE


stepMergeChip.pl 
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


