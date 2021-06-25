### QC of PROTECT data
### Ryan Arathimos
### 23/10/2019

#First create a list of IDs categorised by each study present in the PROTECT datasets

cd ~/brc_scratch/output/protect_qc

printf "data_root=~/brc_scratch/data/protect_qc
output_root=~/brc_scratch/output/protect_qc" > Config.conf 

source Config.conf 

#append all fams
cat UK_ByronCreese_PN_alias.dcgn.fam UK_ByronCreese_PN_alias.ioe24.fam UK_Protect.fam $output_root/odinn/groups/bioinfo/requests/BID-312/output/UK_Protect.plink.dir/UK_Protect.fam > cat_file_fams.txt

wc -l cat_file_fams.txt

#strip out sample IDs
awk '{print $2}' cat_file_fams.txt > cat_file_fams_ids.txt

#pull out study IDs
listnames=(TEC BPD BBP MAGD WLD DPM LCR UNK DCR BK BR CHN)

for studyname in "${listnames[@]}" ; do
    echo "$studyname"
    grep -i $studyname cat_file_fams_ids.txt > $studyname.ids.list.txt
    wc -l $studyname.ids.list.txt
	head $studyname.ids.list.txt
done

#check numbers of rows pulled out equal total number in original file
touch checkfile_tmp.txt

for studyname in "${listnames[@]}" ; do
    echo "$studyname"
    cat checkfile_tmp.txt $studyname.ids.list.txt > tmp1 | mv tmp1 checkfile_tmp.txt
done

wc -l checkfile_tmp.txt #original file
wc -l cat_file_fams_ids.txt #check numbers match

head checkfile_tmp.txt

rm checkfile_tmp.txt

#combine IDs from separate files and give categorisation
COUNTER=0

for studyname in "${listnames[@]}" ; do
	awk '{print $1 "$COUNTER"}' $studyname.ids.list.txt > $studyname.ids.list.numbered.txt
	(( COUNTER++ ))
	echo $COUNTER
done

