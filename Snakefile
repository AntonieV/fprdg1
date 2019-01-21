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
	conda:
		"envs/kallisto.yaml"
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

rule volcano:
    input:
        pval = "p-values_all_transcripts.csv"
        matrix = "sleuth/sleuth_matrix.csv"
        samples = config["samples"]
    conda:
        "envs/volcano"
    output:
        "plots/volcano.svg"
    script:
        "r_scripts/volcano.R"

rule heatmap:
    input:
        matrix = "sleuth/sleuth_matrix.csv"
        dist = open(config["clust_dist"], "r").read()
    conda:
        "envs/heatmap.yaml"
    output:
        "plots/heatmap.svg"
    script:
        "r_scripts/complexHeatmap.R"

rule pizzly_prep:
    input:
        id = "kallisto/transcripts.idx",
        fq1 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq1'],
        fq2 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq2']
    output:
        ordner = directory("pizzly/{sample}"),
        file1 = "pizzly/{sample}/fusion.txt",
        file2 = "pizzly/{sample}/index.cache.txt"
    shell:
        "kallisto quant -i {input.id} --fusion -o {output.ordner} {input.fq1} {input.fq2}"       

rule pizzly:
    input:
        transcript = config["transcripts"],
        uno = config["transcripts_gtf"],
        file1 = "pizzly/{sample}/fusion.txt",
        file2 = "pizzly/{sample}/index.cache.txt"
    conda:
        "envs/pizzly.yaml"
    output:
        eins = "{sample}.fusions.fasta",
        zwei = "{sample}.json",
        drei = "{sample}"
    shell:
        "pizzly -k 31 --gtf {input.uno} --cache {input.file2} --align-score 2 --insert-size 400 --fasta {input.transcript} --output {output.drei} {input.file1}"

rule pizzly_flatten:
    input:
        "test.json"
    output:
        "genetable.txt"
    shell:
        "py:scripts/flatten_json.py {input} [{output}]"

rule gage:
    input:
        
    conda:
        "envs/gage.yaml"
    output:
        
    script:
        "r_scripts/gage.R"
