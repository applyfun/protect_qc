#!/bin/bash -l
#SBATCH --output=/scratch/users/%u/%j.king.out --mem=40000 --partition brc,shared

#run KING

#set directories and config
module add apps/R/3.6.0

cd ~/brc_scratch/output/protect_qc

listnames=(BPD BBP MAGD WLD DPM LCR UNK DCR BK BR CHN TEC)

for studyname in "${listnames[@]}" ; do
	echo "$studyname"

	#~/brc_scratch/software/king -b $outputdir/merged_uk_protect_$studyname.filtered.bed --kinship --unrelated --degree 3 --prefix $studyname.king

	#~/brc_scratch/software/king -b ~/brc_scratch/output/protect_qc/merged_uk_protect_$studyname.filtered.bed --related --degree 3 --prefix $studyname.king.related

	~/brc_scratch/software/king -b ~/brc_scratch/output/protect_qc/merged_uk_protect_$studyname.filtered.bed --kinship --unrelated --degree 3 --prefix $studyname.king.kinship

done

#plot

listnames2=(BPD BBP MAGD WLD DPM LCR UNK DCR BK BR CHN TEC)

for studyname in "${listnames2[@]}" ; do
	echo "$studyname"

	Rscript --vanilla ~/brc_scratch/scripts/protect_qc/plot_KING_robust_output.R $studyname 

done
	
#test run
#Rscript --vanilla ~/brc_scratch/scripts/protect_qc/plot_KING_robust_output.R TEC 


