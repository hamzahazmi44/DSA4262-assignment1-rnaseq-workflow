nextflow.enable.dsl = 2

params.scenario = 'annotated'
params.reads = 'fastq/*.fastq.gz'
params.genome = 'reference/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa'
params.gtf = 'annotation/Homo_sapiens.GRCh38.91.gtf'


process ALIGN {
    cpus 2
    maxForks 1
    publishDir 'task5_output/bam', mode: 'copy'

    input:
    tuple val(sample), path(fastq)
    path genome

    output:
    tuple val(sample), path("${sample}.bam"), path("${sample}.bam.bai")

    script:
    def rnaOptions = sample.contains('_directRNA_') ? '-uf -k14' : ''
    """
    set -euo pipefail
    minimap2 -t 1 -ax splice ${rnaOptions} ${genome} ${fastq} |
        samtools sort -@ 1 -m 256M -o ${sample}.bam -
    samtools index ${sample}.bam
    """
}

process QC {
    publishDir 'task5_output/qc', mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)
    path qcScript

    output:
    path "${sample}.flagstat.txt"
    path "${sample}.qc.tsv"

    script:
    """
    bash ${qcScript} ${sample} ${bam}
    """
}

process BAMBU {
    cpus 1
    maxForks 1
    publishDir "task5_output/${params.scenario}", mode: 'copy'

    input:
    path bams
    path indexes
    path genome
    path genomeIndex
    path gtf
    val scenario
    path bambuScript

    output:
    path 'se.rds'
    path 'bambu_output'

    script:
    """
    Rscript ${bambuScript} ${scenario} ${genome} ${gtf}
    """
}

workflow {
    if (!(params.scenario in ["annotated", "de_novo"])) error "Use --scenario annotated or --scenario de_novo"
    reads = Channel.fromPath(params.reads, checkIfExists: true)
        .map { fastq ->
            tuple(fastq.name.replaceFirst(/\.fastq\.gz$/, ''), fastq)
        }

    genome = Channel.value(file(params.genome, checkIfExists: true))
    genomeIndex = Channel.value(file("${params.genome}.fai", checkIfExists: true))
    gtf = Channel.value(file(params.gtf, checkIfExists: true))

    aligned = ALIGN(reads, genome)
    QC(aligned, Channel.value(file("${projectDir}/task5_qc.sh")))

    bamFiles = aligned.map { sample, bam, bai -> bam }.collect()
    indexFiles = aligned.map { sample, bam, bai -> bai }.collect()

    BAMBU(
        bamFiles,
        indexFiles,
        genome,
        genomeIndex,
        gtf,
        params.scenario,
        Channel.value(file("${projectDir}/task5_bambu.R"))
    )
}
