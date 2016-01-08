#!/usr/bin/env perl

#########################################################################################
#                                       merge_output.pl
#########################################################################################
# 
#  This program merges output after mapping by bowtie/bwa
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
# use strict;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage; 
 
#################### VARIABLES ######################
$command           = "";
$mappedout           = "";
$filext           = "";
$outdir           = "";
$input           = "";
$bam		="";
$jobsubmit        = "";
$servicename      = "";
$help             = "";
$print_version    = "";
$version          = "1.0.0";

################### PARAMETER PARSING ####################

GetOptions(
	'command=s'       => \$command,
	'mappedout=s'       => \$mappedout,
 	'filext=s'       => \$filext, 
 	'outdir=s'       => \$outdir,
     	'input=s'       => \$input,
     	'bam=s'       => \$bam,
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


@v=split/\:/,$input;

for($i=0;$i<@v;$i++) 
{
  my($filename, $directories, $suffix) = fileparse($v[$i]);
  $com="$command $mappedout $filext $outdir $filename $bam;\n";  
  $job=$jobsubmit." -n ".$servicename."_".$i." -c \"$com\"";
  print STDERR "EEEEEEEEEE $job\n";
  `$job`;
}

__END__


=head1 NAME

merge_output.pl

=head1 SYNOPSIS  

merge_output.pl

Intended to run ONLY from workflows

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

