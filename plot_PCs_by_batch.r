### Plot PCs by batch
### Ryan Arathimos

library(ggplot2)
library(openxlsx)
library(RColorBrewer)
library(gridExtra)

dir1 <- "~/brc_scratch/output/protect_qc"
setwd(dir1)

pcsname <- "merged_uk_protect_TEC_4means_europeans.pop_strat.pca.evec"

batchfile <- read.table(paste0(dir1,"/batch_variable_merged_uk_protect_final.txt"))
names(batchfile) <- c("ID","batch")
dim(batchfile)


batchfile2 <- read.table(paste0(dir1,"/FILE_dcgn.fam"))
batchfile2 <- batchfile2[c("V2")]
batchfile2$batch <- "batch00X"
names(batchfile2) <- c("ID","batch")

batchfile <- rbind(batchfile, batchfile2)
dim(batchfile)

pca <- read.table(paste0(dir1,"/", pcsname ), quote="\"")
dim(pca)
names(pca) <- c("V1","ID", paste0("pc", seq(1:(ncol(pca)-3))), "Control")

pca4 <- merge(pca, batchfile, by.x="ID" ,by.y="ID")
dim(pca4)

for (k in 1:20) {

    gg <- ggplot(data=pca4, aes_string(x=paste0("pc",k), y=paste0("pc",k+1), colour="batch" )) +
    geom_point(alpha=0.4, size=1.5, show.legend = FALSE) +
    ggtitle(paste0("PC ", k, " and ", k+1, "from N ", nrow(pca4) ," samples")) +
    theme_bw()

    assign(paste0("gg_s_",k), gg)

}

pdf(file = paste0("pc1_vs_pc2_", "with_genotype_batch", ".pdf"), width=20, height=20)

grid.arrange(gg_s_1,gg_s_2,gg_s_3,gg_s_4,gg_s_5,gg_s_6,gg_s_7,gg_s_8,gg_s_9,gg_s_10,gg_s_11,gg_s_12,gg_s_13,gg_s_14,gg_s_15,gg_s_16,gg_s_17,gg_s_18,gg_s_19,gg_s_20, ncol=5)

dev.off()


