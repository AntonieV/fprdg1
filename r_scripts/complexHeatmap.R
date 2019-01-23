library(ComplexHeatmap)
#library(rsvg)
library(circlize)

#Input zum direkten Testen ohne Workflow
#path.matr <- "../sleuth/sleuth_matrix.csv"
#path.dist <- "../clustering_distance.txt"

#Snakemake-Input
path.matr <- snakemake@input[["matrix"]]
path.dist <- snakemake@input[["dist"]]
path.p_all <- snakemake@input[["p_all"]]

write("\n", file = path.dist, append = TRUE)

matr.so <- read.table(path.matr)
dist <- gsub("[[:space:]]", "", unlist(read.table(path.dist, stringsAsFactors = FALSE)))

#NA-Zeilen entfernen
matr.so <- na.omit(matr.so)

#Null-Zeilen entfernen
matr.so <- subset.matrix(matr.so, rowSums(matr.so)!=0)

#Bestimmung von Median(.5-Quantil) und der Quartile fuer die Faerbung der Heatmap
so.min <- min(matr.so)
so.quantiles <- rowMeans(apply(matr.so, 2, quantile, probs = c(.25, .5, .75)))

#Heatmap wird aufgebaut
svg(file=snakemake@output[[1]])
Heatmap(matr.so, 
        name = "normalized\nestimated\ncounts", 
        column_title = "Samples",
        column_names_side = "top",
        row_title = "Transcripts",
        row_names_side = "right",
        row_dend_side = "left",
        col = colorRamp2(c(so.min, so.quantiles), c("darkgreen", "green", "darkred", "red")), 
        cluster_rows = TRUE, 
        cluster_columns = TRUE, 
        clustering_distance_rows = dist)
dev.off()