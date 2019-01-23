import sys
import json
import csv
import pandas as pd
from collections import OrderedDict

###
### gene1_name gene1_id, gene2_name, gene2_id, type, pair, split, txlist
###columns=['geneA.name', 'geneA.id', 'geneB.name', 'geneB.id', 'paircount', 'splitcount', 'transcripts.list']
   

def usage():
    print("Usage: python flatten_json.py fusion.out.json genetable.csv")
    print("")
    print("       outputs a flat table listing all gene fusions")


if __name__ == "__main__":
    nargs = len(sys.argv)
    if nargs <= 1:
        usage()
    else:
        infn = sys.argv[1]
        outf = sys.argv[2]

        fusions = pd.read_json(infn)
        fusions.to_csv(path_or_buf=outf, sep='\t', )

