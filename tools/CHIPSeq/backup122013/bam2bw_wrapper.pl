#!/usr/bin/env perl

#########################################################################################
#                                       bam2bw_wrapper.pl
#########################################################################################
# 
#  This program in charge of initiating BW creation.
#
#########################################################################################
# AUTHORS:
#
# Hennady Shulha, PhD 
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
 my $command           = "";
 my $outdir           = "";
 my $input           = "";
 my $genomesize           = "";
 my $username           = "";
 my $wversion           = "";
 my $lname           = "";
 
 my $servicename      = "";
 my $jobsubmit        = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

GetOptions( 
	'command=s'           => \$command,
	'outdir=s'            => \$outdir,
	'input=s'             => \$input,
	'genomesize=s'             => \$genomesize,
	'username=s'             => \$username,
	'wversion=s'             => \$wversion,
        'lname=s'             => \$lname,

	'servicename=s'       => \$servicename,
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

#pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($bowtie2Ind eq "") or ($outdir eq "") or ($tophatCmd eq "") );	

 
################### MAIN PROGRAM ####################
#    

$input=~s/\,/\:/g;
my @files=split(/:/,$input);

my %seen=();
@files = grep { ! $seen{$_} ++ } @files;
  
for(my $i=0;$i<@files;$i++) 
{
   my @fullp=split/\//,$files[$i];
   my $com="$command $outdir $fullp[$#fullp] $genomesize $username $wversion $lname\n";
   my $a="$fullp[$#fullp]";
   my $job=$jobsubmit." -n ".$servicename."_".$i." -c \"$com\"";
   `$job`;
   print $job."\n";
}


__END__


=head1 NAME

bam2bw_wrapper.pl

=head1 SYNOPSIS  

bam2bw_wrapper.pl 

This script is intended to be called from workflow only.

=head1 AUTHORS

 Hennady Shulha, PhD 

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



