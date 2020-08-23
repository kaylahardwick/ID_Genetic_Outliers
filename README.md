# ID_Genetic_Outliers
Visualizations to identify genetic outliers in otherwise closely related groups.

This code calculates genetic distance and identity by descent for a set of samples, and generates boxplots to aid in visual identification of genetic outliers in otherwise closely related groups. This analysis may be useful for identifying instances of potential pollen contamination in the field or sample mixups in the lab.

The code can be run as follows:
./DST_IBD_outliers.sh FILE1 FILE2

Input files: 
FILE1: A vcf of genotype calls for all samples (required).

FILE2: A file with sample identifiers and group designations (optional). 

The group designations file should be formatted like such:
Sample1	Group1
Sample2	Group1
Sample3	Group1
Sample4	Group2
Sample5	Group2

Sample identifiers in the group designations file must match those in the vcf. If no group designations file is provided, all samples will be treated as members of a single group.

Note: please don't include underscores in sample identifiers (plink doesn't handle these characters well). In addition, please do not include duplicate sample identifiers.

Dependencies for running this code include plink (https://zzz.bwh.harvard.edu/plink/), R, and the R libraries ggplot2, dplyr, and gridExtra.

See DST_IBD_Group1_1.png for an example plot.
