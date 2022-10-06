process CODONPHYML {

    container "codonphyml:1.0"

    input:
    path alignment

    output:
    path "*", emit: out

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: alignment.baseName
    """
    codonphyml \\
        -i $alignment \\
        -o $prefix \\
        $args
    """

}
