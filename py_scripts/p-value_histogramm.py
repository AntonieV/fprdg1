#p-value Histogramm
import pandas as pd
import seaborn as sns

import matplotlib.pyplot as plt

p_value_table = pd.read_csv(snakemake.input[0], sep='\t')
#p_value_table = pd.read_csv('p-values_all_transcripts.csv', sep='\t')

p_value = p_value_table['pval']

p_value = p_value.dropna()

pval_plot = sns.distplot(p_value, kde=False, axlabel="P-Values", color="k", norm_hist=True)
pval_plot.set(ylabel='count')
plt.title("p-value Histogramm")

#plt.show()
plt.savefig(snakemake.output[0])


#so = sleuth_load(snakemake.input[0])  #so=sleuth object
#sleuth_table_gene = sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
#sleuth_table_gene = dplyr::filter(sleuth_table_gene, qval <= 0.05)

#sleuth_table_tx = sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE, pval_aggregate = FALSE)
#sleuth_table_tx = dplyr::filter(sleuth_table_tx, qval <= 0.05)
