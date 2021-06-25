### Plot PCs for PROTECT data
### Ryan Arathimos
### 16/01/2020

library(ggplot2)
library(openxlsx)
library(RColorBrewer)

print("Loaded all packages!")

datadir <- "~/brc_scratch/data/protect_qc"

outputdir <- "~/brc_scratch/output/protect_qc"

setwd(paste0(datadir))

#read in fam 
fam1 <- read.delim(paste0(datadir, "/1000g/1kg.TEC.pop_strat.pruned.fam"), sep="\t", header=F)
names(fam1) <- c("famID","ID","x2","x3","sex","pheno")

#read in calculated PCs from EIGENSOFT
pca <- read.table(paste0(datadir, "/1000g/1kg.TEC.pop_strat.pruned.pca.evec" ), quote="\"")
print("Done with loading PCs from file!")

#read in ethnicity phenotype from PROTECT
ethn <- read.xlsx(paste0(datadir,"/Decode_Ethnicity_cleaned.xlsx"))
ethn <- ethn[-1,] #first row of excel file is a header

#recode from numbers to ethnicities
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==NA] <- 0
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==1 | ethn$DEM_EthnicOrigin==2 | ethn$DEM_EthnicOrigin==3 | ethn$DEM_EthnicOrigin==4 ] <- "White European"
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==5 ] <- "White Non-European"
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==6 | ethn$DEM_EthnicOrigin==7 | ethn$DEM_EthnicOrigin==8 | ethn$DEM_EthnicOrigin==9 ] <- "Mixed"
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==10 | ethn$DEM_EthnicOrigin==11 | ethn$DEM_EthnicOrigin==12] <- "South Asian"
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==13 | ethn$DEM_EthnicOrigin==14 ] <- "East Asian or Other Asian"
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==15 | ethn$DEM_EthnicOrigin==16 | ethn$DEM_EthnicOrigin==17 ] <- "Black"
ethn$DEM_EthnicOrigin[ethn$DEM_EthnicOrigin==18 | ethn$DEM_EthnicOrigin==19 ] <- "Other"

#ethnicities codes as defined in PROTECT data collection:
#1 = White: English / Welsh / Scottish / Northern Irish / British
#2 = White: Irish
#3 = White: Gypsy or Irish Traveller
#4 = White: European
#5 = White: Non-European
#6 = Mixed: White and Black Caribbean
#7 = Mixed: White and Black African
#8 = Mixed: White and Asian
#9 = Mixed: Any other Mixed / Multiple ethnic background
#10 = Asian / Asian British: Indian
#11 = Asian / Asian British: Pakistani
#12 = Asian / Asian British: Bangladeshi
#13 = Asian / Asian British: Chinese
#14 = Asian / Asian British: Any other Asian background
#15 = Black / African / Caribbean / Black British: African
#16 = Black / African / Caribbean / Black British: Caribbean
#17 = Any other Black / African / Caribbean background
#18 = Other ethnic group: Arab
#19 = Any other ethnic group

#merge fam with ethnicities - keep all fam file entries (that include 1000g that are NA for ethnicity)
fam1 <- merge(fam1, ethn, by.x="ID", by.y="B20_TEC_ID", all.x=T)

#rename PC columns to pc1-5
names(pca) <- c("FAMID","IID", paste0("pc", seq(1:5)), "ID")

pca2 <- pca
pca2$Population <- as.character(pca2$ID)
pca2$Population[pca2$Population=="Control"] <- 1 #"control" is PROTECT samples
pca2$Population <- as.numeric(pca2$Population)

