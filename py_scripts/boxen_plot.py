#Boxenplots der (normalisierten) Counts aller Samples
import pandas as pd
import seaborn as sns
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pysam import VariantFile

daten = pd.read_csv(VariantFile(snakemake.input[0]), sep='\t')
sns.boxenplot(data=daten, scale = "linear");
plt.title("Boxenplots der (normalisierten) Counts aller Samples")
plt.savefig(snakemake.output[0])