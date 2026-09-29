# Task 5 Nextflow workflow

Requires Nextflow, minimap2, samtools, R, and the bambu R package.
Run from the assignment1 directory with the FASTQ, reference FASTA,
and GTF paths specified in main.nf.

Scenario 1, with annotations:
./nextflow run main.nf --scenario annotated \
  -with-report task5_output/annotated_report.html

Scenario 2, without annotations and reusing completed tasks:
./nextflow run main.nf --scenario de_novo -resume \
  -with-report task5_output/de_novo_report.html \
  -with-trace task5_output/de_novo_trace.txt

main.nf defines the ALIGN, QC, and BAMBU processes.
task5_qc.sh calculates primary-read counts and mapping percentages.
task5_bambu.R runs Bambu and writes the RDS, extended GTF, and count files.

The successful first annotated run completed, but its HTML report could
not be rendered because the report filename already existed.
Its runtime is recorded in the Nextflow execution history and log.
