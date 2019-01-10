###############################################################
###################### Installation  ##########################
        ### wird durch env/sleuth.yaml uebernommen ####

#install.packages("Rtools 3.5")
#source("http://bioconductor.org/biocLite.R") #install rhdf5
#biocLite("rhdf5")

#install.packages("devtools")  #package devtools

#devtools::install_github("pachterlab/sleuth")  #install sleuth

##############################################################

#Sleuth starten:

suppressMessages({
  library("sleuth")
})

path <- getwd() # aktuelles Verzeichnis speichern

#Vorbereitungen:

#Listen mit den Pfaden zu den einzelnen Kallisto-Dateien anlegen: 

kal_dirs <- file.path(gsub(" ","", paste(path, "/", snakemake@input[["kal_path"]])))  # Liste der Pfadnamen der einzelnen Kallisto-results

#kal_dirs <- file.path(gsub(" ","", paste(path, "/", "kallisto/", c("a","b","c", "d"))))

####################################################################
####### ZUM DEBUGGEN: verschiedene Varianten der Pfadangaben #######

#kal_dirs <- file.path(gsub(" ","", paste(path, "/", snakemake@input[["kal_path"]],"/"))) 
#--#kal_dirs <- file.path(gsub(" ","", paste("../", snakemake@input[["kal_path"]])))
#--#kal_dirs <- file.path(gsub(" ","", paste("../", snakemake@input[["kal_path"]],"/")))
#kal_dirs <- file.path(gsub(" ","", paste("/",path, "/", snakemake@input[["kal_path"]])))
#kal_dirs <- file.path(gsub(" ","", paste("/",path, "/", snakemake@input[["kal_path"]],"/")))
#--#kal_dirs <- file.path(gsub(" ","", paste("/", snakemake@input[["kal_path"]])))
#--#kal_dirs <- file.path(gsub(" ","", paste("/", snakemake@input[["kal_path"]],"/")))
#kal_dirs <- file.path(snakemake@input[["kal_path"]])

####################################################################

###############################################################################
####### ZUM DEBUGGEN: Betrachten der Pfad-Liste zu den Kallisto-Dateien #######

kal_dirs

###############################################################################



#################################################
######## ZUM DEBUGGEN: Test der h5-Datei ########

###test_kallisto <- rhdf5::h5read("/home/tharja/Schreibtisch/Projekt_Ursprungsversion/fprdg1/kallisto/a/abundance.h5","/")
###rhdf5::H5close()
###test_kallisto$est_counts
###test_kallisto$aux$ids
###test_kallisto$aux$length

#################################################


#Hilfstabelle anlegen mit Angaben zum experimentellen Design der einzelnen Proben
#aus dem Kallisto-Verzeichnis:

#s2c <- read.table(file.path("..", "metadata", "hiseq_info.txt"), 
#                  header = TRUE, stringsAsFactors=FALSE) 

#s2c <- read.table(file = "../table_for_reads.csv" , sep = "\t", 
#                  header = TRUE, stringsAsFactors = FALSE)

s2c <- read.table(file = snakemake@input[["sam_tab"]] , sep = "\t", 
                  header = TRUE, stringsAsFactors = FALSE)

s2c <- dplyr::select(s2c, sample, condition)

#Die Pfade der Kallisto-Dateien muessen nun als neue Spalte an die Hilfstabelle angefuegt werden:
s2c <- dplyr::mutate(s2c, path = kal_dirs)


#######################################################################
######## ZUM DEBUGGEN: Ausgabe der Hilfstabelle in der Konsole ########

print(s2c)

#######################################################################


############################################################################################
##################### ZUM DEBUGGEN: Einlesen einer tsv- und h5-Datei #######################

#cat("\n******************************************************************************\n\n")
#a <- gsub(" ", "", paste(s2c$path[1], "/abundance.tsv"))
#b <- gsub(" ", "", paste(s2c$path[1], "/abundance.h5"))
#x <- read_kallisto_tsv(a)
#str(x)
#cat("\n******************************************************************************\n\n")
#y <- read_kallisto_h5(b, read_bootstrap = FALSE)
#str(y)   
#cat("\n******************************************************************************\n\n")

############################################################################################


#Kallisto-Daten in Sleuth laden, anlegen eines Sleuth-Objekts:

#load the kallisto processed data into the object
#Initialisierung des Sleuth-Objekts:


####################################### ZUM DEBUGGEN #################################################
#rhdf5::h5read("/home/tharja/Schreibtisch/Projekt_Ursprungsversion/fprdg1/kallisto/a/abundance.h5","/")
#rhdf5::h5read("/home/tharja/Schreibtisch/Projekt_Ursprungsversion/fprdg1/kallisto/b/abundance.h5","/")
#rhdf5::h5read("/home/tharja/Schreibtisch/Projekt_Ursprungsversion/fprdg1/kallisto/c/abundance.h5","/")
#rhdf5::h5read("/home/tharja/Schreibtisch/Projekt_Ursprungsversion/fprdg1/kallisto/d/abundance.h5","/")
#rhdf5::H5close()

######################################################################################################


so <- sleuth_prep(s2c, full_model = ~condition) #extra_bootstrap_summary = FALSE) #, read_bootstrap_tpm=TRUE, full_model = ~condition)
str(so)
cat("\n******************************************************************************\n\n")

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
sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)
head(sleuth_significant, 20)

#### TODO - Gennamen zu den IDs hinzugfuegen

#### TODO - Outputdatei anlegen, ggf. Hilfsdatei zur Ueberpruefung der Zwischenvariablen
#### auf Korrektheit anlegen

sleuth_save(so, "sleuth/sleuth_object")

write.table(sleuth_table, file = "sleuth/p-values_all_transcripts.csv", sep = "\t")
write.table(sleuth_significant, file = "sleuth/significant_transcripts.csv", sep = "\t")

##################################################################################
######## ZUM DEBUGGEN: Testfiles anlegen ohne Sleuth-Analyse und ausgeben ########
              ##### zum Testen der Sluth-Regel in Snakemake #####

#write.table(s2c, file = "sleuth/p-values_all_transcripts.csv", sep = "\t")
#write.table(s2c, file = "sleuth/significant_transcripts.csv", sep = "\t")

#y <- read.table(file = "sleuth/p-values_all_transcripts.csv", sep = "\t", header = TRUE)
#z <- read.table(file = "sleuth/significant_transcripts.csv", sep = "\t", header = TRUE)
#y
#z

##################################################################################


#snakemake@output <- list(file.path(y))

