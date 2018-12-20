###################### Installation ##########################
###sollte schon ueber das env installiert werden####
#install.packages("Rtools 3.5")
#source("http://bioconductor.org/biocLite.R") #insall rhdf5
#biocLite("rhdf5")

#install.packages("devtools")  #package devtools

#devtools::install_github("pachterlab/sleuth")  #install sleuth

##############################################################

#Sleuth starten:

suppressMessages({
  library("sleuth")
})

#Vorbereitungen:

#Verzeichnis-Pfad speichern, in dem die Kallisto-results liegen:
#sample_id <- dir(file.path("...", "results"))  #hier Pfad zu den Kallisto-results angeben

#Betrachten der in diesem Verzeichnis vorhandenen Kallisto-Dateien:
#sample_id

#Listen mit den Pfaden zu den einzelnen Kallisto-Dateien anlegen: 
#kal_dirs <- file.path("...", "results", sample_id, "kallisto")  #hier Pfad zu den Kallisto-results angeben
kal_dirs <- snakemake@input[["kal_path"]]  # Liste der Pfadnamen der einzelnen Kallisto-results

#Betrachten der Pfad-Liste zu den Kallisto-Dateien:
#kal_dirs

#Hilfstabelle anlegen mit Angaben zum experimentellen Design der einzelnen Proben
#aus dem Kallisto-Verzeichnis:
#s2c <- read.table(file.path("...", "metadata", "hiseq_info.txt"), #hier Pfad zu den Kallisto-results angeben
#                  header = TRUE, stringsAsFactors=FALSE) 
s2c <- read.table(snakemake@input[["sam_tab"]])
s2c <- dplyr::select(s2c, sample = run_accession, condition)
#s2c

#Die Pfade der Kallisto-Dateien muessen nun als neue Spalte an die Hilfstabelle angefuegt werden:
s2c <- dplyr::mutate(s2c, path = kal_dirs)

#Betrachten der Hilfstabelle, auf Korrektheit ueberpruefen:
#print(s2c)

#Kallisto-Daten in Sleuth laden, anlegen eines Sleuth-Objekts:

#load the kallisto processed data into the object
#Initialisierung des Sleuth-Objekts:
so <- sleuth_prep(s2c, extra_bootstrap_summary = TRUE)

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
#models(so)

#Betrachen der signifikanten Ergebnisse aus dem Likelihood-Ratio-Test:
sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)
#head(sleuth_significant, 20)

#### TODO - Gennamen zu den IDs hinzugfuegen

#### TODO - Outputdatei anlegen, ggf. Hilfsdatei zur Ueberpruefung der Zwischenvariablen
#### auf Korrektheit anlegen

snakemake@output <- sleuth_table

