configfile: "config.yaml"
import pandas as pd


samples = pd.read_csv(config["samples"], sep = "\t")


rule kallisto_idx:
	input:
		config["transcripts"]
	conda:
		"envs/kallisto.yaml"
	output:
		"kallisto/transcripts.idx"
	shell:
		"kallisto index -i {output} {input}"

rule kallisto_quant:
	input:
		id = "kallisto/transcripts.idx",
		fq1 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq1'],
		fq2 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq2']
	output:
		directory("kallisto/{sample}")
	shell:
		"kallisto quant -i {input.id} -o {output} {input.fq1} {input.fq2}"

rule sleuth:
        input:
	        expand("kallisto/{sample}.h5", sample = samples) #Liste der Kallisto-Pfade
        conda:
	        "envs/sleuth.yaml"  #### hier noch die unnoetigen Tools entfernen
        output:
	        "/sleuth/significant_transcripts.csv"
        script:
	        "r_scripts/sleuth_script.R"

