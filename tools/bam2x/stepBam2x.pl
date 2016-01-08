#!/usr/bin/env perl

#########################################################################################
#                                       stepBam2x.pl
#########################################################################################
# 
# This program runs mirza for all the files in $outdir/files directory
# Inputs of the program is  
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
 my $output           = ""; 
 my $bam              = "";
 my $input            = "";
 my $queue            = "";
 my $pngfile          = "";
 my $tts              = "";
 my $up               = "";
 my $down             = "";
 my $galaxyout        = "";
 my $bedformat        = "";
 my $jobsubmit        = "";
 my $servicename      = "";
 my $help             = "";
 my $print_version    = "";
 my $version          = "1.0.0";

################### PARAMETER PARSING ####################

my $cmd=$0." ".join(" ",@ARGV); ####command line copy

GetOptions( 
	'output=s'       => \$output,
        'bam=s'          => \$bam,
        'format=s'       => \$bedformat,
        'queue=s'        => \$queue,
        'up=s'           => \$up,
        'down=s'         => \$down,
        'tts=s'          => \$tts,
        'input=s'        => \$input,
        'galaxyout=s'    => \$galaxyout,
        'pngfile=s'      => \$pngfile,
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

pod2usage( {'-verbose' => 0, '-exitval' => 1,} ) if ( ($input eq "") or ($output eq "") or ($bam eq "") );	

 
################### MAIN PROGRAM ####################
    
    if($tts eq "tts")
    {
       $tts="--tts";
    } else { $tts=""; }
    if ($up>0)
    {
      $up="--up $up";
    }else{$up="";}

    if ($down>0)
    {
      $down="--down $down";
    }else{$down="";}
    $output=~/(.*)\/(.*)/;
    my $outdir=$1;
    my $prefix=$2;
    getHtml($outdir,$prefix);
    my $agg="aggregation";
    if ($bam!~/\.bam/)
    {
      $agg="aggregation_bed";
    }
    my $com="";
    my $com="rm -rf $output;source /home/xz18w/ve; bam2x $agg -b $bam -o $output -i $input -I $bedformat $tts $up $down;";
    $com.="cp $output $galaxyout;"; 
    $com.="cp $outdir/$prefix.png $pngfile;";
    print "\n\n\n".$com."\n\n\n";
    if ($queue eq "long")
    {
      my $job=$jobsubmit." -s $servicename -n ".$servicename." -c \"$com\"";
      `$job`;
    }
    else
    {
      `$com`;
    }

sub getHtml{

my ($outdir, $prefix)=@_;

open(OUT, ">$outdir/index.html");

my $html=qq|
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>bam2x aggregation example</title>
  <link rel="stylesheet" href="http://nvd3.org/assets/css/nv.d3.css">
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script src="http://nvd3.org/assets/js/nv.d3.js"></script>
<link rel="stylesheet" href="http://nvd3.org/assets/css/nv.d3.css">
</head>

<body>
<div id="FIGURE" style=" height:100% ; background-color: white" region="center" class="myDiv" title="FIGURE" align="center">
 <div id="chart" class="easyui-resizable" style="padding:20px height:98%;width:98%;border:1px solid">
<svg id="svg"></svg>
</div>
</div>

<script>


  var width = nv.utils.windowSize().width - 40,
        height = nv.utils.windowSize().height - 40;
  var chart = nv.models.lineChart()
                .margin({top: 20, right: 20, bottom: 20, left: 20})
                .transitionDuration(350)
                .useInteractiveGuideline(true)
                .showLegend(true)
                .showYAxis(true)
                .showXAxis(true)
    chart.xAxis     //Chart x-axis settings
      .axisLabel('Pos to TTS')
      .tickFormat(d3.format(',r'));

    chart.yAxis     //Chart y-axis settings
      .axisLabel('Mean Coverage or Gini')
      .tickFormat(d3.format('.02f'));
\$.ajax( {
        url:"$prefix",
        success: function(r) {
            render(parseCSV(r,"\\n","\\t"))
        
        }
}
        );
    
function render(myData)
{


    d3.select('#svg')
      .datum(myData)
      .call(chart);

    nv.utils.windowResize(function() { chart.update() });
    return chart;
  }



function parseCSV(text, lineTerminator, cellTerminator) {

var lines = text.split(lineTerminator);
var aggregation=[],gini=[]

for(var j = 1; j<lines.length; j++){
if(lines[j] != ""){

    var d = lines[j].split(cellTerminator);
    aggregation.push({x: parseInt(d[0]), y: parseFloat(d[1])});
    gini.push({x: parseInt(d[0]), y: parseFloat(d[2])});

}}
  return [
    {
      values: aggregation,
      key: "Aggregation",
      color: "#ff7f0e"
    },
    {
      values: gini,
      key: "Gini",
      color: "#2ca02c"
    },

  ];

}



</script>
</body>

|;
print OUT $html;
close(OUT);
}

__END__


=head1 NAME

stepBam2x.pl

=head1 SYNOPSIS  

stepBam2x.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -t tophatCmd <tophat dir and file> 
            -b bowtie2Ind <ribosome Index file>

stepBam2x.pl -help

stepBam2x.pl -version

For help, run this script with -help option.

=head1 OPTIONS

=head2 -o outdir <output directory>

the output files will be "$outdir/after_ribosome" 

=head2 -b tophatCmd <bowtie dir and file> 

Fullpath of tophat executable file. Ex: ~/tophat_dir/tophat

=head2  -g gtf <ucsc gtf files> 

Transcript annotation file

=head2  -r bowtie2Ind <ribosome Index file>

Bowtie2 index files. Ex: ~/bowtie_ind/hg18

=head2 -help

Display this documentation.

=head2 -version

Display the version

=head1 DESCRIPTION

 This program maps the reads using tophat2

=head1 EXAMPLE

stepBam2x.pl 
            -o outdir <output directory> 
            -g gtf <ucsc gtf files> 
            -t tophatCmd <tophat dir and file> 
            -b bowtie2Ind <ribosome Index file>

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



