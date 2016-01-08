#!/usr/bin/env perl

#########################################################################################
#                                       macs14.pl
#########################################################################################
# 
#  This program runs MACS software to call peaks for the mapped reads.
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
 my $outdir           = "";
 my $indir           = "";
 my $input           = "";
 my $command           = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

GetOptions( 
	'macsoutdir=s'       => \$outdir,
	'outdirbowtie=s'       => \$indir,
	'acommand=s'       => \$command,
	'input=s'       => \$input,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
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

mkdir $outdir if (! -e $outdir);

my @prefiles=split(/:/,$input);
  
for(my $i=0;$i<@prefiles;$i++) 
{
  my @file=split(/,/,$prefiles[$i]);
  if (@file eq 2)
  {
   my($filename1)  = fileparse($file[0]);
   my($filename2)  = fileparse($file[1]);
   my $com="$command -t $indir/$filename1.bam -c $indir/$filename2.bam --name=$outdir/$filename1.vs.$filename2\n";
   my $a="$filename1.$filename2";
   my $job=$jobsubmit." -n ".$servicename."_".$a." -c \"$com\"";
  `$job`;
  }
}


__END__


=head1 NAME

macs14.pl

=head1 SYNOPSIS  

macs14.pl 

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



