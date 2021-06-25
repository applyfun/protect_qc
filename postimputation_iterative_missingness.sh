module load apps/plink/1.9.0b6.10

aspercent=$(echo $1 " / 100" | bc -l)
genomind_1=$(echo "1-"$aspercent | bc -l)

plink \
--bfile postimputation_merged_snps_only \
--geno $genomind_1 \
--make-bed \
--out postimputation_merged_snps_only_SNP$1

#Remove samples with completeness < 90%

plink \
--bfile postimputation_merged_snps_only_SNP$1 \
--mind $genomind_1 \
--make-bed \
--out postimputation_merged_snps_only_sample$1.SNP$1

newstep=$(($1+$3))

for i in $(seq $newstep $3 $2)

do

aspercent=$(echo $i " / 100" | bc -l)
genomind=$(echo "1-"$aspercent | bc -l)
prefix=$(($i-$3))

plink \
--bfile postimputation_merged_snps_only_sample$prefix.SNP$prefix \
--geno $genomind \
--make-bed \
--out postimputation_merged_snps_only_sample$prefix.SNP$i

plink \
--bfile postimputation_merged_snps_only_sample$prefix.SNP$i \
--mind $genomind \
--make-bed \
--out postimputation_merged_snps_only_sample$i.SNP$i

done

plink \
--bfile postimputation_merged_snps_only_sample$2.SNP$2 \
--make-bed \
--out postimputation_merged_snps_only_filtered 
