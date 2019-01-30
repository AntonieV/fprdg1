#install.packages("/home/tharja/Schreibtisch/Software/XML_3.98-1.16.tar.gz", repos = NULL)
#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install("gage", version = "3.8")
#BiocManager::install("gageData", version = "3.8")
#install.packages("XML")
#BiocManager::install("KEGGgraph", version = "3.8")
#BiocManager::install("pathview", version = "3.8")

library(gage)
library(gageData)
library(pathview)
library(dplyr)

#p_all <- read.table("../sleuth/p-values_all_transcripts.csv", header=TRUE)
#matr <- read.table("../sleuth/sleuth_matrix.csv", header=TRUE)
#samples <- read.table("../table_for_reads.csv", header=TRUE, stringsAsFactors = TRUE)

p_all <- read.table(snakemake@input[["pval"]], header=TRUE)
matr <- read.table(snakemake@input[["matrix"]], header=TRUE)
samples <- read.table(snakemake@input[["samples"]], header=TRUE, stringsAsFactors = TRUE)

#p_all ist nach pval sortiert, wird nun wie Matrix nach Gen-ID angeordnet:
p_all <- dplyr::arrange(p_all, target_id)

if(any(p_all$target_id != row.names(matr))){
  stop("Die Datenmatrix mit der Anzahl der Counts und der Datensatz 
       der Signifikanzanalyse aus Sluth sind verschieden!")
  quit(status = 1, runLast = FALSE)
  
}
#Ersetzen der target_id durch Gen-Namen
rownames(matr) = make.names(p_all$ext_gene, unique = TRUE)

condition_1 <- samples$sample[samples$condition == as.character(factor(samples$condition)[1])]
condition_2 <- samples$sample[samples$condition == as.character(factor(samples$condition)[2])]

samples.cond_1 <- matr[][as.character(samples$sample[condition_1])]
samples.cond_2 <- matr[][as.character(samples$sample[condition_2])]

#log2-FoldChange   
FoldChange <- rowSums(samples.cond_2)/rowSums(samples.cond_1)
log2FC <- log2(FoldChange)

p_val <- p_all$pval
q_val <- p_all$qval

#Anlegen des Dataframes fuer den Gage mit:
#Gen/Target-ID, 
#FoldChange(log2), 
#p-Werten aus der Sleuth-Analyse und 
#den durch Post-Hoc-Tests normaliesierten p-Werten (qval, also Korrektur der 
#Alphafehler-Kumulierung beim multiplen Testen) aus der Sleuth-Analyse

gage.data <- data.frame(TragetID = p_all$target_id, EnsembleID = p_all$ens_gene, 
                        GeneID = p_all$ext_gene, log2FoldChange = log2FC, 
                        pVal = p_val, PostHoc_pValues = q_val, Mean = p_all$mean_obs)
gage.data <- na.omit(gage.data)

detach("package:dplyr", unload=TRUE)

data(kegg.sets.hs)
data(sigmet.idx.hs)
kegg.sets.hs <- kegg.sets.hs[sigmet.idx.hs]

# Get the results
keggres <- gage(gage.data$log2FoldChange, gsets=kegg.sets.hs, same.dir=TRUE)
# Look at both up (greater), down (less), and statatistics.
lapply(keggres, head)

# Get the pathways
keggrespathways <- data.frame(id=rownames(keggres$greater), keggres$greater) %>%
  tbl_df() %>%
  filter(row_number()<=10) %>%
  .$id %>%
  as.character()
keggrespathways

# Get the IDs.
keggresids <- substr(keggrespathways, start=1, stop=8)
keggresids

# Define plotting function for applying later
plot_pathway = function(pid) pathview(gene.data=gage.data$log2FoldChange, pathway.id=pid, 
                                      species="hsa", new.signature=FALSE)

#plot multiple pathways (plots saved to disk and returns a throwaway list object)
tmp = sapply(keggresids, function(pid) pathview(gene.data=gage.data$log2FoldChange, 
                                         pathway.id=pid, species="hsa"))

