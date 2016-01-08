#!/share/bin/perl -w
# runPipeLine
#    VERSION: Version 1 (23 Sep 2013)
#    AUTHOR: Alper Kucukural
#    PURPOSE: It runs Ilumina alignment pipeline and some preliminary statistics
#		    
#             
#    INPUT ARGUMENTS:  
#             paramfile: chromosme number to read genomic sequence of a chromosome          
#             input: input file/s that contatins fasta reads
#             outdir: outout directory
#                         
#    OUTPUT FILES: Description of format of output files 
#
#

############## LIBRARIES AND PRAGMAS ################
 use POSIX;
 use Class::Struct;
 use File::Basename;
 use Getopt::Long;
 use Pod::Usage;
 use strict;
#################### CONSTANTS ###################### 
my $dir=`pwd`;
chomp($dir);

#################### STRUCTS ########################
struct ('Steps', {
   method            => '$',
   genome            => '$',
   genomedir         => '$',
   splicesites       => '$', 
   param             => '$',
   stepexplan        => '$',
   includeit         => '$',
   mate              => '$',
} );

#################### VARIABLES ###################### 
## Get command line options and initialize values
my (
	$paramfile, # parameter file
        $input,     # input fastq file/s
        $outdir,    # output directory
	$type,     
	$jobnum,
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
	'param=s'   => \$paramfile, # parameter file
        'input=s'   => \$input, # input fastq file/s
        'outdir=s'  => \$outdir, # outout directory
	'type=s'    => \$type, # runType
	'help'      => \$help, # request help
	'version'   => \$print_version, # print the version
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
unless ($paramfile) {
	$paramfile = shift @ARGV or
		die "  OOPS! No parameter file specified! \n use --help\n";
}

# set type to ""
unless ($type) {
	$type = "";
}

# Read ParamFile 
 my %params=();
 my $logtxt="";
 readPipeParams(\%params, $paramfile);


 #If there is an adapter it will be removed.

 my $outd="$outdir/bowtie";
 `mkdir -p $outd`;

 my @in=split(/:/, $input);
 
 my $initial=$in[0];
 if (@in>1) {
    $params{"PairedEnd"}="YES";
    my $com="cp $in[0] $outd/input_R1.fastq";
    `$com`;
    $com="cp $in[1] $outd/input_R2.fastq";
    `$com`;
 }
 else
 {
    my $com="cp $initial $outd/input.fastq";
    `$com`;
 }
 
 my $logname = "summaryMapping.log";
 
 if(!defined $jobnum)
 {
   `rm $outd/$logname.*`;
 }

 my $num=1;
 if (-s "$outd/$logname.1")
 {
   $num = `ls $outd/$logname.*|awk '{split(\$1, a, "."); print a[3]; }'|sort -n|tail -n 1`;
   $num++;
 }
 open(my $LOG, ">$outd/$logname.$num");
  
 my $cmd=$0;

 wlog($LOG, "program started at: ");    
 wlog($LOG, "The command used is:");
 wlog($LOG, "$cmd\n");
 wlog($LOG, "Parameters specified:");
 wlog($LOG, "input paramfile: $paramfile");
 wlog($LOG, "type: $type");

 writeParams($LOG, \%params); 
 wlog($LOG, "Output Dir: $outd");

################### MAIN PROGRAM ####################
#    Make the Alignments
#    Prepare the initial Statistics

my @steps=();
    
getSteps(\@steps, \%params);

for(my $i=0; $i<@steps; $i++)
{  
   wlog($LOG, "###### Mapping Started #######:Step $i"); 
   mapBowtie($LOG, $i, "$outd/input.fastq", $outd, \@steps, \%params);
   wlog($LOG, "###### Mapping Ended #######:Step $i"); 
}

writeHtml($LOG, $outd, \%params);

#################### FUNCTIONS ###################### 
sub readPipeParams
{
  my ($params, $paramfile)=@_;
   
  open(PAR, $paramfile) or die "Error openings: $!";
  my %par=();
  my @order=();
  while (my $line=<PAR>)
  {
    chomp($line);
    if ($line!~/^#/)
    {
        if($line=~/^([A-Za-z0-9]+)[\s\t]+=[\s\t]+(.*)/)
        { 
          my $param=$1;
          my $val=$2;
          if (exists $par{$param})
          {
           $val=$par{$param}.":$val";
          }
          else
	  {
            push(@order, $param); 
          } 
          $par{$param}=$val;     
        } 
    }
  }
  $par{"order"}=\@order;
  %{$params}=%par;
}
sub writeParams
{
    my ($LOG, $params) = @_;
   
    print $LOG "\n############ PARAMETERS #############################\n#\n";
    my $order=${$params}{"order"};
    foreach my $param (@{$order})       
    {
      if($param!~/^$/)
      { 
       my $txt = sprintf("# %-20s = %-40s\n", $param, ${$params}{$param}); 
       my @steps=split(/:/, ${$params}{$param});
       if (@steps>1)
       { 
          $txt=sprintf("# %-20s ===>\n", $param);
          for  (my $i=0; $i<@steps; $i++)
          { 
            $txt .= sprintf("# %20s = %-40s\n", ($i+1), $steps[$i]); 
          }
       }
       #print $txt;
       print $LOG $txt;
      }
    } 
    
    print $LOG "#\n############ PARAMETERS END ##########################\n";   
}

sub mapBowtie
{
    my ($LOG, $i, $input, $outd, $steps, $params)=@_;

    my $outfile="bowtie.outmap";
    my $rest = $input.".".$i;
    my $init=${$params}{"Bowtie"}." ".${$steps}[$i]->param." ".${$steps}[$i]->genomedir."/".${$steps}[$i]->genome;
    my $com="";
    if ((exists ${$params}{"PairedEnd"}) && ${$params}{"PairedEnd"} eq "YES")
    {

        my $input1=$input; 
        my $input2=$input;
        my $rest1 = $input1."_1.".$i;
        my $rest2 = $input2."_2.".$i;

        if ($i==0)
        { 
          $input1=~s/\.(fast[aq])/_R1\.$1/;
          $input2=~s/\.(fast[aq])/_R2\.$1/;  
        }
        else
        {
          $input1=$input."_1.".($i-1);
          $input2=$input."_2.".($i-1);
        }

        if (${$steps}[$i]->mate eq "YES")
        {
          $com.="$init --un $rest -1 $input1 -2 $input2 $outd/$outfile.$i > $outd/bowtie.res.$i 2>&1\n";
        }
        else
        {          
          $com.="$init --un ".$rest1." $input1 $outd/$outfile.".$i."_1 > $outd/bowtie.res.$i 2>&1\n";
          $com.="$init --un ".$rest2." $input2 $outd/$outfile.".$i."_2 >> $outd/bowtie.res.$i 2>&1\n";
        }
    }
    else
    {
       if ($i>0)
       { 
         $input.=".".($i-1);
       }
       $com.="$init --un $rest $input $outd/$outfile.$i > $outd/bowtie.res.$i 2>&1\n";
    }
    wlog($LOG, $com);
    `$com`;
}


sub wlog
{
  my ($LOG, $txt) = @_;
  my $timestamp = localtime(); 
  print $LOG "$timestamp: $txt\n";
}


#Steps are reading from parameter file
sub getSteps
{
 my ($steps, $params)=@_;


 my @method=split(/:/, ${$params}{"Method"});
 my $count=@method;
 my @genome=();
 my @genomedir=();
 my @splicesites=();
 my @param=();
 my @stepExplan=();
 my @includeit=();
 my @mate=();

 splitArr(\@genome, "Genome", $count, $params);
 splitArr(\@genomedir, "GenomeDir", $count, $params);
 splitArr(\@splicesites, "SpliceSites", $count, $params);
 splitArr(\@param, "Param", $count, $params); 
 splitArr(\@stepExplan, "StepExplan", $count, $params); 
 splitArr(\@includeit, "IncludeIt", $count, $params);
 splitArr(\@mate, "Mate", $count, $params);
 
 my @starr=();
 for (my $i=0; $i<$count; $i++)
 {
   my $tmp=new Steps;
   $tmp->method($method[$i]);
   $tmp->genome($genome[$i]);
   $tmp->genomedir($genomedir[$i]);
   $tmp->splicesites($splicesites[$i]);
   $tmp->param($param[$i]);
   $tmp->stepexplan($stepExplan[$i]);
   $tmp->includeit($includeit[$i]);
   $tmp->mate($mate[$i]);
   push(@starr, $tmp);
 }
 @{$steps}=@starr;
}

#Each steps were collected one variable with ":" seperator
#when it was reading.Those sequences are split using splitArr function
# if the parameter hasn't defined. 0 value puts as default.
sub splitArr
{
  my ($arr, $par, $count, $params) = @_;

  my @tmp=();
  if (exists ${$params}{$par})
  {
    @tmp=split(/:/, ${$params}{$par});
  }
  else
  {  
    for (my $i=0; $i<$count; $i++)
    {
      push(@tmp, "0");
    }
  }
  @{$arr}=@tmp;
}

### HTML OUTPUT ###
sub writeHtml
{
 my ($LOG, $outd, $params) = @_;
  my $com="";
 
 if (${$params}{"Html"})
 {
  my $htmlout="$outd/html";
  `mkdir -p $htmlout`;
  open(OUT, ">$htmlout/index.html");  
  print OUT "<html><body>";
  
  my $html = makeSummaryHTML($LOG, $outd, $params);

  print $html;
  print OUT $html;
  print OUT "</body></html>";
 }
}

sub makeSummaryHTML
{
  my ($LOG, $outd, $params) = @_;

  my $html="";

   my @bowfiles=();
   my @explan=();
   getExp(\@bowfiles, \@explan, $outd, $params);
   
   $html.="<table>";
   if ((exists ${$params}{"PairedEnd"}) && ${$params}{"PairedEnd"} eq "YES")
   {
     $html.="<tr><th>Alignment</th><th>R1</th><th># of reads</th><th>Unique</th><th>Perc</th><th>Multiple</th><th>Perc</th><th>R2</th><th># of reads</th><th>Unique</th><th>Perc</th><th>Multiple</th><th>Perc</th><th>Total</th><th>Perc</th></tr>";
   }
   else
   {
     $html.="<tr><th>Alignment</th><th># of reads</th><th>Unique</th><th>Perc</th><th>Multiple</th><th>Perc</th><th>Total</th><th>Perc</th></tr>";
   }
   my $i=0;
   my $first_reads_processed=0;
   foreach my $file (@bowfiles)
   {
     my $txt=sprintf("<tr><th  align=\"left\">%-30s</th>%-30s</tr>\n", $explan[$i], prepSummaryHTML($file, $params,\$first_reads_processed));
     $html.=$txt;
     $i++;
   }
  return $html."</table>\n";
}

sub prepSummaryHTML
{
  my ($file, $params, $first_reads_processed)=@_;
  my $txt="";

  if (-s $file)
  {  
  open (F, $file) or die "Error opening: $!";
  my $num=`grep \"^#\" $file|wc -l`;
  chomp($num);
  my $j=1;
  my $total=0;
  my $mul=0;
  my $doub=1;
  while (my $line=<F>)
  {
    chomp($line);    
    if ($line=~/processed:\s(\d+)/)
    {
       if (!${$first_reads_processed})
       {
          ${$first_reads_processed}=$1;  
       }
       if ($num>5)
       {        
         $doub=2;
         $txt.="<td>R".$j."</td>";
       }
       else
       {
        if ((exists ${$params}{"PairedEnd"}) && ${$params}{"PairedEnd"} eq "YES")
        {
          $txt.="<td>Mate(R1-R2)</td>";
        }
       }
       $txt.="<td align=\"right\" bgcolor=\"#EEEEEE\">".commify($1)."</td>";
       $j++;
    } 
    elsif ($line=~/reported alignment:\s(.+)(\(.+\))/)
    {
       if (${$first_reads_processed}>0)
       {
         my $perc=sprintf("%.2f",100*($1/${$first_reads_processed}));
         $txt.="<td align=\"right\">".commify($1)."</td><td align=\"right\" bgcolor=\"#EEEEEE\">(".$perc."%)</td>";
       }
       $total+=$1;
    }
    elsif ($line=~/due to -M:\s(.+)(\(.+\))/)
    {
       $total+=$1;
       $mul=1;
       if (${$first_reads_processed}>0)
       {
         my $perc=sprintf("%.2f",100*($1/${$first_reads_processed}));
         $txt.="<td align=\"right\">".commify($1)."</td><td align=\"right\" bgcolor=\"#EEEEEE\">(".$perc."%)</td>";
       }
    }  
    elsif ($line=~/^Reported/ || $line=~/^No/)
    {
      if ($mul==0)
      {
        $txt.="<td align=\"right\">0</td><td align=\"right\" bgcolor=\"#EEEEEE\">(0.00%)</td>";
      }
      $mul=0;
    }
   }
  
  if (${$first_reads_processed}>0)
  {
   my $perc=sprintf("%.2f",100*($total/(${$first_reads_processed}*$doub)));
   $txt.="<td align=\"right\">".commify($total)."</td><td align=\"right\" bgcolor=\"#EEEEEE\">(".$perc."%)</td>";
  }
  }
  return $txt;
}

sub getExp
{
   my ($bowfiles, $explan, $outd, $params) = @_;
   if (exists  ${$params}{"StepExplan"})
   {
     @{$explan}=split(/:/, ${$params}{"StepExplan"});
     my @tmp=();
     for(my $i=0; $i<@{$explan}; $i++)
     {
      push(@tmp, "$outd/bowtie.res.$i");
     }
    @{$bowfiles}=@tmp;
   }
}

sub commify 
{
  local $_  = shift;
  1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
  return $_;
}
