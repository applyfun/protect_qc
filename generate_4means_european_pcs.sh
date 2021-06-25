#!/bin/bash -l
#SBATCH --output=/scratch/users/%u/%j.out --mem=20000 --partition brc

#set directories and config
cd ~/brc_scratch/data/protect_qc/

printf "root=~/brc_scratch/data/protect_qc
file_ioe24=UK_ByronCreese_PN_alias.ioe24
outputdir=~/brc_scratch/output/protect_qc
covar=/path/to/covariates.cov
gwas_scriptsdir=~/brc_scratch/scripts/protect_qc/gwas_scripts-master
plink=plink
R=/path/to/R" > Config.conf 

source Config.conf

cd $outputdir

#generate PCs

#PCs by EIGENSOFT
#module load bioinformatics/EIGENSOFT/6.1.4

#EIGENSOFT doesnt like phenotype in fam file coded as -9 so make sure it is reset to 1
 PATH=$PATH:~/brc_scratch/software/EIG-6.1.4/bin/
  

#generate PCs
     
	~/brc_scratch/software/EIG-6.1.4/bin/convertf -p <(printf "genotypename: "$outputdir"/merged_uk_protect_TEC.sexcheck1.cleaned.4means.europeans.bed
	snpname: "$outputdir"/merged_uk_protect_TEC.sexcheck1.cleaned.4means.europeans.bim
	indivname: "$outputdir"/merged_uk_protect_TEC.sexcheck1.cleaned.4means.europeans.fam
	outputformat: EIGENSTRAT
	genotypeoutname: "$outputdir"/merged_uk_protect_TEC_4means_europeans.pop_strat.eigenstratgeno
	snpoutname: "$outputdir"/merged_uk_protect_TEC_4means_europeans.pop_strat.snp
	indivoutname: "$outputdir"/merged_uk_protect_TEC_4means_europeans.pop_strat.ind")

	~/brc_scratch/software/EIG-6.1.4/bin/smartpca.perl \
	-i $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.eigenstratgeno \
	-a $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.snp \
	-b $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.ind \
	-o $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.pca \
	-p $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.indpop_strat.plot \
	-e $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.eval \
	-l $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat_smartpca.log \
	-t 100 \
	-k 100 \
	-s 30

	#to allow import in to R
	sed -i -e 's/^[ \t]*//' -e 's/:/ /g' $outputdir/merged_uk_protect_TEC_4means_europeans.pop_strat.pca.evec

#generate PCs - this time without removing outliers
     
	~/brc_scratch/software/EIG-6.1.4/bin/convertf -p <(printf "genotypename: "$outputdir"/merged_uk_protect_TEC.sexcheck1.cleaned.4means.europeans.bed
	snpname: "$outputdir"/merged_uk_protect_TEC.sexcheck1.cleaned.4means.europeans.bim
	indivname: "$outputdir"/merged_uk_protect_TEC.sexcheck1.cleaned.4means.europeans.fam
	outputformat: EIGENSTRAT
	genotypeoutname: "$outputdir"/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.eigenstratgeno
	snpoutname: "$outputdir"/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.snp
	indivoutname: "$outputdir"/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.ind")

	~/brc_scratch/software/EIG-6.1.4/bin/smartpca.perl \
	-i $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.eigenstratgeno \
	-a $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.snp \
	-b $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.ind \
	-o $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.pca \
	-p $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.indpop_strat.plot \
	-e $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.eval \
	-l $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat_smartpca.log \
	-m 0 \
	-t 100 \
	-k 100 \
	-s 6

	#to allow import in to R
	sed -i -e 's/^[ \t]*//' -e 's/:/ /g' $outputdir/merged_uk_protect_TEC_4means_europeans_nooutliersremoved.pop_strat.pca.evec