"""
    This tool recursively map sequenced files to any number of index files in given order. 
 
    usage: offtargetanalysis.py [options]
    --inputfile: Sequence input file path that contains sequences to be searched for potential gRNAs
    --outputdir: output directory
    --output: output file
    --user_email: user email address 
    --bsgenomename: genome build 
    --maxmismatch: Maximum mismatch allowed in off target search, default 3. Warning: will be considerably slower if set > 3    
    --exportAllgRNAs: Indicate whether to output all potential gRNAs to a file in fasta format, genbank format or both. Default to both.
    --findPairedgRNAOnly: Choose whether to only search for paired gRNAs in such an orientation that the first one is on minus strand called reverse gRNA and the second one is on plus strand called forward gRNA. TRUE or FALSE, default FALSE
    --mingap: Min Gap, default 0
    --maxgap: Max Gap, default 20
    --PAMsize: PAM length, default 3
    --PAM: PAM sequence after the gRNA, default NGG
    --PAMPattern: Regular expression of protospacer-adjacent motif (PAM), default N[A|G]G$
    --gRNAsize: The size of the gRNA, default 20
    --minscore: minimum score of an off target to included in the final output, default 0.5
    --topN: top N off targets to be included in the final output, default 100
    --topNOfftargetTotalScore: top N off target used to calculate the total off target score, default 10
    --annotateExon: Choose whether or not to indicate whether the off target is inside an exon or not, default TRUE
    --fetchSequence: Fetch flank sequence of off target or not, default TRUE
    --upstream: upstream offset from the off target start, default 200
    --downstream: downstream offset from the off target end default 200
    --weights: numeric vector size of gRNA length, default 0, 0, 0.014, 0, 0, 0.395, 0.317, 0, 0.389, 0.079, 0.445, 0.508, 0.613, 0.851, 0.732, 0.828, 0.615, 0.804, 0.685, 0.583 which is used in Hsu et al., 2013 cited in the reference section  

    usage: offtargetanalysis.py --inputfile --outputdir --user_email --output --bsgenomename
"""
# imports
import os, re, string, sys
from sys import argv, exit, stderr
from optparse import OptionParser
from os.path import dirname, exists, join
from os import system
from subprocess import Popen, PIPE

bin_dir = dirname(argv[0])

#genome definitions
bsgenomenamedict = {
 "hg18" : "Hsapiens", 
 "hg19" : "Hsapiens", 
 "mm10" : "Mmusculus",
 "mm9"  : "Mmusculus",
 "ce10" : "Celegans",
 "ce9"  : "Celegans",
 "rn5"  : "Rnorvegicus",
 "rn4"  : "Rnorvegicus",
 "dm3"  : "Dmelanogaster",
 "danRer7" : "Drerio",
 "bosTau6" : "Btaurus",
 "sacCer3" : "Scerevisiae",
 "sacCer2" : "Scerevisiae",
 "rheMac3" : "Mmulatta" 
}

bsgenomesdict = {
 "hg18" : "BSgenome.Hsapiens.UCSC.hg18", 
 "hg19" : "BSgenome.Hsapiens.UCSC.hg19", 
 "mm10" : "BSgenome.Mmusculus.UCSC.mm10",
 "mm9"  : "BSgenome.Mmusculus.UCSC.mm9",
 "ce10" : "BSgenome.Celegans.UCSC.ce10",
 "ce9"  : "BSgenome.Celegans.UCSC.ce9",
 "rn5"  : "BSgenome.Rnorvegicus.UCSC.rn5",
 "rn4"  : "BSgenome.Rnorvegicus.UCSC.rn4",
 "dm3"  : "BSgenome.Dmelanogaster.UCSC.dm3",
 "danRer7" : "BSgenome.Drerio.UCSC.danRer7",
 "bosTau6" : "BSgenome.Btaurus.UCSC.bosTau6",
 "sacCer3" : "BSgenome.Scerevisiae.UCSC.sacCer3",
 "sacCer2" : "BSgenome.Scerevisiae.UCSC.sacCer2",
 "rheMac3" : "BSgenome.Mmulatta.UCSC.rheMac3" 
}

