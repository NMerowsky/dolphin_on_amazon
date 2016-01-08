#!/bin/env python
from sys import stderr, exit, argv
from os import system, makedirs, chdir
from os.path import exists, join, split, basename
from kraken_utils import which, NoPathFoundError, TooManyPathFoundError, find_analysis_dir
from getopt import getopt

usage='''%s [-s <step> -o <out_dir> -k <wkey> -d <dataDir> -a <annotationDir> --configuration=<config_string>]
''' % basename( argv[0] )

#dolphin parameters
outdir_root = ''
wkey = ''

#fixed part of the command line 
cmd='imp_commandline.pl'
step = ''

'''
#temporarily blocked
try :
	which(cmd)
except NoPathFoundError :
	print >>stderr, 'Error:', cmd, 'not found!'
	exit(127)
'''

#direct parameters for imp_commandline.pl
configuration=''
description_fn='description.txt'
dataDir=''
analysisDir=''
annotationDir=''

options, args = getopt( argv[1:], 's:d:k:o:a:h', ['configuration=' ] )

for option, val in options :
	if option == '--configuration' :
		configuration = val
	elif option == '-s' :
		step = val
	elif option == '-d' :
		dataDir = val
	elif option == '-k' :
		wkey = val
	elif option == '-o' :
		outdir_root = val
	elif option == '-a' :
		annotationDir = val
	elif option == '-h' :
		print usage
		exit(0)

if not dataDir :
	print >>stderr, "Error: data directory should be set with the -d option."
	exit(128)

if not outdir_root :
	print >>stderr, "Error: Output directory should be set with the -o option."
	exit(128)

if not wkey :
	print >>stderr, "Error: Wkey should be set with the -k option."
	exit(128)

if not configuration :
	print >>stderr, "Error: configuration should be set."
	exit(128)


outdir = join( outdir_root, wkey )
if exists( outdir ) :
	pass
else :
	makedirs( outdir )

chdir( outdir )

description = description_fn 
if exists( description ) :
	pass
else :
	print >>stderr, "Error: description file is missing!"
	exit(128)

try :
	analysisDir = find_analysis_dir()
except TooManyPathFoundError :
	print >>stderr, "Error: Too many analysis directories!"
	exit(128)
except NoPathFoundError :
	if step == 'organise' :
		pass
	else :
		print >>stderr, "Error: No analysis directories are found!"
		exit(128)

annotation_parameter = ''
if annotationDir :
	annotation_parameter = '--annotationDir=%s'%annotationDir

analysis_parameter = ''
if analysisDir :
	analysis_parameter = '--analysisDir=%s'%analysisDir


command_line = 'module load seqimp/13-274; %(cmd)s --step=%(step)s --description=%(description)s --default-configuration=%(configuration)s --dataDir=%(dataDir)s %(annotation_parameter)s %(analysis_parameter)s'%locals()
exit_status = system( command_line )

exit( exit_status )
