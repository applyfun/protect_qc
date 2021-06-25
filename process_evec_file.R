### Process .evec file from PCA in to a more comprehensible format
### 14/05/2020
### R ARATHIMOS

data_dir <- "~/brc_scratch/output/protect_qc/transfer15052020/QC/pcs/europeans/raw/"
evec_file <- "merged_uk_protect_TEC_4means_europeans.pop_strat.pca.evec"

#process by reading in and reformatting
pcs1 <- read.table(paste0(data_dir,evec_file), header=F)

names(pcs1) <- c("FID","IID", paste0("pc", seq(1:(ncol(pcs1)-3))), "Status")

#check
head(pcs1)
dim(pcs1)

pcs1 <- pcs1[,c("IID", paste0("pc", seq(1:20)))]
head(pcs1)

setwd("~/brc_scratch/output/protect_qc/transfer15052020/QC/pcs/europeans/")

write.csv(pcs1, file="top20_pcs_reformatted_europeans.csv", row.names=F)

