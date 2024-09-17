nextflow.enable.dsl = 2

params.sample_name = 'NA12878'
// params.fastq1_path = "/var/snap/amazon-ssm-agent/7993/test/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq.gz"
// params.fastq2_path = "/var/snap/amazon-ssm-agent/7993/test/H06HDADXX130110.1.ATCACGAT.20k_reads_2.fastq.gz"
params.cram = "/var/snap/amazon-ssm-agent/7993/test/NA12878.cram"
params.crai = "/var/snap/amazon-ssm-agent/7993/test/NA12878.cram.crai"
params.fasta = "/var/snap/amazon-ssm-agent/7993/download/broad/Homo_sapiens_assembly38.fasta"
params.fai = "/var/snap/amazon-ssm-agent/7993/download/broad/Homo_sapiens_assembly38.fasta.fai"

log.info """\
    EX _ W F   P I P E L I N E
    ===================================
    sample_name     : ${params.sample_name}
    cram            : ${params.cram}
    crai            : ${params.crai}
    fasta           : ${params.fasta}
    fai             : ${params.fai}
    """
    .stripIndent(true)

// include { FASTQC } from './fastqc/main.nf'
// include { FASTP } from './fastp/main.nf'
// include { MULTIQC } from './multiqc/main.nf'
include { PICARD } from './picard/main.nf'
include { MANTA_SINGLE } from './manta/main.nf'
include { CNVNATOR } from './cnvnator/main.nf'

workflow {
    // FASTQC(params.sample_name, params.fastq1_path, params.fastq2_path)
    // FASTP(params.sample_name, params.fastq1_path, params.fastq2_path)
    // MULTIQC(FASTP.out.json, FASTP.out.html, FASTQC.out.html, FASTQC.out.zip)
    PICARD(params.sample_name, params.cram, params.crai, params.fasta, params.fai)
    MANTA_SINGLE(params.sample_name, params.cram, params.crai, params.fasta, params.fai)
    CNVNATOR(params.sample_name, params.cram, params.crai, params.fasta, params.fai)
}
