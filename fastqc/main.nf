process FASTQC {
    tag "${sample_name}"
    label "fastqc"
    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    input:
        val sample_name
        path fastq1_path
        path fastq2_path

    output:
        tuple val(sample_name), path("*_fastqc.html"),   emit: html
        tuple val(sample_name), path("*_fastqc.zip"),    emit: zip
        path "versions.yml",                                            emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    mkdir fastqc_results/
    fastqc \\
        -o . \\
        --threads $task.cpus \\
        ${fastq1_path} ${fastq2_path}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed '/FastQC v/!d; s/.*v//' )
    END_VERSIONS
    """
}