txdbdict = {
 "hg18" : "TxDb.Hsapiens.UCSC.hg18.knownGene", 
 "hg19" : "TxDb.Hsapiens.UCSC.hg19.knownGene", 
 "mm10" : "TxDb.Mmusculus.UCSC.mm10.knownGene",
 "mm9"  : "TxDb.Mmusculus.UCSC.mm9.knownGene",
 "rn5"  : "TxDb.Rnorvegicus.UCSC.rn5.refGene",
 "rn4"  : "TxDb.Rnorvegicus.UCSC.rn4.refGene",
 "dm3"  : "TxDb.Dmelanogaster.UCSC.dm3.ensGene",
 "sacCer3" : "TxDb.Scerevisiae.UCSC.sacCer3.sgdGene",
 "sacCer2" : "TxDb.Scerevisiae.UCSC.sacCer2.sgdGene"
}

genomeanndict = {
 "hg18" : "org.Hs.eg.db", 
 "hg19" : "org.Hs.eg.db", 
 "mm10" : "org.Mm.eg.db",
 "mm9"  : "org.Mm.eg.db",
 "ce10" : "org.Ce.eg.db",
 "ce9"  : "org.Ce.eg.db",
 "rn5"  : "org.Rn.eg.db",
 "rn4"  : "org.Rn.eg.db",
 "dm3"  : "org.Dm.eg.db",
 "danRer7" : "org.Dr.eg.db",
 "sacCer3" : "org.Sc.sgd.db",
 "sacCer2" : "org.Sc.sgd.db",
 "rheMac3" : "org.Mmu.eg.db" 
}

organndict = {
 "hg18" : "org.Hs.egSYMBOL", 
 "hg19" : "org.Hs.egSYMBOL", 
 "mm10" : "org.Mm.egSYMBOL",
 "mm9"  : "org.Mm.egSYMBOL",
 "ce10" : "org.Ce.egSYMBOL",
 "ce9"  : "org.Ce.egSYMBOL",
 "rn5"  : "org.Rn.egSYMBOL",
 "rn4"  : "org.Rn.egSYMBOL",
 "dm3"  : "org.Dm.egFLYBASE2EG",
 "danRer7" : "org.Dr.egSYMBOL",
 "sacCer3" : "org.Sc.sgdGENENAME",
 "sacCer2" : "org.Sc.sgdGENENAME",
 "rheMac3" : "org.Mmu.egSYMBOL" 
}

# error
def stop_err( msg ):
    sys.stderr.write( "%s\n" % msg )
    sys.exit()

