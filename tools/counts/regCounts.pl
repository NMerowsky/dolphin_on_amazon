#!/share/bin/perl -w
# regCounts
#    VERSION: Version 1 (14 May 2012)
#    AUTHOR: Alper Kucukural
#    PURPOSE: It finds counts in different regions. The regions are intronic, coding,
#             3' UTR, 5' UTR, 1kb downstream, 1kb upstream.
#		    
#             
#    INPUT ARGUMENTS:  
#       --beddir <beddir>
#       --outdir <outdir>
#       --name <name>
#       --type <unique(species)|all>
#       --refreg <reference regions>
#       --version
#       --help
#                         
#    OUTPUT FILES: Description of format of output files 
#       For each region there is one line in a text file, indicates the number of reads.
#
#

############## LIBRARIES AND PRAGMAS ################
 use POSIX;
 use POSIX qw/floor/;
 use List::Util qw[min max];
 use Math::Big qw[factorial euler];
 use strict;
 use File::Basename; 
 use Class::Struct;
 use Getopt::Long;
 use Pod::Usage;

#################### CONSTANTS ###################### 
my $dir=`pwd`;
chomp($dir);
#################### VARIABLES ###################### 
## Get command line options and initialize values
my (
	$input,    # input file
	$outdir,   # output directory
	$outname,  # outname is going to be used to give a name the output file
    	$type,     # type is species or all
	$refreg,   # reference regions directory
        $help,
	$print_version,
);

my $u="";
my $VERSION = '1.0.0';
################### PARAMETER PARSING ####################

### Quick help
unless (@ARGV) { 
	# when no command line options are present
	# print SYNOPSIS
	pod2usage( {
		'-verbose' => 0, 
		'-exitval' => 1,
	} );
}

# Command line options
GetOptions( 
	'input=s'      => \$input,  # input file
	'outdir=s'     => \$outdir, # output directory 
	'name=s'       => \$outname,# name is going to be used to give a name the output file
	'type=s'       => \$type,   # type is species or all
	'refreg=s'     => \$refreg, # reference regions directory
	'help'         => \$help,   # request help
	'version'      => \$print_version, # print the version
) or die " unrecognized option(s)!! please refer to the help documentation\n\n";

# Print version
if ($print_version) {
	print "Pipeline main script, version $VERSION\n\n";
	exit;
}

# Print help
if ($help) {
	# print entire POD
	pod2usage( {
		'-verbose' => 2,
		'-exitval' => 1,
	} );
}

### Check for requirements
# check param file
unless ($input) {
	$input = shift @ARGV or
		die "  OOPS! No parameter file specified! \n use --help\n";
}

# set type to "all"
unless ($type) {
	$type = "all";
}

# set type to ""
unless ($refreg) {
	$refreg = "/home/kucukura/progs/pipe/PipeLine/ref/reg";
}

if ($type eq "species")
{
  $u="-u ";
}

 `mkdir -p $outdir/$outname/`;

 my $logname = "summary.log";

 my $num=1;
 if (-s "$outdir/$outname/$logname.1")
 {
   $num = `ls $outdir/$outname/$logname.*|awk '{split(\$1, a, "."); print a[3]; }'|sort -n|tail -n 1`;
   $num++;
 }
 open(my $LOG, ">$outdir/$outname/$logname.$num");
  
 my $cmd=$0;  
 wlog($LOG, "program started at: ");    
 wlog($LOG, "The command used is:");
 wlog($LOG, "$cmd\n"); 
 wlog($LOG, "Parameters specified:");
 wlog($LOG, "input: $input");
 wlog($LOG, "name: $outname"); 
 wlog($LOG, "refreg: $refreg");  
 wlog($LOG, "type: $type");
 wlog($LOG, "Output Dir: $outdir");

################### MAIN PROGRAM ####################
  
  # get the bed file list from given directory

  # Get only proper lines for the counts.
