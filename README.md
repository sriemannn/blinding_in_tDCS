# blinding_in_tDCS

I want to show how to check the blinding of participants within a tDCS study. 

Literature suggestions: 
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/
- https://cran.r-project.org/web/packages/BI/index.html

## Theorectical Background
- we are interested in two different blinding indices (BI): James' BI and Bang's BI

### James' BI
- James' BI is not treatment arm specific (no closer look within the subgroups)
- James' BI ranges from 0 to 1
- 0 representing total lack of blinding (all participants guess right)
- 1 representing complete blinding (all participants guess wrong) 
    - could be also problematic: may indicate "unblinding" in the opposite direction
- 0.5 representing completely random blinding (half the participants guess correct, half guess right)
- lack of blinding can be considered if the upper bound of the (two-sided) confidence interval is below 0.5 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/)

### Bang's BI
- Bang's BI is treatment arm specific (looks at the blinding within each treatment)
- Bang's BI ranges from -1 to 1
- 0 representing completly random blinding (half the participants guess correct, half guess right)
- 1 representing complete unblinding (all participants guess right)
- -1 representing all participants guess their treatment wrong 
    - could be also problematic: may indicate "unblinding" in the opposite direction
- if -0.2 <= Bang's BI <= 0.2: blinding is considered to be successful
- lack of blinding can be considered if relevant limit of the one-sided confidence interval does not cover 0 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/)


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
#### James' BI
                             Estimate Std. Error 95% LCL (2-Sided) 95% UCL (2-Sided)
                    Overall 0.6125215 0.06646557         0.4822513         0.7427916
####
- James’ BI estimate was 0.6 (95% CI: 0.5-0.7) implying that the participants were effectively blinded
    -  0.5 representing completely random blinding (half the participants guess correct, half guess right)
    - lack of blinding can be considered if the upper bound of the (two-sided) confidence interval is below 0.5 
        -  0.7 > 0.5
