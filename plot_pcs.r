### Plot PCs 
### Ryan Arathimos
### 08/01/2020

library(ggplot2)
library(openxlsx)
library(RColorBrewer)

print("Loaded all packages!")
Sys.setenv("DISPLAY"=":0.0")

#PULL IN ARGS 
args = commandArgs(trailingOnly=TRUE)
pcsname <- args[1]
dir1 <- args[2]
round_n <- args[3]
i <- args[4]

datadir <- "~/brc_scratch/data/protect_qc"

print("Imported args!")

#read in calculated PCs from EIGENSOFT
pca <- read.table(paste0(dir1,"/", pcsname ), quote="\"")

print("Done with loading PCs from file!")

#rename PC columns to pc1-100
names(pca) <- c("V1","ID", paste0("pc", seq(1:(ncol(pca)-2))))
pca3 <- pca

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

#loop over vars that may explain variation in PCs and plot against top 5 PCs
setwd(dir1)

print("Entering plotting section!...")

if (i=="TEC") { 
  #plot PCs with phenotypic ethnicity
  print("Plotting by ethnicity for TEC IDs...")

  #merge PCs with ethnicity
  pca4 <- merge(pca3, ethn, by.x="ID", by.y="B20_TEC_ID", all.x=T)
  pca4$DEM_EthnicOrigin[is.na(pca4$DEM_EthnicOrigin)] <- "Unknown"
  head(pca4)

  for (j in c("DEM_EthnicOrigin")) {

    gg <- ggplot(data=pca4, aes_string(x="pc1", y="pc2", colour=paste0(j))) +
      geom_point(alpha=0.7, size=3) +
      ggtitle(paste0("PCs from N ", nrow(pca4) ," samples")) +
      scale_fill_brewer(palette="Set1", aesthetics = c("colour")) +
      theme_bw()
    
    png(filename = paste0("pc1_vs_pc2_", i,  "_", round_n, "_ethnicities.png"), width = 24, height = 20, res=300, units = "cm")
    print(gg)
    dev.off()
    #bitmap(file = paste0("pc1_vs_pc2_", i,  "_", round_n, "_ethnicities.png"), type = "png16m", height = 20, width = 20, res = 300, units = "cm" )
    #print(gg)
    #dev.off()

    print("Done plotting one!")

    
  }
  } else {

   print("Done!")
   
  }

    gg <- ggplot(data=pca3, aes_string(x="pc1", y="pc2")) +
    geom_point(alpha=0.6, color='cornflowerblue', size=3) +
    ggtitle(paste0("PCs from N ", nrow(pca3) ," samples")) +
    theme_bw()
  
  png(filename = paste0("pc1_vs_pc2_", i, "_", round_n, ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()
  
  ##
  gg <- ggplot(data=pca3, aes_string(x="pc2", y="pc3")) +
    geom_point(alpha=0.6, color='cornflowerblue', size=3) +
    ggtitle(paste0("PCs from N ", nrow(pca3) ," samples")) +
    theme_bw()
  
  png(filename = paste0("pc2_vs_pc3_", i, "_", round_n, ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()
  
  ##
  gg <- ggplot(data=pca3, aes_string(x="pc3", y="pc4")) +
    geom_point(alpha=0.6, color='cornflowerblue', size=3) +
    ggtitle(paste0("PCs from N ", nrow(pca3) ," samples")) +
    theme_bw()
  
  png(filename = paste0("pc3_vs_pc4_", i, "_", round_n, ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()
  
  ##
  gg <- ggplot(data=pca3, aes_string(x="pc4", y="pc5")) +
    geom_point(alpha=0.6, color='cornflowerblue', size=3) +
    ggtitle(paste0("PCs from N ", nrow(pca3) ," samples")) +
    theme_bw()
  
  png(filename = paste0("pc4_vs_pc5_", i,  "_", round_n, ".png"), width = 24, height = 20, res=300, units = "cm")
  print(gg)
  dev.off()

#


