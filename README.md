# nf-qc-ex
Example of QC nextflow code

- Download an example of a sample from [GATK bundle](https://s3.amazonaws.com/gatk-test-data/gatk-test-data-readme.html)
- Running the pipeline
```bash
nextflow main.nf --sample_name H06HDADXX130110 --fastq1_path /var/snap/amazon-ssm-agent/7993/test/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq.gz --fastq2_path /var/snap/amazon-ssm-agent/7993/test/H06HDADXX130110.1.ATCACGAT.20k_reads_2.fastq.gz
```
