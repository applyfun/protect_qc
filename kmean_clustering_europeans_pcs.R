# European ancestry clustering - Joni's Code
# /mnt/lustre/groups/ukbiobank/KCL_Data/Scripts/kcl_ukbb_scripts/bin/Make_UKBB_Caucasians_By_4_Means_Clustering.R 
##Set seed

library(dplyr)
library(ggplot2)

set.seed(1204688)

dir1 <- "~/brc_scratch/output/protect_qc/"
pcsname <- "merged_uk_protect_TEC.pop_strat.pca.evec"
 
setwd(dir1) 

#read in PCs
QC_DATA <- read.table(paste0(dir1,"/", pcsname ), quote="\"")
names(QC_DATA) <- c("V1","IID", paste0("PC", seq(1:(ncol(QC_DATA)-2))))

##K means clustering on each PC
K_MEAN <- 4

PCs=QC_DATA %>%
  select(IID, PC1, PC2)
PC1_K <- kmeans(PCs$PC1, K_MEAN)
PC2_K <- kmeans(PCs$PC2, K_MEAN)
PC1_2_K <- kmeans(PCs[,c("PC1","PC2")], K_MEAN)

##Add clusters to PC dataframe
PCs$PC1.Cluster <- PC1_K$cluster
PCs$PC2.Cluster <- PC2_K$cluster
#PCs$Clusters<-as.factor(paste(PC1_K$cluster,PC2_K$cluster,sep="."))

##EUROPEAN group is the majority
MAX_PC1 <- ifelse(match(max(table(PCs$PC1.Cluster, PCs$PC2.Cluster)), table(PCs$PC1.Cluster, PCs$PC2.Cluster)) %% K_MEAN == 0, K_MEAN, match(max(table(PCs$PC1.Cluster, PCs$PC2.Cluster)), table(PCs$PC1.Cluster, PCs$PC2.Cluster)) %% K_MEAN)
MAX_PC2 <- ceiling(match(max(table(PCs$PC1.Cluster, PCs$PC2.Cluster)), table(PCs$PC1.Cluster, PCs$PC2.Cluster))/K_MEAN)

##Make list of EUROPEAN IDs
EUROPEANS <- as.data.frame(PCs[PCs$PC1.Cluster == MAX_PC1 & PCs$PC2.Cluster == MAX_PC2,1])
names(EUROPEANS) <- "ID"
EUROPEANS$KMEANS <- "Europeans"

##Make list of kmeans europeans for plink
EUROPEANS$FID <- "FAM001"
plink_ids <- EUROPEANS[c("FID","ID")]

write.table(plink_ids, file="4means_europeans_id_list.txt", quote=F, row.names=F, col.names=F, sep="\t")

#plot the european cluster
QC_DATA2 <- merge(QC_DATA, EUROPEANS, by.x="IID", by.y="ID", all.x=T)
QC_DATA2[is.na(QC_DATA2$KMEANS),"KMEANS"] <- "Non-europeans"

  gg <- ggplot(data=QC_DATA2, aes_string(x="PC1", y="PC2", colour="KMEANS")) +
    geom_point(alpha=1, size=3) +
    ggtitle(paste0("Europeans estimated to be ", nrow(EUROPEANS) ," samples using k-means clustering")) +
    scale_fill_brewer(palette="Set1", aesthetics = c("colour")) +
    labs(colour='Clusters') +
    theme_bw()
  
 bitmap(file = paste0("pc1_vs_pc2_", "kmeans_clustering", ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
 dev.off()
  
#