# main
def main():
    # define options
    parser = OptionParser()
    parser.add_option("-i", "--inputfile", dest="inputfile")
    parser.add_option("-o", "--outputdir", dest="outputdir")
    parser.add_option("-f", "--output", dest="output")
    parser.add_option("-u", "--user_email", dest="useremail")
    parser.add_option("-b", "--bsgenomename", dest="bsgenomename")
    parser.add_option("-m", "--maxmismatch", dest="maxmismatch")
    parser.add_option("-e", "--exportAllgRNAs", dest="exportAllgRNAs")
    parser.add_option("", "--findPairedgRNAOnly", dest="findPairedgRNAOnly")
    parser.add_option("", "--mingap", dest="mingap")
    parser.add_option("", "--maxgap", dest="maxgap")
    parser.add_option("", "--PAMsize", dest="PAMsize")
    parser.add_option("", "--PAM", dest="PAM")
    parser.add_option("", "--PAMPattern", dest="PAMPattern")
    parser.add_option("", "--gRNAsize", dest="gRNAsize")
    parser.add_option("", "--minscore", dest="minscore")
    parser.add_option("", "--topN", dest="topN")
    parser.add_option("", "--topNOfftargetTotalScore", dest="topNOfftargetTotalScore")
    parser.add_option("", "--annotateExon", dest="annotateExon")
    parser.add_option("", "--fetchSequence", dest="fetchSequence")
    parser.add_option("", "--upstream", dest="upstream")
    parser.add_option("", "--downstream", dest="downstream")
    parser.add_option("", "--weights", dest="weights")
    parser.add_option("-j", "--jobsubmit", dest="jobsubmit")
    parser.add_option("-s", "--servicename", dest="servicename")
    parser.add_option("", "--chromToSearch", dest="chromToSearch")

    # parse
    options, args = parser.parse_args()
    
    try:
        # retrieve options
        inputfile                 = options.inputfile
        outputdir                 = options.outputdir
        output                    = options.output
        username                  = options.useremail
        bsgenomename              = options.bsgenomename
        maxmismatch               = options.maxmismatch
        exportAllgRNAs            = options.exportAllgRNAs
        findPairedgRNAOnly        = options.findPairedgRNAOnly
        mingap                    = options.mingap  	
        maxgap                    = options.maxgap  	
        PAMsize                   = options.PAMsize 	
        PAMPattern                = options.PAMPattern 	
        PAM                       = options.PAM  	
        gRNAsize                  = options.gRNAsize 	
        minscore                  = options.minscore  	
        topNOfftargetTotalScore   = options.topNOfftargetTotalScore
        topN                      = options.topN
        annotateExon              = options.annotateExon	
        fetchSequence             = options.fetchSequence 	
        upstream                  = options.upstream
        downstream                = options.downstream  	
        weights                   = options.weights	
        chromToSearch             = options.chromToSearch
 
  
	if not inputfile :
		print >>stderr, 'Error: Input file is not defined.'
		exit( 128 )

	if not outputdir :
		print >>stderr, 'Error: Output dir is not defined.'
		exit( 128 )

        print outputdir 
        
    
    except Exception, ex:
        stop_err('Error running offtargetanalysis.py\n' + str(ex))

    runCRISPRSeek( inputfile, outputdir, output, username, bsgenomename, maxmismatch, 
                 exportAllgRNAs, findPairedgRNAOnly, mingap, maxgap, PAMsize, PAMPattern, 
                 PAM, gRNAsize, minscore, topNOfftargetTotalScore, topN, annotateExon, 
                 fetchSequence, upstream, downstream, weights,chromToSearch)
    sys.exit(0)

