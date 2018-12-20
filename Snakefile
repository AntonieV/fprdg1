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
		fq1 = samples["fq1"][{sample}],
		fq2 = samples["fq2"][{sample}]
	output:
		"kallisto/" + samples["sample"][{sample}]
	shell:
		"kallisto quant -i {input.id} -o {output} {input.fq1} {input.fq2}"

		