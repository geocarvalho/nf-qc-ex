process PICARD {
    tag "${sample_name}"
    label "picard"
    container 'quay.io/biocontainers/picard:3.2.0--hdfd78af_0'

    input:
        val sample_name
        path cram
        path crai
        path fasta
        path fai
        
    output:
        tuple val(sample_name), path("*_metrics"), emit: metrics
        path  "versions.yml"              , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def avail_mem = 60
        if (!task.memory) {
            log.info '[Picard CollectWgsMetrics] Available memory not known - defaulting to 60GB. Specify process memory requirements to change this.'
        } else {
            avail_mem = (task.memory.mega*0.8).intValue()
        }
        """
        picard \\
            -Xmx${avail_mem}g \\
            CollectWgsMetrics \\
            --INPUT $cram \\
            --OUTPUT ${sample_name}.CollectWgsMetrics.coverage_metrics \\
            --REFERENCE_SEQUENCE ${fasta}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            picard: \$(picard CollectWgsMetrics --version 2>&1 | grep -o 'Version.*' | cut -f2- -d:)
        END_VERSIONS
        """
}
