import pandas as pd

in_data = {'sample': ["a", "b"], 'fq1': ["data/reads/a.chr21.1.fq", "data/reads/b.chr21.1.fq"],
           'fq2': ["data/reads/a.chr21.2.fq", "data/reads/b.chr21.2.fq"], 'condition': ["treated", "untreated"]}

table_path_of_reads = pd.DataFrame(data=in_data, columns=['sample', 'fq1', 'fq2', 'condition'])

table_path_of_reads.to_csv(path_or_buf="../table_for_reads.csv", sep='\t', header=True)

# print(table_path_of_reads)