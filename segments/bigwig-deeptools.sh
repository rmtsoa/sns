#!/bin/bash


# deepTools generate BigWig from BAM


# script filename
script_name=$(basename "${BASH_SOURCE[0]}")
segment_name=${script_name/%.sh/}
echo -e "\n ========== SEGMENT: $segment_name ========== \n" >&2

# check for correct number of arguments
if [ ! $# == 4 ] ; then
	echo -e "\n $script_name ERROR: WRONG NUMBER OF ARGUMENTS SUPPLIED \n" >&2
	echo -e "\n USAGE: $script_name project_dir sample_name num_threads BAM \n" >&2
	exit 1
fi

# arguments
proj_dir=$1
sample=$2
threads=$3
bam=$4


#########################


# check that inputs exist

if [ ! -d "$proj_dir" ] ; then
	echo -e "\n $script_name ERROR: DIR $proj_dir DOES NOT EXIST \n" >&2
	exit 1
fi

if [ ! -s "$bam" ] ; then
	echo -e "\n $script_name ERROR: BAM $bam DOES NOT EXIST \n" >&2
	exit 1
fi


#########################


# settings and files

bigwig_dir="${proj_dir}/BIGWIG"
mkdir -p "$bigwig_dir"
bigwig="${bigwig_dir}/${sample}.bin1.rpkm.bw"

# BIGWIG_RPKM_BIN1=${BIGWIG_RPKM_DIR}/${ID}.bin1.rpkm.bw
# BIGWIG_RPKM_BIN10=${BIGWIG_RPKM_DIR}/${ID}.bin10.smooth50.rpkm.bw


#########################


# exit if output exits already

if [ -s "$bigwig" ] ; then
	echo -e "\n $script_name SKIP SAMPLE $sample \n" >&2
	exit 1
fi


#########################


# generate bigwig using deeptools

module unload python
module load python/2.7.3
module load deeptools/2.2.4
module load kentutils/329

echo " * bamCoverage: $(readlink -f $(which bamCoverage)) "
echo " * BAM: $bam "
echo " * BIGWIG: $bigwig "

bash_cmd="
bamCoverage \
--verbose \
--numberOfProcessors $threads \
--binSize 1 \
--normalizeUsingRPKM \
--outFileFormat bigwig \
--bam $bam \
--outFileName $bigwig
"
echo "CMD: $bash_cmd"
eval "$bash_cmd"

# echo " * BIGWIG: $BIGWIG_RPKM_BIN10 "

# CMD="
# bamCoverage \
# --verbose \
# --numberOfProcessors $THREADS \
# --binSize 10 \
# --fragmentLength 1 \
# --smoothLength 50 \
# --normalizeUsingRPKM \
# --outFileFormat bigwig \
# --bam $BAM \
# --outFileName $BIGWIG_RPKM_BIN10
# "
# echo "CMD: $CMD"
# eval "$CMD"


#########################


# check that output generated

if [ ! -s "$bigwig" ] ; then
	echo -e "\n $script_name ERROR: BIGWIG $bigwig NOT GENERATED \n" >&2
	exit 1
fi


#########################



# end
