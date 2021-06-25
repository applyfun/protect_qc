#Sort 1000G data and project on to PROTECT data
#R Arathimos

#set directories and config
cd ~/brc_scratch/data/protect_qc/

printf "root=~/brc_scratch/data/protect_qc
file_ioe24=UK_ByronCreese_PN_alias.ioe24
pheno=~/brc_scratch/data/protect/reformated_mdd_pheno_final.raw
outputdir=~/brc_scratch/output/protect_qc
datadir=~/brc_scratch/data/protect_qc
covar=/path/to/covariates.cov
gwas_scriptsdir=~/brc_scratch/scripts/protect_qc/gwas_scripts-master
plink=plink
R=/path/to/R" > Config.conf 

source Config.conf

cd $outputdir

###

cd ~/brc_scratch/data/protect_qc/1000g

#build is GRCh37/hg19
wget https://www.dropbox.com/s/k9ptc4kep9hmvz5/1kg_phase1_all.tar.gz?dl=1

mv 1kg_phase1_all.tar.gz?dl=1 1kg_phase1_all.tar.gz

tar -xzf 1kg_phase1_all.tar.gz

wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_g1k.ped

grep -f <(awk '{print $2}' 1kg_phase1_all.fam) <(awk 'NR > 1 {print 0, $2, $7}' 20130606_g1k.ped) > 1KG_Phenos.txt

sed -i -e 's/ASW/3/g' -e 's/CEU/4/g' -e 's/CHB/5/g' -e 's/CHS/6/g' -e 's/CLM/7/g' -e 's/FIN/8/g' -e 's/GBR/10/g' -e 's/IBS/11/g' -e 's/JPT/12/g' -e 's/LWK/13/g' -e 's/MXL/14/g' -e 's/PUR/15/g' -e 's/TSI/16/g' -e 's/YRI/17/g' 1KG_Phenos.txt

rm 1kg_phase1_all.tar.gz

#Limit files to SNPs with rs IDs
fgrep rs $outputdir/merged_uk_protect_TEC.filtered.unrelated.LD_three.bim > $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsids.txt
#Get rs ID variant names
awk '{print $2}' $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsids.txt > $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsid_names.txt
wc -l $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsid_names.txt
head $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsid_names.txt

#limit to the list created
cd ~/brc_scratch/data/protect_qc/1000g

plink \
--bfile 1kg_phase1_all \
--extract $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsid_names.txt \
--make-bed \
--out 1kg_phase1_all_forliftover_pruned

wc -l 1kg_phase1_all_forliftover_pruned.bim

#convert to ped/map first
plink \
--bfile 1kg_phase1_all_forliftover_pruned \
--recode \
--tab \
--out 1kg_phase1_all_ped_forliftover

rm 1kg_phase1_all.bed
rm 1kg_phase1_all.bim
rm 1kg_phase1_all.fam

#lift
module load general/python/2.7.10
python ~/brc_scratch/software/liftOverPlink-master/liftOverPlink.py --bin ~/brc_scratch/software/liftOver_v0 --map 1kg_phase1_all_ped_forliftover.map --out 1kg_phase1_all_ped_forliftover_lifted --chain ~/brc_scratch/software/hg19ToHg38.over.chain.gz

#remove bad lifted snps, generate good ped snd combine fixed ped with fixed map
python ~/brc_scratch/software/liftOverPlink-master/rmBadLifts.py --map 1kg_phase1_all_ped_forliftover_lifted.map --out good_lifted.map --log bad_lifted.dat

cut -f 2 bad_lifted.dat > to_exclude.dat
cut -f 4 1kg_phase1_all_ped_forliftover_lifted.bed.unlifted | sed "/^#/d" >> to_exclude.dat 
wc -l to_exclude.dat 

plink \
--file 1kg_phase1_all_ped_forliftover \
--recode \
--out lifted \
--exclude to_exclude.dat

plink \
--map good_lifted.map \
--ped lifted.ped \
--make-bed \
--out final2

#convert map files back to bed bim fam
plink \
--bfile final2 \
--make-bed \
--out 1kg_phase1_all_liftover_converted

#tidy 
rm 1kg_phase1_all_ped_forliftover.ped
rm final2*

#Extract rs IDs from root
plink \
--bfile $outputdir/merged_uk_protect_TEC.filtered.unrelated.LD_three \
--extract $outputdir/merged_uk_protect_TEC.LD_three.data.pruned.rsid_names.txt \
--chr 1-22 \
--make-bed \
--out $outputdir/protect_for_1000g_extracted

