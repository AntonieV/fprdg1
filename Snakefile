configfile: "config.yaml"
import pandas as pd

#kallisto: kerne in config file?

samples = pd.read_csv(config["samples"], sep = "\t")


rule all:
    input:
        "plots/heatmap.svg",
        "plots/volcano.svg"


rule kallisto_idx:
    input:
        config["transcripts"]
    conda:
        "envs/kallisto.yaml"
    output:
        config["kallisto_idx"]
    shell:
        "kallisto index -i {output} {input}"

rule kallisto_quant:
    input:
        id = config["kallisto_idx"],
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
        "sleuth/significant_transcripts.csv",
        "sleuth/p-values_all_transcripts.csv",
        "sleuth/sleuth_matrix.csv",
        "sleuth/sleuth_object"
    script:
        "r_scripts/sleuth_script.R"

rule volcano:
    input:
        pval = "sleuth/p-values_all_transcripts.csv",
        matrix = "sleuth/sleuth_matrix.csv",
        samples = config["samples"]
    conda:
        "envs/volcano.yaml"
    output:
        "plots/volcano.svg"
    script:
        "r_scripts/volcano.R"

rule heatmap:
    input:
        "plots/volcano.svg",
        matrix = "sleuth/sleuth_matrix.csv",
        dist = config["clust_dist"],
        p_all = "sleuth/p-values_all_transcripts.csv"
    conda:
        "envs/heatmap.yaml"
    output:
        "plots/heatmap.svg"
    script:
        "r_scripts/complexHeatmap.R"

rule pizzly_prep:
    input:
        id = config["kallisto_idx"],
        fq1 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq1'],
        fq2 = lambda wildcards: samples.loc[samples['sample'] == wildcards.sample]['fq2']
    conda:
        "envs/kallisto.yaml"
    params:
        "pizzly/{sample}/prep"
    output:
        "pizzly/{sample}/prep/fusion.txt",
        "pizzly/{sample}/prep/abundance.h5"
    shell:
        "kallisto quant -i {input.id} --fusion -o {params} {input.fq1} {input.fq2}"

rule pizzly:
    input:
        transcript = config["transcripts"],
        gtf = config["transcripts_gtf"],
        fusions = "pizzly/{sample}/prep/fusion.txt"
    conda:
        "envs/pizzly.yaml"
    params:
        "pizzly/{sample}/prep",
        "pizzly/{sample}/result"
    output:
        "pizzly/{sample}/result.json"
    shell:
        "pizzly -k 31 --gtf {input.gtf} --cache {params[0]}/indx.cache.txt --align-score 2 --insert-size 400 --fasta {input.transcript} --output {params[1]} {input.fusions}"

rule pizzly_flatten:
    input:
        "pizzly/{sample}/result.json"# ueber alle; expand("pizzly/{sample}/result.json", sample = samples['sample'])
    output:
        "plots/pizzly_genetable_{sample}.csv" #TODO eine datei pro sample aber svg
    shell:
        "python py_scripts/flatten_json.py {input} {output}"

rule pizzly_fragment_length:
    input:
        "pizzly/{sample}/prep/abundance.h5"
    conda:
        "envs/pizzly_fragment_length.yaml"
    output:
        "plots/pizzly_fragment_length_{sample}.csv" #TODO als svg
    shell:
        "python py_scripts/get_fragment_length.py {input} 0.95 {output} " #evtl andees percentil angeben

rule pizzly_all:
    input:
        expand("plots/pizzly_genetable_{sample}.csv", sample = samples['sample']),
        expand("plots/pizzly_fragment_length_{sample}.csv", sample = samples['sample'])
    
rule gage:
    input:

    conda:
        "envs/gage.yaml"
    output:

    script:
        "r_scripts/gage.R"

rule svg_pdf:
    input:
        directory("plots")
    conda:
        "envs/svg_pdf.yaml"
    output:
        "rna-seq_plots.pdf"
    script:
        "r_scripts/svg_to_pdf.R"

rule boxen_plot:
    input:
        "sleuth/sleuth_matrix.csv"
    conda:
        "envs/boxen.yaml"
    output:
        "plots/boxen.svg"
    script:
        "py_scripts/boxen_plot.py"

rule p_value_hist:
    input:
        "sleuth/p-values_all_transcripts.csv"  #sleuth-tabelle mit 'pval'-Spalte
    conda:
        "envs/boxen.yaml"
    output:
        "plots/p-value.svg"
    script:
        "py_scripts/p-value_histogramm.py"

rule strip_plot:
    input:
        "sleuth/significant_transcripts.csv"  #sleuth-matrix, mit den Spalten target_id, which_units???
    conda:
        "envs/boxen.yaml"
    output:
        "plots/strip.svg"
    script:
        "py_scripts/strip_plot.py"
