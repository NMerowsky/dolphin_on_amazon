#!/share/bin/python

from optparse import OptionParser
import os
import urllib, json
import re
import sys
import re
import cgi


url="http://biocore.umassmed.edu/dolphin/ajax/dolphinfuncs.php?p=getFileList"
updateurl="http://biocore.umassmed.edu/dolphin/ajax/dolphinfuncs.php?p=updateHashBackup&input=%(input)s&dirname=%(dirname)s&hashstr=%(hashstr)s"
   
def getFileList():

    response = urllib.urlopen(url);
    data = json.loads(response.read())

    return data

def getValfromFile(filename):
    val=''
    if (os.path.isfile(filename)):
    	infile = open(filename)
    	val = infile.readlines()[0].rstrip()
    else:
    	sys.exit(84)
    return val
 
def calcHash(amazonbucket, inputfile):
   command="mkdir -p /opt/sw/tmp; cd /opt/sw/tmp;"
   amazonbucket = re.sub('s3://biocorebackup/', '', amazonbucket)
   command+="s3cmd get --skip-existing s3://biocorebackup/"+amazonbucket+"/"+inputfile+">/dev/null;"
   command+="md5sum "+inputfile+" > "+inputfile+".md5sum;"
   print command
   child = os.popen(command)
   jobout = child.read().rstrip()
   err = child.close()
   hashstr = getValfromFile("/opt/sw/tmp/"+inputfile+".md5sum").split(" ")[0]
   command="rm -rf /opt/sw/tmp/"+inputfile+"*"
   child = os.popen(command)
   print hashstr
   return hashstr

def runCalcHash(input, dirname, amazon_bucket):
   files=input.split(',')
   count=0
   if (len(files)>1):
     hashstr1=calcHash(amazon_bucket, files[0].strip())
     hashstr2=calcHash(amazon_bucket, files[1].strip())
     hashstr=hashstr1+","+hashstr2
   else:
    hashstr=calcHash(amazon_bucket, input.strip())

   input=urllib.quote(input)
   dirname=urllib.quote(dirname)
   urlstr=updateurl%locals()
   print urlstr
   response = urllib.urlopen(urlstr)
  

def main():

   results=getFileList()
   for result in results:
       
       fastq_dir=result['fastq_dir']
       filename=result['file_name']
       amazon_bucket=result['amazon_bucket']
       print fastq_dir 
       print filename 
       print amazon_bucket
       runCalcHash(filename, fastq_dir, amazon_bucket)

if __name__ == "__main__":
    main()

