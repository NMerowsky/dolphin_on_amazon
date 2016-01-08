#!/usr/bin/python

from optparse import OptionParser
from ZSI.client import NamedParamBinding as NPBinding, Binding
import json
import os
import re
import cgi
import warnings
import sys
   
url="http://galaxyweb.umassmed.edu/dolphin_amazon/service.php"

re_string = re.compile(r'(?P<htmlchars>[<&>])|(?P<space>^[ \t]+)|(?P<lineend>\r\n|\r|\n)|(?P<protocal>(^|\s)((http|ftp)://.*?))(\s|$)', re.S|re.M|re.I)

def plaintext2html(text, tabstop=4):
    def do_sub(m):
        c = m.groupdict()
        if c['htmlchars']:
            return cgi.escape(c['htmlchars'])
        if c['lineend']:
            return '<br>'
        elif c['space']:
            t = m.group().replace('\t', '&nbsp;'*tabstop)
            t = t.replace(' ', '&nbsp;')
            return t
        elif c['space'] == '\t':
            return ' '*tabstop;
        else:
            url = m.group('protocal')
            if url.startswith(' '):
                prefix = ' '
                url = url[1:]
            else:
                prefix = ''
            last = m.groups()[-1]
            if last in ['\n', '\r', '\r\n']:
                last = '<br>'
            return '%s<a href="%s">%s</a>%s' % (prefix, url, url, last)
    return re.sub(re_string, do_sub, text)



def checkAllJobsFinished(username, wkey, service_name):
    kw = {'url':url}
    b = NPBinding(**kw)
    mesg=b.checkAllJobsFinished(a=username , c=wkey , b=service_name)
    
    data=json.dumps(mesg)
    wkey=json.loads(data)

    ret=str(wkey['return'])
    #print "JOBs checked:"+ret+"\n"
    if (ret.startswith("ERROR")):
                print service_name + ":" + ret + "\n"
                print "Check the service:"+service_name+"\n"
                sys.exit(2);

def insertJob( username, wkey, com, jobname, service_name, jobnum, result):
    
    #print "username="+username+", wkey="+wkey+", com="+com+", jobname="+jobname+", ser="+service_name+", jobnum="+jobnum+", res="+result 
    #kw = {'url':url, 'tracefile':sys.stdout}
    kw = {'url':url}
    b = NPBinding(**kw)
    mesg=b.insertJob(a=username , c=wkey , b=com , e=jobname, d=service_name , f=jobnum, h=result)
    
    data=json.dumps(mesg)
    wkey=json.loads(data)

    ret=str(wkey['return'])
    #print "JOB inserted:"+ret+"\n"
    if (ret.startswith("ERROR")):
                print jobname + ":" + ret + "\n"
                print "Check the job#:"+jobnum+"\n"
                sys.exit(2);

def updateJob( username, wkey, jobname, service_name, field, jobnum, result):
    #print "username="+str(username)+", wkey="+str(wkey)+", jobname="+str(jobname)+", ser="+str(service_name)+", field="+str(field)+", jobnum="+str(jobnum)+", res="+str(result) 
    kw = {'url':url}
    b = NPBinding(**kw)
    mesg=b.updateJob(a=username , c=wkey , b=jobname, e=service_name , d=field, g=jobnum, f=result)
    
    data=json.dumps(mesg)
    wkey=json.loads(data)

    ret=str(wkey['return'])
    #print "JOB updated:"+ret+"\n"
    if (ret.startswith("ERROR")):
                print jobname + ":" + ret + "\n"
                print "Check the job#:"+jobnum+"\n"
                sys.exit(2);

def insertJobOut(username, wkey, jobnum, outdir, edir):
   file=str(outdir)+"/tmp/sge/"+str(jobnum)
   command="python " + edir  + "/readout.py -f "+file
   child = os.popen(command)
   jobout = child.read().rstrip()
   err = child.close()

   if err:
	raise RuntimeError, 'ERROR: %s failed w/ exit code %d' % (command, err) 
   jobout=plaintext2html(re.sub('\'', "\"", jobout))
   kw = {'url':url}
   b = NPBinding(**kw)
   mesg=b.insertJobOut(a=username , c=wkey , b=jobnum, f=jobout)

def main():
   try:
	#python finishJob.py -u kucukura -k nVy1THnthvrRWfXcj187KeDDQrNAkY -s splitFastQ
        parser = OptionParser()
        parser.add_option('-u', '--username', help='defined user in the cluster', dest='username')
        parser.add_option('-k', '--key', help='defined key for the workflow', dest='wkey')
        parser.add_option('-c', '--com', help='bash script of the command', dest='com')
        parser.add_option('-j', '--jobname', help='name of of the job', dest='jobname')
        parser.add_option('-s', '--servicename', help='service name', dest='servicename')
	parser.add_option('-t', '--type', help='type of the operation', dest='type')
	parser.add_option('-n', '--jobnum', help='submitted job number', dest='jobnum')
	parser.add_option('-m', '--message', help='resulting message of the job', dest='message')
	parser.add_option('-o', '--outdir', help='output directory', dest='outdir')


        (options, args) = parser.parse_args()
   except:
	#parser.print_help()
        print "for help use --help"
        sys.exit(2)


   USERNAME                = options.username   
   WKEY                    = options.wkey 
   COM                     = options.com
   JOBNAME                 = options.jobname
   SERVICENAME             = options.servicename
   TYPE			   = options.type
   JOBNUM                  = options.jobnum
   MESSAGE                 = options.message
   OUTDIR                  = options.outdir

        
   edir="/opt/sw/Galaxy/dolphin"

   if (TYPE == "dbSubmitJob"):
	insertJob(USERNAME, WKEY, COM, JOBNAME, SERVICENAME, JOBNUM, MESSAGE) # MESSAGE has jobnum here
   elif (TYPE == "dbSetStartTime"):
        updateJob(USERNAME, WKEY, JOBNAME, SERVICENAME, "start_time", JOBNUM, MESSAGE)  	
   elif (TYPE == "dbSetEndTime"):
        updateJob(USERNAME, WKEY, JOBNAME, SERVICENAME, "end_time", JOBNUM, MESSAGE) 	
        insertJobOut(USERNAME, WKEY, JOBNUM, OUTDIR, edir)

   checkAllJobsFinished(USERNAME, WKEY, SERVICENAME)

if __name__ == "__main__":
    main()


