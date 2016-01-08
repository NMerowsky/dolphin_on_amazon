#!/usr/bin/python

from optparse import OptionParser
import warnings
import sys
import os
import time
   
       
def main():
   try:
	#python finishJob.py -u kucukura -k nVy1THnthvrRWfXcj187KeDDQrNAkY -s splitFastQ
        parser = OptionParser()
	parser.add_option('-n', '--jobnum', help='submitted job number', dest='jobnum')

        (options, args) = parser.parse_args()
   except:
	#parser.print_help()
        print "for help use --help"
        sys.exit(2)


   JOBNUM                  = options.jobnum

   #qstat="export SGE_CELL=default;export PATH=\$PATH:/opt/sge6/bin/linux-x64;export SGE_ROOT=/opt/sge6; export DRMAA_LIBRARY_PATH=/opt/sge6/lib/linux-x64/libdrmaa.so;export SGE_QMASTER_PORT=63231;export SGE_EXECD_PORT=63232;export LDPATH=:/opt/sge6/lib/linux-x64;/opt/sge6/bin/linux-x64/qstat"

   com="qstat|/bin/grep "+str(JOBNUM);

   job=str(os.popen(com).readline().rstrip())
   if (len(job) > 2):
       print job
   else:
     com="qacct -j "+str(JOBNUM)+" 2>&1|grep exit_status|awk '{print $2}'"
     getres=True
     i=1
     while getres:
        time.sleep(2)
        res= str(os.popen(com).readline().rstrip())
        if (len(res)>0 or i>10):
           getres=False
           if (res!="0" or i>10):
              print "EXIT "+res+": JOB# "+str(JOBNUM)
        i+=1
        
        if res==0:
            print "DONE"
if __name__ == "__main__":
    main()


