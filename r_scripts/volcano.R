library(MASS)
library(calibrate)

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
  
}else{
  #Ersetzen der target_id durch Gen-Namen
  rownames(matr) = make.names(p_all$ext_gene, unique = TRUE)
  
  #nur signifikante Gene werden verwendet
  matr <- cbind(matr, p_val = p_all$pval)
  matr <- cbind(matr, q_val = p_all$qval)
  #matr <- subset.matrix(matr, matr$q_val < 0.01)
  
  
  condition_1 <- samples$sample[samples$condition == as.character(factor(samples$condition)[1])]
  condition_2 <- samples$sample[samples$condition == as.character(factor(samples$condition)[2])]
  
  samples.cond_1 <- matr[][as.character(samples$sample[condition_1])]
  samples.cond_2 <- matr[][as.character(samples$sample[condition_2])]
 
  #Definitionsbereich: log2-FoldChange   
  FoldChange <- rowSums(samples.cond_2)/rowSums(samples.cond_1)
  log2FC <- log2(FoldChange)
  plot_x <- log2FC  
  
  #ungueltige Werte anpassen, Intervall des Definitionsbereichs bestimmen
  plot_x[which(is.nan(plot_x))] = Inf
  plot_x[which(is.na(plot_x))] = 0
  min_x <- min(plot_x[is.finite(plot_x)])
  max_x <- max(plot_x[is.finite(plot_x)])
  
  #Wertebereich: -log10 der p-Werte
  p_val <- matr[length(matr)-1]
  plot_y <- unlist(-log10(p_val))
  
  #ungueltige Werte anpassen, Intervall des Definitionsbereichs bestimmen
  plot_y[which(is.nan(plot_y))] = Inf
  plot_y[which(is.na(plot_y))] = 0
  min_y <- min(abs(plot_y[is.finite(plot_y)]))
  max_y <- max(plot_y[is.finite(plot_y)])
  
  #Anlegen des Dataframes fuer den Volcano-Plot mit:
      #Gen/Target-ID, 
      #FoldChange(log2), 
      #p-Werten aus der Sleuth-Analyse und 
      #den durch Post-Hoc-Tests normaliesierten p-Werten (qval, also Korrektur der 
            #Alphafehler-Kumulierung beim multiplen Testen) aus der Sleuth-Analyse
      
  volcano.data <- data.frame(GeneID = rownames(matr), log2FoldChange = plot_x, 
                             pVal = plot_y, PostHoc_pValues = matr$q_val)
  
 
  #svg("../plots/test.svg")
  svg(file=snakemake@output[[1]])
  #Volcano-Plot anlegen
  with(volcano.data, plot(log2FoldChange, pVal, pch = 20, main = "Volcano-Plot", 
                          xlim = c(min_x, max_x),
                          ylim = c(min_y, max_y),
                          xlab = "log2(FoldChange)", ylab = "-log10(p-Values)"))
  
  #Farbgebung: rot := p-Wert(nach Posthoc-Test) < 0.05, orange := log2FoldChange > 1, 
  #            gruen := signifikant(p < 0.05), log2FoldChange > 1
  with(subset(volcano.data, PostHoc_pValues<.05 ), points(log2FoldChange, pVal, pch=20, col="red"))
  with(subset(volcano.data, abs(log2FoldChange)>1), points(log2FoldChange, pVal, pch=20, col="orange"))
  with(subset(volcano.data, PostHoc_pValues<.05 & abs(log2FoldChange)>1), points(log2FoldChange, pVal, pch=20, col="green"))
  
  #Datenpunkte anpassen
  with(subset(volcano.data, PostHoc_pValues<.05 & abs(log2FoldChange)>1), textxy(log2FoldChange, pVal, labs=GeneID, cex=.8))
  dev.off()
}
