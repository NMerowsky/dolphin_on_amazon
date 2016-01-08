#!/share/bin/perl -w
# uploadCounts.pl
#    VERSION: Version 1 (31 August 2011)
#    AUTHOR: Alper Kucukural
#    PURPOSE: Upload Counts to DB
#		    
#             
#    INPUT ARGUMENTS:  
#             countdir: bedfile
#             database: database
#             table   : tablename
#                         
#    OUTPUT FILES: Description of format of output files 
#
#

############## LIBRARIES AND PRAGMAS ################
package CountObj;
 
 use POSIX qw/floor/;
 use List::Util qw[min max];
 use Math::Big qw[factorial euler];
 use strict;
 use File::Basename;
 use DBI;
 use DBD::mysql;
 use POSIX qw(ceil floor);


#################### CONSTANTS ###################### 
my $host = "galaxy.umassmed.edu";
my $user = "biocore";
my $pw = "biocore2013";
#################### VARIABLES ######################
my $countfile = "";
my $database = "";
my $tablename= "";
my $field    = "";
my $CountMod     = "";

################### PARAMETER PARSING ####################
my $cmd=$0." ".join(" ",@ARGV); ####command line copy

# Parse the command line
if (scalar @ARGV==0)
{
  print "Usage:\n";
  print "$0 -c countfile -db database -t table -f field -type [1:geneCounts|2:exonCounts]\n";
  exit;
}
while(scalar @ARGV > 0){
    my $next_arg = shift(@ARGV);
    if($next_arg eq "-c"){ $countfile= shift(@ARGV); }
    elsif($next_arg eq "-db"){ $database= shift(@ARGV); }
    elsif($next_arg eq "-t"){ $tablename= shift(@ARGV); }     
    elsif($next_arg eq "-f"){ $field= shift(@ARGV); }                 
    elsif($next_arg eq "-cm"){ $CountMod= shift(@ARGV); } # If type=1 exon and introncounts will be uploaded together, type=2 only exonic counts will be uploaded 
}


################### PERL DBI CONNECT ####################
#DATA SOURCE NAME
my $dbh=DBI->connect("dbi:mysql:mysql:$host:3306",$user, $pw, {RaiseError=>1}) or die "Couldn't connect:".DBI->errstr();

#No need to prepare a statement handle when we're running
#a command that doesn't return any rows.
$dbh->do("create database if not exists $database");


my $dsn = "dbi:mysql:$database:$host:3306";
$dbh = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database: " . DBI->errstr;

  my @counts=();
  my @fields=();
  readCountsFile(\@counts, \@fields, $countfile);

  if (checkTable(\$dbh, $tablename) eq "null")
  {
     createTable(\$dbh, $tablename, $field, \@fields);
  }
  else
  {
    addField(\$dbh, $tablename, $field, \@fields);
  }
  
  insertFields(\$dbh, \@counts, $tablename, $field, \@fields);    

    
sub readCountsFile
{
my ($counts, $fields, $countfile) = @_;


  my @tmp=();
  open(IN, $countfile);
  my $i=0;
  while(my $line=<IN>)
  {
    chomp($line);
    $line=~s/[\n\r]//gi;
    my @a=split(/[,\s\t]+/, $line);
    if($i==0)
    {
      @{$fields}=@a;
    }
    else
    {
      push(@tmp, \@a);
    }
    $i++;
  }
  @{$counts}=@tmp;
}

sub checkTable
{
my ($dbh, $tablename)=@_;

  
  #runSQL("drop table $tablename", $dbh);
 
  my $res=runSQL("DESCRIBE `$tablename`", $dbh);
  print "[$res]\n";
  return $res;
}

sub addField
{
my ($dbh, $tablename, $set, $fieldnames)=@_;
  for(my $i=2; $i<@{$fieldnames}; $i++)
  { 
    my $SQL="ALTER TABLE `$tablename` ADD `".$set."_".${$fieldnames}[$i]."` FLOAT NOT NULL DEFAULT 0;"; 
    runSQL($SQL, $dbh);
  } 
}

sub createTable
{
my ($dbh, $tablename, $set, $fieldnames)=@_;

  my $SQL="
  CREATE TABLE  `$tablename`(
    `id` bigint(20) NOT NULL auto_increment,
    `name` varchar(20) NOT NULL,
    `chrom` varchar(10) NOT NULL,";

  for(my $i=2; $i<@{$fieldnames}; $i++)
  { 
      $SQL.="`".$set."_".${$fieldnames}[$i]."` float NOT NULL default '0',\n";
  }
  
  $SQL.="PRIMARY KEY  (`id`),
    KEY `idx_name` (`name`)
  ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1"; 

  runSQL($SQL, $dbh);
}

sub insertFields
{
my ($dbh, $counts, $tablename, $set, $fieldnames)=@_;

  my @fieldvals=();
  foreach my $row (@{$counts})
  {  
    @fieldvals=@{$row};   
    my $chrom=$fieldvals[0];
    my $name=$fieldvals[1];

    my $SQL="select id from `$tablename` where chrom='$chrom' and name='$name'";
    my $result = runSelect($SQL, $dbh);
  

     if($result ne "null")
     {
       $SQL="UPDATE `$tablename` set ";
       for(my $i=2; $i<@{$fieldnames}; $i++)
       {
         $SQL.=$set."_".${$fieldnames}[$i]."='".$fieldvals[$i]."'";
         if ($i<@{$fieldnames}-1)
         {
           $SQL.=",";
         }
       }
       $SQL.=" where chrom='$chrom' and name='$name'"; 
     }
     else
     {
       $SQL="INSERT INTO `$tablename`(chrom, name";
       for(my $i=2; $i<@{$fieldnames}; $i++)
       {
           $SQL.=", ".$set."_".${$fieldnames}[$i];
       } 
       $SQL.=")";
       $SQL.="VALUES('$chrom', '$name'";
       for(my $i=2; $i<@{$fieldnames}; $i++)
       {
           $SQL.=", '".$fieldvals[$i]."'";
       } 
       $SQL.=")";
     }
 
    #print $SQL."\n";
    runSQL($SQL, $dbh);
  }
  
}



sub runSQL
{ 
  my ($sSQL, $dbh) = @_;
  #print $sSQL."\n\n\n";
  my $st = ${$dbh}->prepare($sSQL) or  return "null";
  $st->execute()
    or return "null";
  if ($sSQL=~/select/g)
  { 
   my @s=$st->fetchrow_array();
   if (@s>0)
   { 
    return $s[0];  
   }
   else
   {  
    return "null";
   }
  }
}

sub runSelect
{ 
  my ($sSQL, $dbh) = @_;

  my $st = runSQL($sSQL, $dbh);

  return $st;
}

 



