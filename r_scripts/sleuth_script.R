library(biomaRt)
#Sleuth starten:

suppressMessages({
  library("sleuth")
})

path <- getwd() # aktuelles Verzeichnis speichern

#Vorbereitungen:

#Listen mit den Pfaden zu den einzelnen Kallisto-Dateien anlegen: 

kal_dirs <- file.path(gsub(" ","", paste(path, "/", snakemake@input[["kal_path"]])))  # Liste der Pfadnamen der einzelnen Kallisto-results


s2c <- read.table(file = snakemake@input[["sam_tab"]] , sep = "\t", 
                  header = TRUE, stringsAsFactors = FALSE)

s2c <- dplyr::select(s2c, sample, condition)

#Die Pfade der Kallisto-Dateien muessen nun als neue Spalte an die Hilfstabelle angefuegt werden:
s2c <- dplyr::mutate(s2c, path = kal_dirs)

#Zuordnung der Transkripte zu Genen
mart <- biomaRt::useMart(biomart = "ENSEMBL_MART_ENSEMBL",
                         dataset = "hsapiens_gene_ensembl",
                         host = 'ensembl.org')
t2g <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "ensembl_gene_id",
                                     "external_gene_name"), mart = mart)
t2g <- dplyr::rename(t2g, target_id = ensembl_transcript_id,
                     ens_gene = ensembl_gene_id, ext_gene = external_gene_name)

so <- sleuth_prep(s2c, full_model = ~condition, target_mapping = t2g) #extra_bootstrap_summary = FALSE) #, read_bootstrap_tpm=TRUE, full_model = ~condition)

#estimate parameters for the sleuth response error measurement (full) model
#Das Sleuth-Objekt an das Full-Model anpassen:
so <- sleuth_fit(so, ~condition, 'full')

#estimate parameters for the sleuth reduced model
#Das Sleuth-Objekt an das reduzierte Model anpassen:
so <- sleuth_fit(so, ~1, 'reduced')

#perform differential analysis (testing) using the likelihood ratio test
#Analyse starten:
so <- sleuth_lrt(so, 'reduced', 'full')

#Betrachten des Full-Models und des reduzierten Modells:
models(so)

#Betrachen der signifikanten Ergebnisse aus dem Likelihood-Ratio-Test:
sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = TRUE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)

#### TODO - Gennamen zu den IDs hinzugfuegen

sleuth_save(so, "sleuth/sleuth_object")

sleuth_matrix = sleuth_to_matrix(so, 'obs_norm', 'est_counts')

write.table(sleuth_matrix, file = "sleuth/sleuth_matrix.csv", sep = "\t")
write.table(sleuth_table, file = "sleuth/p-values_all_transcripts.csv", sep = "\t")
write.table(sleuth_significant, file = "sleuth/significant_transcripts.csv", sep = "\t")