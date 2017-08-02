# purchase-analysis
Analyzing consumer purchasing preference changes from implementing new public policies.

1.) Run the `preprocess.R` script to generate the `data/brands/` and `data/units/` files as well as the `include.txt` file from the Nielsen data. The `include.txt` file is important for subsequent steps as it is a list of file paths to raw Nielsen movement data files. Alternatively you can use our output from this step.

```
Rscript preprocess.R
```

2.) Run the `reduce.R` script through an HPC scheduler (e.g., SGE). This will process each Nielsen movement data file in `include.txt` in parallel by merging with store and product files to calculate the total volume in ounces (OZ) and total dollar amount sold each week from 2006 to 2015.

```
for i in `cat include.txt`; do echo $i; qsub sge-scatter.sh $i; done
```

3.) TBD
