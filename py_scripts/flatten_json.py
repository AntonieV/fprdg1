import sys
import json
import csv
from collections import OrderedDict

###
### gene1_name gene1_id, gene2_name, gene2_id, type, pair, split, txlist

def loadJSON(fn):
    with open(fn) as f:
        JJ = json.load(f,object_pairs_hook=OrderedDict)
    return JJ['genes']

def outputGeneTable(fusions, outf, filters = None):
    with open(outf, 'w') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csvwriter.writerow(['\t'.join(["geneA.name", "geneA.id", "geneB.name", "geneB.id", "paircount", "splitcount", "transcripts.list"])])
        
        
        for gf in fusions:
            gAname = gf['geneA']['name']
            gAid   = gf['geneA']['id']
            gBname = gf['geneB']['name']
            gBid   = gf['geneB']['id']
            pairs  = str(gf['paircount'])
            split  = str(gf['splitcount'])
            txp = [tp['fasta_record'] for tp in gf['transcripts']]

            csvwriter.writerow(['\t'.join([gAname, gAid, gBname, gBid, pairs, split, ';'.join(txp)])])

def usage():
    print("Usage: python flatten_json.py fusion.out.json [genetable.txt]")
    print("")
    print("       outputs a flat table listing all gene fusions, if the output file is not")


if __name__ == "__main__":
    nargs = len(sys.argv)
    if nargs <= 1:
        usage()
    else:
        infn = sys.argv[1]
        fusions = loadJSON(infn)
        outf = sys.stdout
        
        outputGeneTable(fusions,sys.argv[2])

        if outf != sys.stdout:
            outf.close()
