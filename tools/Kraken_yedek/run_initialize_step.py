#!/bin/env python
from os import system, makedirs
from os.path import exists, join, basename
from sys import stderr, exit, argv
from kraken_utils import build_description_file
from getopt import getopt
from shutil import copy

usage = '''%s
Options:
-o <outdir>	: Set the root of output directory.
-w <WKEY>	: set the workflow key.
-d <decription file path>
-i <description file contents>
	Note that ' ' needs to be replaced by ',', '\\n' by ':' and ',' by '+'.
-e : base64 encode for the file contents
''' % basename( argv[0] )

#workflow setting read from parameter
outdir_root=''
wkey=''

#fixed part of the command line 
description_fn='description.txt'
user_description_path = ''

#direct parameters for imp_commandline.pl
configuration=''
description=''
dataDir=''

#description file content
description_content =''
encoded_content = 0

options, args = getopt( argv[1:], 'o:k:d:i:eh' )

for option, val in options :
	if option == '-o' :
		outdir_root = val
	elif option == '-k' :
		wkey = val
	elif option == '-d' :
		user_description_path = val
	elif option == '-i' :
		description_content = val
	elif option == '-e' :
		encoded_content = 1
	elif option == '-h' :
		print usage
		exit(0)


if not outdir_root :
	print >>stderr, "Error: Output directory should be set by the -o option!"
	exit(128)

if not wkey :
	print >>stderr, "Error: Wkey should be set by the -w option!"
	exit(128)

outdir = join( outdir_root, wkey )

if not exists( outdir ) :
	makedirs( outdir )

if user_description_path :
	copy( user_description_path, join(outdir, description_fn) )
	#end here!
	exit(0)
else :
	pass

description_path =  join( outdir, description_fn )

#need to check the necessary parameters not defined!
#skipping for now!

fp = open( description_path, 'w' )
build_description_file( description_content, fp, encoded_content=encoded_content )
fp.close()

