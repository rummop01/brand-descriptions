#!/bin/bash
#$ -S /bin/bash
#$ -l mem_free=30G
#$ -l mem_token=30G
#$ -cwd

module load r
Rscript ~/src/purchase-analysis/reduce.R $1
