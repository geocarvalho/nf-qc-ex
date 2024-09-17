process CNVNATOR {
    tag "$sample_id"
    label 'cnvnator'
    container "quay.io/biocontainers/cnvnator:0.4.1--py311hcd771ed_9"

    input:
    val sample_id
    path cram
    path crai
    path fasta
    path fai

    output:
    tuple val(output_meta), path("${prefix}.root"), emit: root
    tuple val(output_meta), path("${prefix}.tab") , emit: tab, optional: true
    path "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    cnvnator -root ${sample_id}.root -tree ${cram}
    cnvnator -root ${sample_id}.root -his 1000 -fasta ${fasta}
    cnvnator -root ${sample_id}.root -stat 1000
    cnvnator -root ${sample_id}.root -partition 1000 -ngc
    cnvnator -root ${sample_id}.root -call 1000 -ngc > ${sample_id}.tab

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        CNVnator: \$(echo \$(cnvnator 2>&1 | sed -n '3p' | sed 's/CNVnator v//'))
    END_VERSIONS
    """
}
