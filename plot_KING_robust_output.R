args = commandArgs(trailingOnly=TRUE)
dataname <- args[1]

#Plot KING robust output
library(data.table, quietly=T)
library(ggplot2)

data_dir <- "~/brc_scratch/data/protect_qc/"
output_dir <- "~/brc_scratch/output/protect_qc/"

king0 <- fread(paste0(output_dir, dataname,".king.kinship.kin"))

####KING output...
head(king0)

print(paste0("Plotting related ", dataname))

#third degree relatives 0.0442-0.0884
setwd(output_dir)
gg1 <- ggplot(king0, aes(IBS0, Kinship)) +
	geom_point(alpha=1, colour="cornflowerblue") +
	geom_hline(yintercept=0.0442, color='coral', size=1) +
	xlab("IBS0 - Proportion of SNPs with zero IBS (identical-by-state)")
	
bitmap(file = paste0("king_ibs0_kinship_",dataname ,"_3rd_degree_plot.png"), type = "png16m", height = 20, width = 20, res = 300, units = "cm" )
#png(filename = paste0("king_ibs0_related_",dataname ,"_3rd_degree_plot.png"), width = 20, height = 20, res=300, units = "cm")
	print(gg1)
dev.off()


