#!/share/bin/perl
#########################################################################################
#                                       stepIGVTDF.pl
#########################################################################################
# 
#  Converts bam files for IGV visualization.
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
 my $genome           = "";
 my $input            = "";
 my $outdir           = "";
 my $samtools         = "";
# my $galaxyout        = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'input=s'        => \$input,
	'outdir=s'       => \$outdir,
        'samtools=s'     => \$samtools,
        'fastagenome=s'  => \$genome,
#        'galaxyout=s'    => \$galaxyout,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($samtools eq "") or ($genome eq "") or ($input eq "") or ($outdir eq "") );	

 
################### MAIN PROGRAM ####################
#   converts the mapped reads for IGV visualization

  my $com = "$samtools index $input.bam $input.bam.bai;\n";
  $com.="cd $outdir; /project/umw_biocore/bin/igvtools.sh count -w 5 $input.bam $input.tdf $genome\n"; 
#  $com.="cp $input.tdf $input.galaxyout.txt\n";
  print $com;
  `$com`;  

__END__


=head1 NAME

stepIGVTDF.pl

=head1 SYNOPSIS  

stepIGVTDF.pl 
            -i input <input> 
            -o outdir <outdir directory> 
            -g genome <genome files> 
            -s samtools <samtools fullpath> 

stepIGVTDF.pl -help

stepIGVTDF.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <outdir directory>

the outdir files will be "$outdir/after_ribosome/tdf" 

=head2  -g genome <genome files> 

Genome fasta file. (Full path)

=head2   -t samtools <samtools fullpath> 

Samtools full path

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepIGVTDF.pl 
            -o outdir <outdir directory> 
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



