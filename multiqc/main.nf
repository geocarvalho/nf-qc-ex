process MULTIQC {
    tag "${sample_name}"
    label "multiqc"
    container 'quay.io/biocontainers/multiqc:1.24--pyhdfd78af_0'

    input:
        tuple val(sample_name), path(fastp_json)
        tuple val(sample_name), path(fastp_html)
        tuple val(sample_name), path(fastqc_html)
        tuple val(sample_name), path(fastqc_zip)

    output:
        path "*_multiqc.html", emit: report
        path "*_data"              , emit: data
        path "*_plots"             , optional:true, emit: plots
        path "versions.yml"        , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        multiqc . -n ${sample_name}_multiqc

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
        END_VERSIONS
        """
}
