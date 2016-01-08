# !/usr/bin/python
        
from optparse import OptionParser
import sys
import os
import re
import string
#import time

def runcmd(command): 
    print command
    child = os.popen(command)
    data = child.read()
    print data
    err = child.close()
    if err:
        return 'ERROR: %s failed w/ exit code %d' % (command, err)
    return data

   
def main():

   try:
        parser = OptionParser()
        parser.add_option('-u', '--username', help='defined user in the cluster', dest='username')
        parser.add_option('-d', '--dbhostname', help='defined hostname for the db', dest='dbhostname')
        parser.add_option('-k', '--key', help='defined key for the workflow', dest='wkey')
        parser.add_option('-s', '--servicename', help='service name', dest='servicename')
        parser.add_option('-c', '--command', help='command that is goinf to be run', dest='com')
        parser.add_option('-n', '--name', help='name of the run', dest='name')
        parser.add_option('-p', '--cpu', help='the # of cpu', dest='cpu')
        parser.add_option('-o', '--outdir', help='output directory', dest='outdir')
 	(options, args) = parser.parse_args()
   except:
        print "OptionParser Error:for help use --help"
        sys.exit(2)
   USERNAME    = options.username
   DBHOSTNAME  = options.dbhostname
   WKEY        = options.wkey 
   OUTDIR      = options.outdir 
   SERVICENAME = options.servicename
   COM         = options.com
   NAME        = options.name
   CPU         = options.cpu

   python      = "python";
   
   print WKEY
   #if (WKEY==None):
   #     WKEY=getKey(30);
   if (USERNAME==None):
        USERNAME=os.system('whoami').read();

   if (NAME == None):
        NAME="job";
   com="wget -qO- http://instance-data/latest/meta-data/public-ipv4"
   headNode=str(os.popen(com).readline().rstrip())
  
   #print "COMMAND: [" + com + "]\n"
   #print "NAME: [" + name + "]\n"
   #print "cpu: [" + cpu + "]\n"


   exec_dir=os.path.dirname(os.path.abspath(__file__))
   #print "EXECDIR" + exec_dir
   sdir="/opt/sw/Galaxy/dolphin"
   pbs=OUTDIR + "/tmp/pbs"
   sge=OUTDIR + "/tmp/sge"
   track=OUTDIR + "/tmp/track"
  
   os.system("mkdir -p "+pbs)
   os.system("mkdir -p "+sge)
   os.system("mkdir -p "+track)

   success_file = track+"/"+str(NAME)+".success";
   if not os.path.exists(success_file):
     f = open(pbs+"/"+NAME+".pbs", "w")
     f.write("#BEGIN-OF-FILE\n")
     f.write("#$ -cwd\n")
     if (CPU>1):
        f.write("#$ -pe single "+ CPU + "\n")
     f.write("#$ -o "+ sge + "/$JOB_ID.out -j y\n")
     f.write("#$ -S /bin/sh\n")
     f.write("#$ -V\n")
     f.write("#$ -b y\n")
     f.write("date\n")
     f.write("cd " + exec_dir + "\n")
     f.write("echo \""+COM+"\"\n")
     f.write(python+" " + sdir + "/jobStatus.py -u " + str(USERNAME) + " -k " + str(WKEY) + " -s " + str(SERVICENAME) + " -t dbSetStartTime -n $JOB_ID -j "+ str(NAME)+ " -m 2\n")
     f.write("\n\n"+ COM +"\n\n")
     f.write("retval=$?\necho \"[\"$retval\"]\"\nif [ $retval -eq 0 ]; then\n")
     if (str(NAME) != str(SERVICENAME)):
       f.write("touch "+success_file+"\n")

     f.write(python+" " + sdir + "/jobStatus.py -u " + str(USERNAME) + " -k " + str(WKEY) + " -s " + str(SERVICENAME) + " -o " + str(OUTDIR) + " -t dbSetEndTime -n $JOB_ID -j "+ str(NAME)+ " -m 3\n")
     f.write("  echo success\nelse\n  echo failed\n  date\n  exit 127\nfi\ndate\n")

     f.write("#END-OF-FILE\n")
     f.close();

     os.popen("chmod o+x "+pbs+"/"+NAME+".pbs")

     nodename = str(os.popen("hostname").readlines())
   
     command="qsub "+pbs+"/"+NAME+".pbs";
     print "QSUB:"+command
     if (nodename != "master"):
        command = "ssh "+headNode+" \""+command+"\""
        
     output = runcmd(command)
     words = re.split('[\t\s]+', str(output))
     num = words[2]
    
     command = python+" " + sdir + "/jobStatus.py -u " + str(USERNAME) + " -k " + str(WKEY) + " -s " + str(SERVICENAME) + " -t dbSubmitJob -n "+ str(num) + " -j "+ str(NAME) + " -m 1 -c \"" + str(pbs)+"/"+NAME+".pbs" + "\""
     print "JOBSTATUS:"+command
   
     #if (nodename != "master"):
     #     command = "ssh "+headNode+" \""+command+"\""
   
     if num>0:
        runcmd(command)   
 
if __name__ == "__main__":
    main()