def runCRISPRSeek( inputfile, outputdir, output, username, bsgenomename, maxmismatch, 
                 exportAllgRNAs, findPairedgRNAOnly, mingap, maxgap, PAMsize, PAMPattern, 
                 PAM, gRNAsize, minscore, topNOfftargetTotalScore, topN, annotateExon, 
                 fetchSequence, upstream, downstream, weights,chromToSearch):
        if (inputfile.startswith('__gt__')):
            fp = open ( outputdir+"/inputfile.fa", 'w') 
	    print >>fp, '%s'%parse_content(inputfile)
            fp.close()
            inputfile=outputdir+"/inputfile.fa"
            
        

        print  outputdir+"/offtargetanalysis.R"
        bsgenomename=bsgenomename.split(',')[1]

        fp = open ( outputdir+"/offtargetanalysis.R", 'w') 
        print bsgenomename+":"+getName(bsgenomename, "library(%s)", bsgenomesdict)
  
        Rprog="library(CRISPRseek)\n"
        Rprog+=getName(bsgenomename, "library(%s)\n", bsgenomesdict) 
        Rprog+=getName(bsgenomename, "library(%s)\n", txdbdict) 
        Rprog+=getName(bsgenomename, "library(%s)\n", genomeanndict)

        Rprog+="outputDir <- file.path('"+outputdir+"','CRISPRSeek' )\n"
        Rprog+="offTargetAnalysis('%s',\n"%inputfile
        Rprog+=getName(bsgenomename, "   BSgenomeName = %s,\n", bsgenomenamedict) 
        Rprog+=getName(bsgenomename, "   txdb = %s,\n", txdbdict)
        Rprog+="   REpatternFile = system.file('extdata', 'NEBenzymes.fa', package = 'CRISPRseek'),\n"
        if (maxmismatch > 0):
           Rprog+="   max.mismatch=%s,\n"%str(maxmismatch)
        if (len(getName(bsgenomename, '%s', organndict))>0):
           Rprog+=getName(bsgenomename, "   orgAnn = %s,\n", organndict) 
        if ( findPairedgRNAOnly == "Yes"):
           Rprog+="   findPairedgRNAOnly=TRUE,\n"
           Rprog+="   min.gap=%s,\n"%str(mingap)
           Rprog+="   max.gap=%s,\n"%str(maxgap)
        if (exportAllgRNAs != "all" and exportAllgRNAs.find('@')==-1):
           Rprog+="   exportAllgRNAs='%s',\n"%str(exportAllgRNAs)
        if (PAMsize and PAMsize.find('@')==-1):
           Rprog+="   PAM.size=%s,\n"%str(PAMsize)
        if (PAMPattern and PAMPattern.find('@')==-1):
           rep={'__ob__' : '[', '__cb__' : ']', '_p_' : '|', '_d_' : '$'}
           for k,v in rep.iteritems():
              PAMPattern = PAMPattern.replace(k, v)
           Rprog+="   PAM.pattern='%s',\n"%str(PAMPattern)
        if (PAM and PAM.find('@')==-1):
           Rprog+="   PAM='%s',\n"%str(PAM)
        if (gRNAsize and gRNAsize.find('@')==-1):
           Rprog+="   gRNA.size=%s,\n"%str(gRNAsize)
        if (minscore and minscore.find('@')==-1):
           Rprog+="   min.score=%s,\n"%str(minscore)
        if (chromToSearch != "all" and chromToSearch.find('@')==-1):
           Rprog+="   chromToSearch ='%s',\n"%chromToSearch
        if (topN and topN.find('@')==-1):
           Rprog+="   topN=%s,\n"%str(topN)
        if (topNOfftargetTotalScore and topNOfftargetTotalScore.find('@')==-1):
           Rprog+="   topN.OfftargetTotalScore=%s,\n"%str(topNOfftargetTotalScore)
        if (annotateExon=="True"):
           Rprog+="   annotateExon=TRUE,\n"
        if (fetchSequence=="True"):
           Rprog+="   fetchSequence=TRUE,\n"
           Rprog+="   upstream=%s,\n"%upstream
           Rprog+="   downstream=%s,\n"%downstream
        if (weights and weights.find('@')==-1):
           Rprog+="   weight=c(%s),\n"%weights
        
        Rprog+="   outputDir = outputDir, overwrite = TRUE)\n\n"

   

        print Rprog

	print >>fp, '%s'%Rprog
         
	fp.close()
	command_line = 'module load R/3.1.0;Rscript --no-save %s/offtargetanalysis.R'%outputdir;

	print command_line
	exit_status = system( command_line )

	exit( exit_status ) 

def getName( name, str, dict ):
        buf=''
        if name in dict.keys():
           print str%dict[name]
           buf = str%dict[name] 
        return buf

def write_workflow( file ):
        fp = open ( file, 'w') 
        sep='\t'

        stepline=step % locals()
        print >>fp, '%s'%stepline
        fp.close()

class NoContentParsedError( Exception ) :
	pass
class ContentFormatError( Exception ) :
	pass

def replace_space(content) :
        content = re.sub('[\s\t,]+', '_', content)
        return content

def parse_content( content, ncols=8, base64=False, verbose=0 ) :
	'''
	This is a function that parse the inputparam content and 
	returns the base64 encoded string if base64 is True otherwise 
	returns the concatenated string with by the conversion to make
	('\t' -> ',', ' ' -> ',', '\n'->':').
	'''

	content = content.replace( '__gt__', '>' ) 
	content = re.sub( ':', '\n', content ) 
        return content

if __name__ == "__main__":
    main()
