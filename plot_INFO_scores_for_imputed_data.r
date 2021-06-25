### Plot INFO  scores for imputed data - 22 chromosomes only
### Requires extra RAM - 40 GB available minimum

library(tidyr)
library(data.table)
library(ggplot2)

setwd("~/brc_scratch/output/protect_qc/imputation/downloaded")

infofile <- fread(paste0("allchrs_maf_threshold.txt"), header=T, verbose=T, select=c("SNP","Rsq","MAF"))

#get rid of rows which are headers from individual files binding
dim(infofile)
infofile$rownums <- rownames(infofile)
excludes <- infofile$rownums[infofile$SNP %like% "SNP" ]
infofile2 <- infofile[ !(infofile$rownums %in% excludes), ]
dim(infofile2)

#split variant column in to chr:position and alleles
infofile2[, c("chromosome", "position","a1","a2") := tstrsplit(SNP, ":", fixed=TRUE)]
infofile2[, c("chromosome", "position","a1","a2","extra1","extra2") := tstrsplit(SNP, ":", fixed=TRUE)]
table(infofile2$chromosome)
table(infofile2$extra1)

infofile <- infofile2

infofile$Rsq <- as.numeric(infofile$Rsq)
infofile$MAF <- as.numeric(infofile$MAF)

#find NAs
infofile_na <- infofile[infofile$Rsq =="NA",]
head(infofile_na)

summary(infofile$MAF)
summary(infofile$Rsq)

#plot

gg0 <- ggplot(infofile, aes(x=Rsq)) +
 geom_histogram(bins=100)

bitmap(file = paste0("hist_Rsquared_22chromosomes_protect", ".png"), type = "png16m", width = 24, height = 20, res=300, units = "cm")
#png(filename = paste0("hist_Rsquared_22chromosomes_protect", ".png"), width = 20, height = 20, res=300, units = "cm")
	print(gg0)
dev.off()

###########

gg1 <- 	ggplot(infofile, aes(x=Rsq, stat(density), colour = chromosome)) +
  		geom_freqpoly() +
  		ggtitle(paste0(NROW(infofile) ," variants")) +
  		theme_bw()

#binwidth = 50
bitmap(file = paste0("Rsquared_22chromosomes_protect", ".png"), type = "png16m", width = 24, height = 20, res=300, units = "cm")
#png(filename = paste0("Rsquared_22chromosomes_protect", ".png"), width = 24, height = 24, res=300, units = "cm")
	print(gg1)
dev.off()

#exclude those with very low MAF and replot
infofile_maf <- infofile[which(infofile$MAF>0.001),]
dim(infofile_maf)

gg2 <- 	ggplot(infofile_maf, aes(x=Rsq, stat(density), colour = chromosome)) +
  geom_freqpoly() +
  ggtitle(paste0(NROW(infofile_maf) ," variants"), subtitle="MAF > 0.001") +
  theme_bw()

bitmap(file = paste0("Rsquared_rare_excluded_22chromosomes_protect", ".png"), type = "png16m", width = 24, height = 20, res=300, units = "cm")
#png(filename = paste0("Rsquared_rare_excluded_22chromosomes_protect", ".png"), width = 24, height = 24, res=300, units = "cm")
print(gg2)
dev.off()







#comparison of low and high and medium maf

gg_x <- 	ggplot(infofile[which(infofile$MAF<0.01),], aes(x=Rsq, stat(density), colour = chromosome)) +
  geom_freqpoly() +
  ggtitle(paste0(NROW(infofile[which(infofile$MAF<0.01),]) ," variants"), subtitle="MAF < 0.01") +
  theme_bw()

bitmap(file = paste0("Rsquared_lowmaf_22chromosomes_protect", ".png"), type = "png16m", width = 24, height = 20, res=300, units = "cm")
#png(filename = paste0("Rsquared_lowmaf_22chromosomes_protect", ".png"), width = 24, height = 24, res=300, units = "cm")
print(gg_x)
dev.off()

###

gg_x <- 	ggplot(infofile[which(infofile$MAF>0.01),], aes(x=Rsq, stat(density), colour = chromosome)) +
  geom_freqpoly() +
  ggtitle(paste0(NROW(infofile[which(infofile$MAF>0.01),]) ," variants"), subtitle="MAF > 0.01") +
  theme_bw()

bitmap(file = paste0("Rsquared_highmaf_22chromosomes_protect", ".png"), type = "png16m", width = 24, height = 20, res=300, units = "cm")
#png(filename = paste0("Rsquared_highmaf_22chromosomes_protect", ".png"), width = 24, height = 24, res=300, units = "cm")
print(gg_x)
dev.off()

###

gg_x <- 	ggplot(infofile[which(infofile$MAF>0.001),], aes(x=Rsq, stat(density), colour = chromosome)) +
  geom_freqpoly() +
  ggtitle(paste0(NROW(infofile[which(infofile$MAF>0.001),]) ," variants"), subtitle="MAF > 0.001") +
  theme_bw()

bitmap(file = paste0("Rsquared_mediummaf_22chromosomes_protect", ".png"), type = "png16m", width = 24, height = 20, res=300, units = "cm")
#png(filename = paste0("Rsquared_mediummaf_22chromosomes_protect", ".png"), width = 24, height = 24, res=300, units = "cm")
print(gg_x)
dev.off()