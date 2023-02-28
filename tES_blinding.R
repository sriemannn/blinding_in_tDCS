# Blinding Indices for tES Studies
# Author: Anna E. Fromm
# the script used several existing packages and I do not want to take
# credit for developing another tool;
# I just want to show how I use different packages within my research

# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/
# https://cran.r-project.org/web/packages/BI/index.html

rm(list = ls())
library(openxlsx)
library(dplyr)
library(tidyr)
# install.packages("BI")
library(BI)

# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/
# https://cran.r-project.org/web/packages/BI/index.html

# setwd("XXXXX")

df1 <- read.xlsx("example_blinding.xlsx",
    sheet = 1, startRow = 1, colNames = TRUE, rowNames = FALSE,
    detectDates = FALSE, skipEmptyRows = TRUE, skipEmptyCols = TRUE,
    rows = NULL, cols = NULL, sep.names = ".", na.strings = "NA",
    fillMergedCells = FALSE
)

response_pivot <- df1 %>%
    group_by(group) %>%
    count(guess) %>%
    pivot_wider(
        names_from = group,
        values_from = n
    ) %>%
    rename(
        Placebo = A,
        Treatment = B
    )

response_pivot[is.na(response_pivot)] <- 0

x <- data.matrix(response_pivot)[, 2:3]

BI(x)
BI(x, alternative.B = "greater")
BI(x, alternative.B = "less")
