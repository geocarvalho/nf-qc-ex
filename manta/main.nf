process MANTA_SINGLE {
    tag "${sample_name}"
    label "manta"
    container 'quay.io/biocontainers/manta:1.6.0--h9ee0642_3'

    input:
        val sample_name
        path cram
        path crai
        path fasta
        path fai
        
    output:
        tuple val(sample_name), path("*_metrics"),  emit: metrics
        path  "versions.yml",                       emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        configManta.py --bam ${cram} --referenceFasta ${fasta} --runDir manta
        python manta/runWorkflow.py -m local -j $task.cpus

        mv manta/results/variants/candidateSmallIndels.vcf.gz ${sample_name}.candidate_small_indels.vcf.gz
        mv manta/results/variants/candidateSmallIndels.vcf.gz.tbi ${sample_name}.candidate_small_indels.vcf.gz.tbi
        mv manta/results/variants/candidateSV.vcf.gz ${sample_name}.candidate_sv.vcf.gz
        mv manta/results/variants/candidateSV.vcf.gz.tbi ${sample_name}.candidate_sv.vcf.gz.tbi
        mv manta/results/variants/diploidSV.vcf.gz ${sample_name}.diploid_sv.vcf.gz
        mv manta/results/variants/diploidSV.vcf.gz.tbi ${sample_name}.diploid_sv.vcf.gz.tbi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            manta: \$( configManta.py --version )
        END_VERSIONS
        """
}
