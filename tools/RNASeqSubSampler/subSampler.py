import random
import sys

def write_random_records(fq, fo, N=100000):
    """ get N random headers from a fastq file without reading the
    whole thing into memory"""
    records = sum(1 for _ in open(fq)) / 4
    rand_records = sorted([random.randint(0, records - 1) for _ in xrange(N)])

    fh = open(fq)
    sub = open(fo, "w")
    rec_no = - 1
    for rr in rand_records:

        while rec_no < rr:
            rec_no += 1       
            for i in range(4): fh.readline()
        for i in range(4):
            sub.write(fh.readline())
        rec_no += 1 # (thanks @anderwo)

    print >>sys.stderr, "wrote to %s" % (sub.name)

if __name__ == "__main__":
    N = 100 if len(sys.argv) < 4 else int(sys.argv[3])
    write_random_records(sys.argv[1], sys.argv[2], N)
