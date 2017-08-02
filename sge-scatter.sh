#!/bin/bash
#$ -S /bin/bash
#$ -cwd

module load r
Rscript ~/src/purchase-analysis/reduce.R $1