#population codes:
#/13CHANGE/LWK/g' -e 's/14CHANGE/MXL/g' -e 's/15CHANGE/PUR/g' -e 's/16CHANGE/TSI/g' -e 's/17CHANGE/YRI/g' -e 's/3CHANGE/ASW/g' -e 's/4CHANGE/CEU/g' -e 's/5CHANGE/CHB/g' -e 
#'s/6CHANGE/CHS/g' -e 's/7CHANGE/CLM/g' -e 's/8CHANGE/FIN/g' -e 's/10CHANGE/GBR/g' -e 's/11CHANGE/IBS/g' -e 's/12CHANGE/JPT/g' 
pca2$Population[pca2$Population==13] <- "LWK"
pca2$Population[pca2$Population==14] <- "MXL"
pca2$Population[pca2$Population==15] <- "PUR"
pca2$Population[pca2$Population==16] <- "TSI"
pca2$Population[pca2$Population==17] <- "YRI"
pca2$Population[pca2$Population==3] <- "ASW"
pca2$Population[pca2$Population==4] <- "CEU"
pca2$Population[pca2$Population==5] <- "CHB"
pca2$Population[pca2$Population==6] <- "CHS"
pca2$Population[pca2$Population==7] <- "CLM"
pca2$Population[pca2$Population==8] <- "FIN"
pca2$Population[pca2$Population==10] <- "GBR"
pca2$Population[pca2$Population==11] <- "IBS"
pca2$Population[pca2$Population==12] <- "JPT"
pca2$Population[pca2$Population==1] <- "PROTECT"

#set blanks to 'unknown' ethnicity and change from factor
#pca2$ethnicity <- as.character(pca2$ethnicity)
#pca2$ethnicity[pca2$ethnicity==""] <- "unknown"

pca3 <- merge(fam1, pca2, by.x="ID", by.y="IID")

#subset 1000g minimal populations
pca4 <- pca3[pca3$Population=="PROTECT" | pca3$Population=="CLM" | pca3$Population=="LWK" | pca3$Population=="CEU" | pca3$Population=="CHB" 
| pca3$Population=="MXL" | pca3$Population=="PUR" | pca3$Population=="ASW",]

#subset with PROTECT ethnicties plus 1000g minimal populations
pca5 <- pca4
pca5$Population[which(pca5$Population=="PROTECT" & !(pca5$DEM_EthnicOrigin=="<NA>"))] <- pca5$DEM_EthnicOrigin[which(pca5$Population=="PROTECT" & !(pca5$DEM_EthnicOrigin=="<NA>"))]
 
#plotting
setwd(outputdir)

for (i in c("Population")) {
  
  gg <- ggplot(data=pca3, aes_string(x="pc1", y="pc2", colour=paste0(i))) +
    geom_point(alpha=1, size=3) +
    scale_fill_brewer(palette="Set3", aesthetics = c("colour")) +
    theme_bw()

  bitmap(file = paste0("pc1_vs_pc2_PROTECT_TEST", "_", ".png"), width = 24, height = 20, res=300, units = "cm")
  #png(filename = paste0("pc1_vs_pc2_PROTECT_TEST", "_", ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()
  
  #minimal 1000g populations
  gg <- ggplot(data=pca4, aes_string(x="pc1", y="pc2", colour=paste0(i))) +
    geom_point(alpha=1, size=3) +
    scale_fill_brewer(palette="Set1", aesthetics = c("colour")) +
    theme_bw()
  
  bitmap(file = paste0("pc1_vs_pc2_PROTECT_TEST_MINPOPS", "_", ".png"), width = 24, height = 20, res=300, units = "cm")
  #png(filename = paste0("pc1_vs_pc2_PROTECT_TEST_MINPOPS", "_", ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()
  
    #minimal 1000g populations
    colourCount = length(unique(pca5$Population))
	getPalette = colorRampPalette(brewer.pal(9, "Set1"))

  gg <- ggplot(data=pca5, aes_string(x="pc1", y="pc2", colour=paste0(i))) +
    geom_point(alpha=1, size=3) +
    scale_fill_manual(values=getPalette(colourCount), aesthetics = c("colour")) +
    theme_bw()

  bitmap(file = paste0("pc1_vs_pc2_PROTECT_TEST_MINPOPS_ETHNICITIES", "_", ".png"), width = 24, height = 20, res=300, units = "cm")
  #png(filename = paste0("pc1_vs_pc2_PROTECT_TEST_MINPOPS_ETHNICITIES", "_", ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()
 
}

print("Done!")



