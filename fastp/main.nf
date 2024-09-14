process FASTP {
    tag "${sample_name}"
    label "fastp"
    container 'quay.io/biocontainers/fastp:0.23.4--hadf994f_1'

    input:
        val sample_name
        path fastq1_path
        path fastq2_path

    output:
        tuple val(sample_name), path('*.fastp.fastq.gz'),  emit: reads
        tuple val(sample_name), path('*.json'),            emit: json
        tuple val(sample_name), path('*.html'),            emit: html
        tuple val(sample_name), path('*.log'),             emit: log
        path "*versions.yml",                              emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        fastp -w $task.cpus -i ${fastq1_path} -I ${fastq2_path} -o ${sample_name}_R1.fastp.fastq.gz -O ${sample_name}_R2.fastp.fastq.gz -j ${sample_name}.fastp.json -h ${sample_name}.fastp.html --detect_adapter_for_pe 2> >(tee ${sample_name}.fastp.log >&2)

        cat <<-END_VERSIONS > fastp_versions.yml
        "${task.process}":
            fastp: \$(echo \$(fastp --version 2>&1) | awk '{print \$2}' )
        END_VERSIONS
        """
}
