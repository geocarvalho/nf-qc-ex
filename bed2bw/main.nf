process BED2BW {
    tag "$meta"
    label 'process_low'
    container "gvcn/bigwig_converter:v0.1"

    input:
        tuple val(meta), path(bed)

    output:
        tuple val(meta), path("*.bw"),      emit: bw
        tuple val(meta), path("*.tsv"),     emit: tsv
        path "versions.yml",                emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def prefix = task.ext.prefix ?: "${meta}"
        """
        Rscript ${projectDir}/script/convert_to_bw.R -i ${bed} -o ${prefix}.ExomeDepth.bw -r ${prefix}_removed_overlapping_intervals.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            \$(echo \$(Rscript ${projectDir}/script/convert_to_bw.R --version 2>&1))
        END_VERSIONS
        """

    stub:
        def prefix = task.ext.prefix ?: "${meta}"
        """
        echo "" > ${prefix}.ExomeDepth.bw
        echo "" > ${prefix}_removed_overlapping_intervals.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            \$(echo \$(Rscript ${projectDir}/script/convert_to_bw.R --version 2>&1))
        END_VERSIONS
        """
}