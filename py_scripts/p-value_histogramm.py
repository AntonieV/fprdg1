#p-value Histogramm
import pandas as pd
import seaborn as sns
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pysam import VariantFile

daten = pd.read_csv(VariantFile(snakemake.input[0]), sep='\t')
p-value=daten['pval']
p=sns.distplot(p-value, kde=False, axlabel="P-Values", color="k", norm_hist=True)
p.set(ylabel='count')
plt.title("p-value Histogramm")
plt.savefig(snakemake.output[0])


#so = sleuth_load(snakemake.input[0])  #so=sleuth object
#sleuth_table_gene = sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
#sleuth_table_gene = dplyr::filter(sleuth_table_gene, qval <= 0.05)

#sleuth_table_tx = sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE, pval_aggregate = FALSE)
#sleuth_table_tx = dplyr::filter(sleuth_table_tx, qval <= 0.05)