if (!(-s "$outdir/$outname.csv"))
{
  my $com="";

  #sort them using start positions of the reads  
  $com="mv $input $input.1";
  `$com`;

  $com="sort $u -k1,1b -k2,2n $input.1 > $outdir/$outname.bed";
  print $com."\n";
  wlog($LOG, $com);
  `$com`;
  # open an output file 
  open (OUT, ">$outdir/$outname.csv");
  my %counts=();

  print OUT "chrom\tname";

  # get the list of the files under reference regions directory.
  $a=`ls $refreg`;
  my @list2=split(/[\n\r]/, $a);

  foreach my $file (@list2) 
  {
    $file=~/([a-zA-Z0-9]+)\./;
    #get the name of the region from filename
    my $name=$1;
    print OUT "\t$name";
    # find the number of overlaps in between two bed files using intersectBed function  
    $com="intersectBed -s -a $refreg/$file -b $outdir/$outname.bed -wo>$outdir/$name.inter";    
    print $com."\n";
    wlog($LOG, $com);
    `$com`;
    open (IN, "$outdir/$name.inter");

    while (my $line=<IN>)
    {
      my @arr=split(/\t/, $line);
      #print $arr[3]."\n";
      if ($arr[3]=~/.*(N[MR]_\d+)_([^_|:]+)[_|:]/)
      {
        my $chrom=$arr[0];
        my $name=$1;
        my $reg=$2;
        #  print "$chrom|$name|$reg\n";
        if (exists $counts{$chrom.":".$name}{$reg})
        {
           $counts{$chrom.":".$name}{$reg}++;
        }
        else
        {
           $counts{$chrom.":".$name}{$reg}=1;
        }
      }
    }
    
  }
  print OUT "\n";
  #print "bitti yaz\n";
 

  # get the list of the files under reference regions directory.
  my $a1=`ls $refreg`;
  #print $a1;
  my @list3=split(/[\n\r]/, $a1);

    foreach my $key ( keys %counts) {
      
      $key=~/(.*)\:(.*)/;
      print OUT "$1\t$2";

      #print "$1\t$2";
      foreach my $file (@list3) 
      {
        $file=~/([a-zA-Z0-9]+)\./;
        #get the name of the region from filename
        my $name=$1;
 
        #print "KEY:$key|$name\n";
         if (exists $counts{$key}{$name})
         {
           print OUT "\t".$counts{$key}{$name};
         }
         else
         {
           print OUT "\t0";
         }
      }
      print OUT "\n";
    }

  close(OUT);
}
wlog($LOG, "Program END");
close($LOG);


sub wlog
{
  my ($LOG, $txt) = @_;
  my $timestamp = localtime(); 
  print $LOG "$timestamp: $txt\n";
} 
 __END__

=head1 NAME

regCounts.pl

=head1 SYNOPSIS

regCounts.pl [-options...] <filename>
 
  --input <inputfile>
  --outdir <outdir>
  --name <name>
  --type <species|all>
  --refreg <reference regions>
  --version
  --help

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --beddir <bed directory>

Specify the bed directory. It will merge the bed files into one and find the # of reads for each different region.

=item --outdir <outdir>

Output directory.

=item --refreg <refreg>

Reference Regions directory is the directory that includes different regions in the genes. These regions are introns, 3'UTR, 5'UTR, coding, 1kb upstream, 1kb downstream.

=type --type <species|all>
The # of reads are calculated for species or all.

=item --version

Print the version number.

=item --help

Display this POD documentation.

=back

=head1 DESCRIPTION

This program is main script to run alignment pipeline. 



=head1 AUTHOR

 Alper Kucukural, PhD
 HHMI/Moore Lab
 Biochemistry and Molecular Pharmacology Dept.
 Lazare Medical Research Building, 870P
 UMass Medical School
 364 Plantation St.
 Worcester, MA 01605-4321

This package is free software; you can redistribute it and/or modify
it under the terms of the GPL (either version 1, or at your option,
any later version) or the Artistic License 2.0.



