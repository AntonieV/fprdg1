#Stripchart der top20 differentiell exprimierten Gene.
import pandas as pd
import seaborn as sns

import matplotlib.pyplot as plt

p_value_table = pd.read_csv(snakemake.input[0], sep='\t')
#p_value_table = pd.read_csv('significant_transcripts.csv', sep='\t')

#Tabelle nach aufsteigendem p-Value sortieren
p_value_table = p_value_table.sort_values(by=['pval'], ascending=True)

#neu sortierte Indexe setzen
p_value_table = p_value_table.reset_index(drop=True)

#top20 p-Values speichern
p_value_table = p_value_table.loc[0:20, :]

sns.set(style="white")
#Wo finden wir die Condition?
sns.stripplot(x='pval', y='ext_gene', data=p_value_table, jitter=False)
#soll ich x und y nicht angeben?
plt.title("Stripchart der top20 differentiell exprimierten Gene")

#plt.show()
plt.savefig(snakemake.output[0])