#Extract rs IDs from 1KG (and add phenotypes)
plink \
--bfile 1kg_phase1_all_liftover_converted \
--extract $outputdir/merged_uk_protect_$studyname.LD_three.data.pruned.rsid_names.txt \
--pheno 1KG_Phenos.txt \
--make-bed \
--out 1kg_phase1_all.rsids.autosomal

#Obtain SNPs present in both files
awk '{print $2}' 1kg_phase1_all.rsids.autosomal.bim > 1kg_phase1_all.rsids_names.txt
#check
head 1kg_phase1_all.rsids_names.txt
wc -l 1kg_phase1_all.rsids_names.txt

##
listnames=(TEC)

for studyname in "${listnames[@]}" ; do

    echo "$studyname"

    #Extract 1KG SNPs from root
	plink \
	--bfile $outputdir/merged_uk_protect_$studyname.filtered.unrelated.LD_three \
	--extract 1kg_phase1_all.rsids_names.txt \
	--make-bed \
	--out $outputdir/merged_uk_protect_$studyname.intersection

done

#Dry run bmerge to identify SNPs PLINK will fail on
for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	plink \
	--bfile $outputdir/merged_uk_protect_$studyname.intersection \
	--bmerge 1kg_phase1_all.rsids.autosomal \
	--merge-mode 6 \
	--out 1KG.data.$studyname.pruned_failures

done

##remove muliallelic if present
for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	#### MULTIALLELIC VARIANTS PRESENT
	plink \
	--bfile $outputdir/merged_uk_protect_$studyname.intersection \
	--exclude 1KG.data.$studyname.pruned_failures.missnp \
	--make-bed \
	--out $outputdir/merged_uk_protect_$studyname.intersection_multiallelic_removed

done

for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	#dry run again
	wc -l $outputdir/merged_uk_protect_$studyname.intersection_multiallelic_removed.bim
	head $outputdir/merged_uk_protect_$studyname.intersection_multiallelic_removed.bim
	head $outputdir/merged_uk_protect_$studyname.intersection_multiallelic_removed.fam
	wc -l $outputdir/merged_uk_protect_$studyname.intersection_multiallelic_removed.fam

	plink \
	--bfile $outputdir/merged_uk_protect_$studyname.intersection_multiallelic_removed \
	--bmerge 1kg_phase1_all.rsids.autosomal \
	--merge-mode 6 \
	--out 1KG.data.$studyname.pruned_failures

	#list variants with mutiple positions
	grep \'rs 1KG.data.$studyname.pruned_failures.log |\
	awk '{print $7}' > 1KG.failures.$studyname.multiple.positions.txt
	sed -i 's/.//;s/.$//' 1KG.failures.$studyname.multiple.positions.txt
	sed -i "s/'//g"  1KG.failures.$studyname.multiple.positions.txt 

	#Add variants with multiple positions to missnp
	cat 1KG.data.$studyname.pruned_failures.missnp 1KG.failures.$studyname.multiple.positions.txt > 1KG.failures.$studyname.multiple.positions.all.txt

done

for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	#Exclude mismatched SNPs and variants with multiple positions
	plink \
	--bfile $outputdir/merged_uk_protect_$studyname.intersection \
	--exclude 1KG.failures.$studyname.multiple.positions.all.txt \
	--make-bed \
	--out data.pruned.$studyname.intersection_for_merge

done

#Merge data and 1KG
cd $datadir/1000g

for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	plink \
	--bfile data.pruned.$studyname.intersection_for_merge \
	--bmerge 1kg_phase1_all.rsids.autosomal \
	--out 1kg.$studyname.pop_strat

done

#Filter missing variants, rare variants and HWE
for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	plink \
	--bfile 1kg.$studyname.pop_strat \
	--geno 0.01 \
	--maf 0.01 \
	--hwe 0.00001 \
	--make-bed \
	--out 1kg.$studyname.pop_strat.for_prune

done

#LD Pruning
for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	plink \
	--bfile 1kg.$studyname.pop_strat.for_prune \
	--indep-pairwise 1500 150 0.2 \
	--out 1kg.$studyname.pop_strat.prune

done

for studyname in "${listnames[@]}" ; do

    echo "$studyname"

	plink \
	--bfile 1kg.$studyname.pop_strat.for_prune \
	--extract 1kg.$studyname.pop_strat.prune.prune.in \
	--make-bed \
	--out 1kg.$studyname.pop_strat.pruned

