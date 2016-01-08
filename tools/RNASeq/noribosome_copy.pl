#!/share/bin/perl 

open in,"input.txt";
 $folder=<in>;
 $_=<in>;
 s/\,/\t/g;
 s/END//;
 @files=split;
close in;

`mkdir after_ribosome`;
for($i=0;$i<$#files;$i+=2) 
{
 `cp $files[$i] after_ribosome/$files[$i]\_1.notR`;
 `cp $files[$i+1] after_ribosome/$files[$i]\_2.notR`;
}
