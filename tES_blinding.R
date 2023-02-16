#Blinding Assessment Indices for tES Studies
#Author: Anna E. Fromm 


rm(list=ls())
library(openxlsx)
library(dplyr)
#install.packages("BI")
library(BI)

#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/
#https://cran.r-project.org/web/packages/BI/index.html

setwd("E:/Arbeit/03 Weiterbildung/R/GitHub") 

df1 <- read.xlsx("example_blinding.xlsx"
                 ,sheet = 1, startRow = 1, colNames = TRUE, rowNames = FALSE, detectDates = FALSE,   skipEmptyRows = TRUE,   skipEmptyCols = TRUE,   rows = NULL,   cols = NULL,   sep.names = ".",   na.strings = "NA",   fillMergedCells = FALSE)


df1$group <- as.factor(df1$group)
df1$guess <- as.factor(df1$guess)

df1$guess <- recode(df1$guess, "1" ="1_active", "2"="2_placebo", "3"="3_dk")

df1_anodal <- df1[ which(df1$group=='B'), ]
vector_anodal <- dplyr::count(df1_anodal, guess)
names(vector_anodal)[names(vector_anodal) == "n"] <- "Treatment"

df1_sham <- df1[ which(df1$group=='A'), ]
vector_sham <- dplyr::count(df1_sham, guess)
names(vector_sham)[names(vector_sham) == "n"] <- "Placebo"

blinding_table <- merge(vector_anodal,vector_sham, all=TRUE)
blinding_table

x <- matrix(c(9, 8, 12, 11, 5, 7), nrow = 3, ncol = 2, byrow = TRUE)
x
BI(x)
BI(x, alternative.B = "greater")
BI(x, alternative.B = "less")


