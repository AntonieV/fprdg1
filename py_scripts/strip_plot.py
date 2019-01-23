#Stripchart der top20 differentiell exprimierten Gene.
import pandas as pd
import seaborn as sns
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pysam import VariantFile

sleuth_matrix = pd.read_csv(VariantFile(snakemake.input[0]), sep='\t')

sns.set(style="white")
sns.stripplot(x='pval', y='target_id', hue='Condition', data=sleuth_matrix, jitter=False)
#soll ich x und y nicht angeben?
plt.title("Stripchart der top20 differentiell exprimierten Gene")
plt.savefig(snakemake.output[0])

