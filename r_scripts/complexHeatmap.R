##############################################################
######### Installation Bioconductor - ComplexHeatmap #########

#if (!requireNamespace("BiocManager"))
#  install.packages("BiocManager")
#BiocManager::install()

## try http:// if https:// URLs are not supported
#source("https://bioconductor.org/biocLite.R")
#biocLite("ComplexHeatmap")

##############################################################

suppressMessages({
  library("sleuth")
})

library(ComplexHeatmap)
library(circlize)

######################## Laden der csv-Sleuth-Daten #############################


current.dir <- getwd()
setwd("../sleuth")
path <- getwd()


sleuth.tmp <- read.table("significant_transcripts.csv", header = TRUE, 
                                 stringsAsFactors = FALSE)

names(sleuth.tmp)[1] <- "target_id" # Korrektur des Spaltennamens fuer die Transcript-IDs

sleuth.sig <- data.frame(sleuth.tmp$target_id, stringsAsFactors = FALSE)

##################### Alternativ Laden des Sleuth-Objektes #####################
#readRDS()
#sleuth_load('sleuth/so')

setwd(current.dir)

#Liste der csv-Dateien im Verzeichnis /sleuth, also Ergebnisse der Sleuth-Analyse
#regular Expressions: ".*" (jedes Zeichen beliebig oft, "^" (leeres Wort am Anfang), 
#                     "$"(leeres Wort am Ende))



sleuth_path <- list.files(path, pattern = ".*significant_transcripts{1}.*\\.csv$")
#sleuth_path <- gsub(" ","",paste(path, "/", sleuth_path))
sleuth_path <- unlist(sleuth_path)

setwd(path)

for(i in seq(along=sleuth_path)){
  result.sleuth <- read.table(sleuth_path[i], header = TRUE)
  sleuth.sig <- rbind(c(sleuth.sig, result.sleuth[names(result.sleuth) == "pval"]))
}
  
extract.sleuth.datas <- function(sleuth_path, sleuth.sig){
  
  results.sleuth <- read.table(sleuth_path, header = TRUE)
  sleuth.sig <- rbind(sleuth.sig, result.sleuth[names(result.sleuth) == "pval"])
}

sleuth.sig <- lapply(sleuth_path, sleuth_path[1], extract.sleuth.datas(sleuth_path, sleuth.sig))

#######################################################################
######## ZUM DEBUGGEN: Ausgabe der Hilfstabelle in der Konsole ########


#matr.sleuth.sig <-









set.seed(123)

mat = cbind(rbind(matrix(rnorm(16, -1), 4), matrix(rnorm(32, 1), 8)),
            rbind(matrix(rnorm(24, 1), 4), matrix(rnorm(48, -1), 8)))

# permute the rows and columns
mat = mat[sample(nrow(mat), nrow(mat)), sample(ncol(mat), ncol(mat))]

rownames(mat) = paste0("R", 1:12)
colnames(mat) = paste0("C", 1:10)

Heatmap(mat, clustering_distance_rows = "pearson")

mat2 = mat
mat2[1, 1] = 100000
Heatmap(mat2, col = colorRamp2(c(-3, 0, 3), c("darkgreen", "white", "darkred")), 
        cluster_rows = FALSE, cluster_columns = FALSE, clustering_distance_rows = "pearson")

mat_with_na = mat
mat_with_na[sample(c(TRUE, FALSE), nrow(mat)*ncol(mat), replace = TRUE, prob = c(1, 9))] = NA
Heatmap(mat_with_na, na_col = "black", clustering_distance_rows = "pearson")
  
  
  
