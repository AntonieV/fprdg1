#Boxenplots der (normalisierten) Counts aller Samples
import pandas as pd
import seaborn as sns
#import matplotlib
#matplotlib.use("Agg")
import matplotlib.pyplot as plt
#from pysam import VariantFile

#daten = pd.read_csv('sleuth_matrix.csv', sep='\t')
sleuth_matrix = pd.read_csv(snakemake.input[0], sep='\t')
sns.boxenplot(data=sleuth_matrix, scale = "linear");
plt.title("Boxenplots der (normalisierten) Counts aller Samples")

#plt.savefig('boxenplot.svg')
plt.savefig(snakemake.output[0])
