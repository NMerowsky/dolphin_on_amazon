#!/usr/bin/env perl

#########################################################################################
#                                       stepPicard.pl
#########################################################################################
# 
#  This program runs the picard 
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
 my $refflat          = "";
 my $outdir           = "";
 my $picardCmd        = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions(
	'outdir=s'        => \$outdir,
        'refflat=s'       => \$refflat,
        'picardCmd=s'     => \$picardCmd,
        'jobsubmit=s'     => \$jobsubmit,
        'servicename=s'   => \$servicename,
	'help'            => \$help, 
	'version'         => \$print_version,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($refflat eq "") or ($outdir eq "") or ($picardCmd eq "") );	

################### MAIN PROGRAM ####################
# runs the picard program

my $indir   = "$outdir/tophat";
$outdir  = "$outdir/picard";
mkdir $outdir if (! -e $outdir);

opendir D, $indir or die "Could not open $indir\n";
my @alndirs = grep /^[^.]/, readdir(D);
closedir D;

foreach my $d (@alndirs){ #pipe.tophat*
  my $dir = "${indir}/$d";
  next if(! (-d $dir));

  my $com="$picardCmd REF_FLAT=$refflat OUTPUT=$outdir/$d.out INPUT=$dir/accepted_hits.bam\n";
  if(@alndirs>1 && $jobsubmit!~/^$/)
  {
    my $job=$jobsubmit." -n ".$servicename."_".$d." -c \"$com\"";
    `$job`;
  }
  else
  { 
    `$com`;
  }
}
__END__


=head1 NAME

stepPicard.pl

=head1 SYNOPSIS  

stepPicard.pl 
            -o outdir <output directory> 
            -r refflat <ucsc gtf files> 
            -p picardCmd <picard full path> 

stepPicard.pl -help

stepPicard.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be stored "$outdir/after_ribosome/cuffdiff" 

=head2 -p picardCmd <picard running line> 

Fullpath of picard running line. Ex: ~/cuffdiff_dir/cuffdiff

=head2  -r refflat <refflat file>  

ucsc refflat file

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

This program runs the cufflinks after tophat mappings

=head1 EXAMPLE

stepPicard.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -c cufflinksCmd <cufflinks full path> 

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





