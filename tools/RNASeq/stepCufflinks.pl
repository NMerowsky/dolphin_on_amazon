#!/usr/bin/env perl

#########################################################################################
#                                       stepCufflinks.pl
#########################################################################################
# 
#  This program runs the cufflinks after tophat mappings
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
 my $gtf              = "";
 my $outdir           = "";
 my $cufflinksCmd     = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'        => \$outdir,
        'cufflinksCmd=s'  => \$cufflinksCmd,
        'gtf=s'           => \$gtf,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($gtf eq "") or ($outdir eq "") or ($cufflinksCmd eq "") );	

 
################### MAIN PROGRAM ####################
#    maps the reads to the the genome and put the files under $outdir/after_ribosome/tophat directory


my $indir   = "$outdir/tophat";
$outdir  = "$outdir/cufflinks";

mkdir $outdir if (! -e $outdir);

my @files = <$indir/*.sorted.bam>;

foreach my $d (@files){ 

  if (-s $d)
  {  
    my $libname=basename($d, ".sorted.bam");
  
    my $com="$cufflinksCmd  --no-update-check -p 8 -o $outdir/pipe.cufflinks.$libname -G $gtf -u -m 300 -v $d\n"; 
    if(@files>1 && $jobsubmit!~/^$/)
    {
      my $job=$jobsubmit." -s $servicename -n ".$servicename."_".$libname." -c \"$com\"";
      print $com."\n";
      `$job`;
    }
    else
    {
      $com.=" &";
      `$com`;
    }
  }
}
__END__


=head1 NAME

stepCufflinks.pl

=head1 SYNOPSIS  

stepCufflinks.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -c cufflinksCmd <cufflinks full path> 

stepCufflinks.pl -help

stepCufflinks.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -c cufflinksCmd <cufflinks full path> 

Fullpath of cufflinks executable file. Ex: ~/cufflinks_dir/cufflinks

=head2  -g gtf <ucsc gtf files> 

Transcript annotation file

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

This program runs the cufflinks after tophat mappings

=head1 EXAMPLE

stepCufflinks.pl 
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



