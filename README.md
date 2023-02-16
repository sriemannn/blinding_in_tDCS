# blinding_in_tDCS

I want to show how to check the blinding of participants within a tDCS study. 

Literature suggestions: 
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/
- https://cran.r-project.org/web/packages/BI/index.html

## First step: Create the data set 
- in order to gain data about the blinding, you can use the TES questionnaire from Table 11 ("Questionnaire of sensations related to transcranial electrical stimulation (TES)" https://pubmed.ncbi.nlm.nih.gov/28709880/)
- you ask the participants to guess in which group they have been
- they can select: treatment, placebo or don't know 
- the table should contain (at least) the following variables: id, group, guess

## Second step: Analysis with R 
- in order to test the "pipeline", you can use the example data (example_blinding.xlsx) and the R code (tES_blinding.R)
- required packages: BI 
- read the data and create a table for your manuscript

#### Preparation 
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
####
#### applying the blinding index  
                  x <- matrix(c(9, 8, 12, 11, 5, 7), nrow = 3, ncol = 2, byrow = TRUE)
                  x
                  BI(x)
                  BI(x, alternative.B = "greater")
                  BI(x, alternative.B = "less")
####
- pay attention that the matrix order looks like your blinding table

## Third step: Interpretation
