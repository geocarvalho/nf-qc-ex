nextflow.enable.dsl = 2
params.sample_name = 'H06HDADXX130110'
params.fastq1_path = "/var/snap/amazon-ssm-agent/7993/test/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq.gz"
params.fastq2_path = "/var/snap/amazon-ssm-agent/7993/test/H06HDADXX130110.1.ATCACGAT.20k_reads_2.fastq.gz"

include { FASTQC } from './fastqc/main.nf'
include { FASTP } from './fastp/main.nf'
include { MULTIQC } from './multiqc/main.nf'

workflow {
    FASTQC(params.sample_name, params.fastq1_path, params.fastq2_path)
    FASTP(params.sample_name, params.fastq1_path, params.fastq2_path)
    MULTIQC(FASTP.out.json, FASTP.out.html, FASTQC.out.html, FASTQC.out.zip)
}
