configfile: "config.yaml"
import pandas as pd


samples = pd.read_csv(config["samples"], sep = "\t")

rule all:
	input:
		"sleuth/significant_transcripts.csv"

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
		"kallisto quant --bootstrap-samples=2 -i {input.id} -o  {output} {input.fq1} {input.fq2}"

rule sleuth:
	input:
		kal_path = expand("kallisto/{sample}", sample = samples['sample']), #Liste der Kallisto-Pfade
		sam_tab = config["samples"]
	conda:
		"envs/sleuth.yaml"  #### hier noch die unnoetigen Tools entfernen
	output:
		"sleuth/significant_transcripts.csv"
	script:
		"r_scripts/sleuth_script.R"

rule pizzly_prep:
	input:
		id = "kallisto/transcripts.idx",
		fq1 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq1'],
		fq2 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq2']
	output:
		directory("pizzly/{sample}")
	shell:
		"kallisto quant -i {input.id} --fusion -o {output} {input.fq1} {input.fq2}"       

rule pizzly:
	input:
		transcript = config["transcripts"],
		uno = config["transcripts_gtf"],
		dos = "pizzly/{sample}"
	conda:
		"envs/pizzly.yaml"
	output:
		eins = "{sample}.fusions.fasta",
		zwei = "{sample}.json"
	shell:
		"pizzly -k 31 --gtf {input.uno} --cache {input.dos}/index.cache.txt --align-score 2 --insert-size 400 --fasta {input.transcript} --output test {input.dos}/fusion.txt"

rule pizzly_flatten:
    input:
        "test.json"
    output:
        "genetable.txt"
    shell:
        "py:scripts/flatten_json.py {input} [{output}]"
