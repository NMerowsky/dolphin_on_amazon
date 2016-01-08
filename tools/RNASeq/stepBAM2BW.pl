#!/usr/bin/env perl

#########################################################################################
#                                       stepBAM2BW.pl
#########################################################################################
# 
#  Converts bam files for UCSC visualization.
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
 my $genomesize       = "";
 my $GCB              = "";
 my $W2BW             = "";
 my $username         = "";
 my $outdir           = "";
 my $build            = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'outdir=s'       => \$outdir,
        'coverage=s'     => \$GCB,
	'wig2bigwig=s'   => \$W2BW,
	'username=s'     => \$username,
	'build=s'        => \$build,
        'jobsubmit=s'    => \$jobsubmit,
        'servicename=s'  => \$servicename,
        'genomesize=s'   => \$genomesize,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($W2BW eq "") or ($genomesize eq "") or ($outdir eq "") );	

 
################### MAIN PROGRAM ####################
#   converts the mapped reads for IGV visualization

my $indir   = "$outdir/tophat";
my $uoutpath="/isilon_temp/garber/genomeBrowser/$username";
 
`mkdir -p $outdir/ucsc`;

my @files = <$indir/*.sorted.bam>;
open(OUT, ">$outdir/ucsc/index.html");

foreach my $d (@files){ 

  my $libname=basename($d, ".sorted.bam");
  
  my $outputbg="$outdir/ucsc/$libname.bg";
  my $outputbw="$outdir/ucsc/$libname.bw";

 my $com = "$GCB -split -bg -ibam $d -g $genomesize > $outputbg;\n";
 $com .= "$W2BW -clip -itemsPerSlot=1 $outputbg $genomesize $outputbw;\n";

 $com.="mkdir -p $uoutpath/ucsc;\n";

 $com.="cp $outputbw $uoutpath/ucsc/.\n";
 $com.="cp $d $uoutpath/ucsc/$libname.bam;\n";
 $com.="cp $d.bai $uoutpath/ucsc/$libname.bam.bai;\n";
 $com.="cp $outputbg $uoutpath/ucsc/.;\n";
 $com.="cp $outdir/tdf $uoutpath/. -R;\n";
 $com.="cp $outdir/fastqc $uoutpath/. -R;\n";

 print OUT "<a href=\"http://biocore.umassmed.edu/cgi-bin/hgTracks?db=$build&hgct_customText=track%20type=bigWig%20name=myBWTrack_$libname%20description=%22a%20bigWig%20track%22%20visibility=full%20bigDataUrl=http://biocore.umassmed.edu/genome/$username/ucsc/$libname.bw\">";
 print OUT "$libname bigWig </a><br><br>";
 print OUT "<a href=\"http://biocore.umassmed.edu/cgi-bin/hgTracks?db=$build&hgct_customText=track%20type=bam%20name=myBAMTrack_$libname%20description=%22a%20bam%20track%22%20visibility=full%20bigDataUrl=http://biocore.umassmed.edu/genome/$username/ucsc/$libname.bam\">";
 print OUT "$libname bam </a><br><br>";
  
 if(@files>1 && $jobsubmit!~/^$/)
 { 
    my $job=$jobsubmit." -n ".$servicename."_".$libname." -c \"$com\"";
    print $job."\n";   
    `$job`;
 }
 else
 { 
    `$com`;
 }
}

close(OUT);
`cp $outdir/ucsc/index.html $uoutpath/.`;

__END__


=head1 NAME

stepBAM2BW.pl

=head1 SYNOPSIS  

stepBAM2BW.pl 
            -o outdir <output directory> 
            -g genomesize <genome size file> 
            -b build <genome build> 

stepBAM2BW.pl -help

stepBAM2BW.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome/tdf" 

=head2  -g genomesize <genome size file> 

Genome size file. (Full path)

=head2   -b build <genome build> 

Samtools full path

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepBAM2BW.pl 
            -o outdir <output directory> 
            -g genome <genome files> 
            -s samtools <samtools fullpath> 

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



