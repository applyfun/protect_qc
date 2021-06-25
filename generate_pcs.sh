#!/bin/bash -l 
#$ -N generate_pcs
#$ -l h_vmem=20G
#PBS -e ~/run_generate_pcs_error.txt
#PBS -o ~/run_generate_pcs_output.txt

#set directories and config
cd ~/brc_scratch/data/protect_qc/

printf "root=~/brc_scratch/data/protect_qc
file_ioe24=UK_ByronCreese_PN_alias.ioe24
pheno=~/brc_scratch/data/protect/reformated_mdd_pheno_final.raw
outputdir=~/brc_scratch/output/protect_qc
covar=/path/to/covariates.cov
gwas_scriptsdir=~/brc_scratch/scripts/protect_qc/gwas_scripts-master
plink=plink
R=/path/to/R" > Config.conf 

source Config.conf

cd $outputdir

#generate PCs

#loop over studies
listnames=(BPD BBP MAGD WLD DPM LCR UNK DCR BK BR CHN TEC)

#PCs by EIGENSOFT
module load bioinformatics/EIGENSOFT/6.1.4

#EIGENSOFT doesnt like phenotype in fam file coded as -9 so reset to 1
for studyname in "${listnames[@]}" ; do
     
    echo "$studyname "

	awk '{$6 = 1; print}' $outputdir/merged_uk_protect_$studyname.sexcheck1.cleaned.fam > $outputdir/tmpfile.fam && mv $outputdir/tmpfile.fam $outputdir/merged_uk_protect_$studyname.sexcheck1.cleaned.fam
	head $outputdir/merged_uk_protect_$studyname.sexcheck1.cleaned.fam

done

#generate PCs - round 1
for studyname in "${listnames[@]}" ; do
     
    echo "$studyname "

	convertf -p <(printf "genotypename: "$outputdir"/merged_uk_protect_"$studyname".sexcheck1.cleaned.bed
	snpname: "$outputdir"/merged_uk_protect_"$studyname".sexcheck1.cleaned.bim
	indivname: "$outputdir"/merged_uk_protect_"$studyname".sexcheck1.cleaned.fam
	outputformat: EIGENSTRAT
	genotypeoutname: "$outputdir"/merged_uk_protect_"$studyname".pop_strat.eigenstratgeno
	snpoutname: "$outputdir"/merged_uk_protect_"$studyname".pop_strat.snp
	indivoutname: "$outputdir"/merged_uk_protect_"$studyname".pop_strat.ind")

	smartpca.perl \
	-i $outputdir/merged_uk_protect_$studyname.pop_strat.eigenstratgeno \
	-a $outputdir/merged_uk_protect_$studyname.pop_strat.snp \
	-b $outputdir/merged_uk_protect_$studyname.pop_strat.ind \
	-o $outputdir/merged_uk_protect_$studyname.pop_strat.pca \
	-p $outputdir/merged_uk_protect_$studyname.pop_strat.indpop_strat.plot \
	-e $outputdir/merged_uk_protect_$studyname.pop_strat.eval \
	-l $outputdir/merged_uk_protect_$studyname.pop_strat_smartpca.log \
	-m 0 \
	-t 100 \
	-k 100 \
	-s 6

	#to allow import in to R
	sed -i -e 's/^[ \t]*//' -e 's/:/ /g' $outputdir/merged_uk_protect_$studyname.pop_strat.pca.evec

done
