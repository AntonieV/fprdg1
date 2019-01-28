import matplotlib.pyplot as plt
import pandas as pd
from sklearn.decomposition import PCA

sleuth_matrix = pd.read_csv(snakemake.input[0], sep='\t')

samples = list(sleuth_matrix)
count_sam = sleuth_matrix.shape[1]

ind = list(range(0, count_sam))

sleuth_matrix = sleuth_matrix.transpose()

n_components = 2

pca = PCA(n_components=n_components)

sl_pca = pca.fit_transform(sleuth_matrix)

colors = plt.cm.get_cmap("hsv", count_sam+1)

plt.figure(figsize=(8, 8))
for i, sam in zip(ind, samples):
    plt.scatter(sl_pca[i, 0], sl_pca[i, 1], color=colors(i), lw=2, label=sam)
plt.title("PCA of Transcriptexpression")
plt.legend(loc="best", shadow=False, scatterpoints=1)


#plt.show()

plt.savefig(snakemake.output[0])
