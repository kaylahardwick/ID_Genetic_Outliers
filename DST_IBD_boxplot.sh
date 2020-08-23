#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

FILE1=${1:-NULL}
FILE2=${2:-NULL}

if [ "$FILE1" == NULL ]
then
die "no genotype data provided"
elif [ -f "$FILE1" ]
then
echo -e "genotype calls in $FILE1"
else
die "$FILE1 does not exist"
fi

if [ "$FILE2" == NULL ]
then
echo -e "no group designations provided"
grep "#CHROM" $FILE1 | cut -f10- | perl -pe 's/\t/\n/g' | awk '{print $1"\tGroup1"}' > IDs.txt
FILE2=IDs.txt
elif [ -f "$FILE2" ]
then
echo -e "group designations in $FILE2"
else
die "$FILE2 does not exist"
fi

#check number of samples in groups file match number of samples in vcf
samplenumgroup=$(awk '{print $1}' $FILE2 | sed '/^$/d' | sort | uniq | wc -l)
samplenumvcf=$(grep "#CHROM" $FILE1 | cut -f10- | perl -pe 's/\t/\n/g' | awk '{print $1}' | sort | uniq | wc -l)
[ "$samplenumgroup" -eq "$samplenumvcf" ] || die "different numbers of samples in vcf and group designations file"
#check if there are duplicate sample IDs in either file
sampleuniqgroup=$(awk '{print $1}' $FILE2 | sed '/^$/d' | sort | uniq -c | awk '$1>1 {print}' | wc -l)
sampleuniqvcf=$(grep "#CHROM" $FILE1 | cut -f10- | perl -pe 's/\t/\n/g' | awk '{print $1}' | sort | uniq -c | awk '$1>1 {print}' | wc -l)
[ "$sampleuniqgroup" -eq 0 ] || die "duplicate sample IDs in group designations file"
[ "$sampleuniqvcf" -eq 0 ] || die "duplicate sample IDs in vcf"

GROUP=$(cat $FILE2 | awk '{print $2}' | sed '/^$/d' | sort | uniq)

for g in $GROUP
do
echo $g
#generate .genome file
awk -v var1="$g" '$2==var1 {print $1"\t"$1}' $FILE2 > keep_${g}.txt
plink --genome --vcf $FILE1 --keep keep_${g}.txt --out ${g} --allow-extra-chr
#gather per-sample statistics
while read p
do 
echo $p
awk -v var2="$p" '$1==var2 || $3==var2 {print var2"\t"$10"\t"$12}' ${g}.genome >> persample_IBD_DST_${g}.txt
done < <(cut -f1 keep_${g}.txt)
#make plots
DST_IBD_boxplot.R $g
#remove extraneous files
rm persample_IBD_DST_${g}.txt
rm keep_${g}.txt
rm ${g}.genome
rm ${g}.nosex
rm ${g}.log
done