done


	plink \
	--bfile 1kg.$studyname.pop_strat.pruned \
	--freq

#Run convertf to make EIGENSTRAT file
module load bioinformatics/EIGENSOFT/6.1.4

for studyname in "${listnames[@]}" ; do

    echo "$studyname"

    #make sure fam file have all the same family ID
    awk '{$1="FAM001"; print}' 1kg.$studyname.pop_strat.pruned.fam > TMPFAM && mv TMPFAM 1kg.$studyname.pop_strat.pruned.fam
    #make sure all individuals have a phenotype value
	awk '{$6=($6<0)?1:$6}1' OFS='\t' 1kg.$studyname.pop_strat.pruned.fam > TMPFAM2 && mv TMPFAM2 1kg.$studyname.pop_strat.pruned.fam

	convertf -p <(printf "genotypename: 1kg.$studyname.pop_strat.pruned.bed
	             snpname: 1kg.$studyname.pop_strat.pruned.bim
	             indivname: 1kg.$studyname.pop_strat.pruned.fam
	             outputformat: EIGENSTRAT
	             genotypeoutname: 1kg.$studyname.pop_strat.pruned.eigenstratgeno
	             snpoutname: 1kg.$studyname.pop_strat.pruned.snp
	             indivoutname: 1kg.$studyname.pop_strat.pruned.ind")

done

#Generate poplist for projection
awk '{print $3}' 1KG_Phenos.txt | sort | uniq > 1kg.LD_poplist.txt
head 1kg.LD_poplist.txt

#Run Smartpca, projecting on 1KG samples only
smartpca.perl \
-i 1kg.$studyname.pop_strat.pruned.eigenstratgeno \
-a 1kg.$studyname.pop_strat.pruned.snp \
-b 1kg.$studyname.pop_strat.pruned.ind \
-o 1kg.$studyname.pop_strat.pruned.pca \
-p 1kg.$studyname.pop_strat.pruned.plot \
-e 1kg.$studyname.pop_strat.pruned.eigenvalues \
-l 1kg.$studyname.pop_strat.pruned.log \
-w 1kg.LD_poplist.txt \
-m 0 \
-k 5

#enable R import
sed -i -e 's/^[ \t]*//' -e 's/:/ /g' 1kg.$studyname.pop_strat.pruned.pca.evec

plink \
--bfile ~/brc_scratch/data/pelotas_adhd/FINAL_ZCALL/Brazil_Pelotas_GSAv2_190713_Intesity_Data_zcall_final.data.pruned \
--write-snplist \
--out list1 \
--noweb

plink \
--bfile 1kg_phase1_all \
--extract list1.snplist \
--noweb \
--out fileB_filtered \
--make-bed

plink \
--bfile 1kg_phase1_all \
--recode-vcf \
--out 1kg_phase1_all_vcf

plink \
--bfile $root.data.pruned \
--recode-vcf \
--out ~/brc_scratch/data/pelotas_adhd/FINAL_ZCALL/pelotas_vcf

#compress to bgzip and sort with tabix ready for vcf-tools
cd ~/brc_scratch/data/pelotas_adhd/1000g
#gzip 1kg_phase1_all_vcf
~/brc_scratch/software/tabix-0.2.6/bgzip 1kg_phase1_all_vcf.vcf
~/brc_scratch/software/tabix-0.2.6/tabix -p vcf 1kg_phase1_all_vcf.vcf.gz

cd ~/brc_scratch/data/pelotas_adhd/FINAL_ZCALL
#gzip pelotas_vcf.vcf
~/brc_scratch/software/tabix-0.2.6/bgzip pelotas_vcf.vcf
~/brc_scratch/software/tabix-0.2.6/tabix -p vcf pelotas_vcf.vcf.gz

#merge using vcf-tools perl script
cd ~/brc_scratch/data/pelotas_adhd/
source Config.conf

cd ~/brc_scratch/data/pelotas_adhd/1000g
$vcf_dir/vcf-merge ~/brc_scratch/data/pelotas_adhd/FINAL_ZCALL/pelotas_vcf.vcf.gz.tbi  1kg_phase1_all_vcf.vcf.gz

#convert back to bed format
plink \
--vcf \
--make-bed \
--out merged_1000g

plink \
--bfile merged_1000g \
--mds-plot 2 \
--noweb \
--out mds

#end

