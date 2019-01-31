# Snakemake workflow: transcript expression analysis

[![Snakemake](https://img.shields.io/badge/snakemake-≥4.2-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/AntonieV/fprdg1.svg?branch=master)](https://travis-ci.org/AntonieV/fprdg1)

In this workflow the abundances of transcipts are quantified using kallisto and analysed with sleuth.
The resulting data ist analysed further with the tools seaborn, scikit-learn, ComplexHeatmap and Pizzly to create summarizing plots and tables that can be found in the folder `plots` after execution.

## Authors

* Johannes Köster (@johanneskoester), https://koesterlab.github.io
* Jana Jansen (@jana-ja)
* Ludmila Janzen (@l-janzen)
* Sophie Sattler (@sophsatt)
* Antonie Vietor (@AntonieV)

## Usage

### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/AntonieV/fprdg1).
If you intend to modify and further develop this workflow, fork this reposity. Please consider providing any generally applicable modifications via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.
Further instructions can be found in the file.

### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake -n

Execute the workflow locally via

    snakemake --cores $Ns --use-conda

using `$N` cores or run it in a cluster environment via

    snakemake --cluster qsub --jobs 100 --use-conda

or

    snakemake --drmaa --jobs 100 --use-conda

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.
