import numpy as np
#import matplotlib
#matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd
import os
from pysam import VariantFile

from itertools import cycle
cycol = cycle('bgrcmk')

#from sklearn.datasets import load_iris
from sklearn.decomposition import PCA

#iris = load_iris()
#X = iris.data
#y = iris.target

path = os.getcwd()

#sleuth_matrix = pd.read_csv('sleuth_matrix.csv', sep='\t')
sleuth_matrix = pd.read_csv(VariantFile(snakemake.input[0]), sep='\t')

samples = list(sleuth_matrix)
count_sam = sleuth_matrix.shape[1]

ind = list(range(0, count_sam))

print("indizes: ")
print(ind)

print("anzahl spalten: ")
print(count_sam)

print("Sleuth Matrix: ")
#print(sleuth_matrix)

sleuth_matrix = sleuth_matrix.transpose()


print("Sample array: ")
print samples
n_components = 2

pca = PCA(n_components=n_components)

sl_pca = pca.fit_transform(sleuth_matrix)

print("Sleuth PCA")

print(sl_pca)


#colors = ['navy', 'turquoise', 'darkorange', 'red']
colors = list(np.random.choice(range(256), size=count_sam))
plt.figure(figsize=(8, 8))
for color, i, sam in zip(colors, ind, samples):
    plt.scatter(sl_pca[i, 0], sl_pca[i, 1], color=next(cycol), lw=2, label=sam)
plt.title("PCA of Transcriptexpression")
plt.legend(loc="best", shadow=False, scatterpoints=1)
plt.axis([-40, 40, -1.5, 1.5])

plt.show()
#plt.savefig("Plots/Plot.svg")

plt.savefig(snakemake.output[0])
