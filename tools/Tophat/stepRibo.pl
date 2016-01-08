#!/usr/bin/env perl

#########################################################################################
#                                       stepRibo.pl
#########################################################################################
# 
#  This program maps the reads to Ribosomal RNAs, if there is no Ribosomal RNA for this
#  genome the program copy the input file into the necessary location for downstream 
#  analysis.
#
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
 my $input            = "";
 my $outdir           = "";
 my $jobsubmit        = "";
 my $ribosomeInd      = "";
 my $bowtiecmd        = ""; 
 my $servicename      = "";
 my $param            = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";
################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'input=s'        => \$input,
	'outdir=s'       => \$outdir,
        'bowtieCmd=s'    => \$bowtiecmd,
        'ribosomeInd=s'  => \$ribosomeInd,
        'servicename=s'  => \$servicename,
        'jobsubmit=s'    => \$jobsubmit,
        'param=s'        => \$param,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($input eq "") or ($outdir eq "") or ($bowtiecmd eq "") );	

 print "[$servicename]\n";
################### MAIN PROGRAM ####################
#    maps the reads to the ribosome and put the files under $outdir/after_ribosome directory

$outdir   = "$outdir/after_ribosome";

mkdir $outdir if (! -e $outdir);

my @pfiles=split(/:/,$input);

my %prefiles1=();
my %prefiles2=();
my $cat=0;
my $pair=0;
for(my $i=0;$i<scalar(@pfiles);$i++) 
{
   my @files=split(/[,\s\t]+/,$pfiles[$i]);
   #print $files[1]."\n";
   exit 64 if (!checkFile($files[1]));
   if (exists $prefiles1{$files[0]})
   {
     $cat=1;
     $prefiles1{$files[0]}.=$files[1]." ";
   }
   else
   {
     $prefiles1{$files[0]}=$files[1]." ";
   }
   if (scalar(@files)==3) 
   {
     $pair=1;
     exit 64 if (!checkFile($files[2]));
     $prefiles2{$files[0]}.=$files[2]." ";  
   }
}
  
foreach my $libname (keys %prefiles1) 
{
    my $str_file="";
    my $com="";
    if (!$pair) {
       $str_file=$prefiles1{$libname};  
 
       if ($str_file=~/\.gz/)
       {
         $com="zcat $str_file > $outdir/$libname.fastq;";
         $str_file= "$outdir/$libname.fastq";
       }
       else
       {
         if ($cat)
         {
           $com="cat $str_file > $outdir/$libname.fastq;";
         }
         else
         {
           $com="ln -s $str_file $outdir/$libname.fastq;";
         }
         $str_file= "$outdir/$libname.fastq";
       }
       $com.="$bowtiecmd --un $outdir/$libname.notR -x $ribosomeInd $str_file --al $outdir/$libname.yesR  >  /dev/null\n";
    }
    else
    {
      my $file1=$prefiles1{$libname};  
      my $file2=$prefiles2{$libname};  
      
      if ($file1=~/\.gz/)
      {
       $com="zcat ".$file1." > $outdir/$libname.1.fastq;";
       $com.="zcat ".$file2." > $outdir/$libname.2.fastq;";
       $str_file= "-1  $outdir/$libname.1.fastq -2  $outdir/$libname.2.fastq";
      }
      else
      {
         if ($cat)
         {
           $com="cat ".$file1." > $outdir/$libname.1.fastq;";
           $com.="cat ".$file2." > $outdir/$libname.2.fastq;";
         }
         else
         {
           $com="ln -s $file1 $outdir/$libname.1.fastq;";
           $com.="ln -s $file2 $outdir/$libname.2.fastq;";
         }
       $str_file= "-1  $outdir/$libname.1.fastq -2  $outdir/$libname.2.fastq";
      }      
      $com.="$bowtiecmd --un-conc $outdir/$libname.notR -x $ribosomeInd $str_file --al-conc $outdir/$libname.yesR  >  /dev/null \n";
 
     }
     #print "[".$com."]\n\n";
     #`$com`;
     my $job=$jobsubmit." -n ".$servicename."_".$libname." -c \"$com\"";
     print $job."\n";   
     `$job`;
}

sub checkFile
{
 my $file=$_[0];
 return 1 if (-e $file);
 return 0;
}

__END__


=head1 NAME

stepRibo.pl

=head1 SYNOPSIS  

stepRibo.pl -i input <fastq> 
            -o outdir <output directory> 
            -b bowtieCmd <bowtie dir and file> 
            -p params <bowtie params> 
            -r ribosomeInd <ribosome Index file>

stepRibo.pl -help

stepRibo.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -i  input file <fastq format> 

fastq files has to be separated with ":". If it is paired end the paired end files has to ber separated by ","

Ex: For single end;

test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq

for paired end;

test1_R1.fastq,test1_R2.fastq:ctrl1_R1.fastq,ctrl1_R2.fastq

    
=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -b bowtieCmd <bowtie dir and file> 

Fullpath of bowtie executable file. Ex: ~/bowtie_dir/bowtie

=head2  -p params <bowtie params> 

Bowtie running parameteres. Ex: "-p 8 -n 2 -l 20 -M 1 -a --strata --best"

=head2  -r ribosomeInd <ribosome Index file>

Ribosomal index files. Ex: ~/bowtie_ind/rRNA


=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program map the reads to rRNAs and put the rest into other files 

=head1 EXAMPLE


stepRibo.pl -i test1.fastq:test2.fastq:ctrl1.fastq:ctrl2.fastq
            -o ~/out
            -b ~/bowtie_dir/bowtie
            -p "-p 8 -n 2 -l 20 -M 1 -a --strata --best"
            -r ~/bowtie_ind/rRNA

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


