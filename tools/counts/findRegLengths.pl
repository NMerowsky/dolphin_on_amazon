#!/share/bin/perl -w
# regCounts
#    VERSION: Version 1 (27 Aug 2013)
#    AUTHOR: Alper Kucukural
#    PURPOSE: It finds lengths of the given regions. 
#		    
#             
#    INPUT ARGUMENTS:  
#       --inputbed <inputbed>
#       --outfile   <outfile>
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
	$inputbed,    # input file
	$outfile,   # output directory
        $help,
	$print_version,
);

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
	'inputbed=s'      => \$inputbed,  # input file
	'outfile=s'       => \$outfile, # output directory 
	'help'            => \$help,   # request help
	'version'         => \$print_version, # print the version
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
unless ($inputbed) {
	$inputbed = shift @ARGV or
		die "  OOPS! No parameter file specified! \n use --help\n";
}

# set type to "all"
unless ($outfile) {
	$outfile = shift @ARGV or
		die "  OOPS! No parameter file specified! \n use --help\n";
}

 my $logname = "$outfile.log";

 my $num=1;
 if (-s "$logname.1")
 {
   $num = `ls $logname.*|awk '{split(\$1, a, "."); print a[3]; }'|sort -n|tail -n 1`;
   $num++;
 }
 open(my $LOG, ">$logname.$num");
  
 my $cmd=$0;  
 wlog($LOG, "program started at: ");    
 wlog($LOG, "The command used is:");
 wlog($LOG, "$cmd\n"); 
 wlog($LOG, "Parameters specified:");
 wlog($LOG, "inputbed: $inputbed");
 wlog($LOG, "Output file: $outfile");

################### MAIN PROGRAM ####################
  
  # get the bed file list from given directory

  # Get only proper lines for the lengths.
my %lengths=();
my %regs=();
if (!(-s "$outfile"))
{
  my $com="";
    open (IN, "$inputbed");

    while (my $line=<IN>)
    {
      my @arr=split(/\t/, $line);
      #print $arr[3]."\n";
      if ($arr[3]=~/.*(N[MR]_\d+)_([^_|:]+)[_|:]/)
      {
        my $chrom=$arr[0];
        my $name=$1;
        my $reg=$2;
        $regs{$reg}=1;
        #print "$chrom|$name|$reg\n";
        if (exists $lengths{$chrom.":".$name}{$reg})
        {
           $lengths{$chrom.":".$name}{$reg}+=$arr[2]-$arr[1];
        }
        else
        {
           $lengths{$chrom.":".$name}{$reg}=$arr[2]-$arr[1];
        }
      }
    }
    
  }
    open (OUT, ">$outfile");
    print OUT "chrom\tname";
    foreach my $reg ( keys %regs)
    {
       print OUT "\t$reg";
    }
    print OUT "\n";

    foreach my $key ( keys %lengths) {
      
      $key=~/(.*)\:(.*)/;
      print OUT "$1\t$2";
 
      #print "$1\t$2";
      foreach my $reg ( keys %regs)
      {
 
        #print "KEY:$key|$name\n";
         if (exists $lengths{$key}{$reg})
         {
           print OUT "\t".$lengths{$key}{$reg};
         }
         else
         {
           print OUT "\t0";
         }
      }
      print OUT "\n";
    }

close(OUT);

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
 
  --inputbed <inputbedfile>
  --outfile <outfile>
  --version
  --help

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --inputbed <bed directory>

Specify the bed file that has all the regions.

=item --outfile <outfile>

Output file.

=item --version

Print the version number.

=item --help

Display this POD documentation.

=back

=head1 DESCRIPTION

This program is main script to run alignment pipeline. 



=head1 AUTHOR

 Alper Kucukural, PhD
 Biocore
 Biochemistry and Molecular Pharmacology Dept.
 Lazare Medical Research Building, 870P
 UMass Medical School
 364 Plantation St.
 Worcester, MA 01605-4321

This package is free software; you can redistribute it and/or modify
it under the terms of the GPL (either version 1, or at your option,
any later version) or the Artistic License 2.0.



