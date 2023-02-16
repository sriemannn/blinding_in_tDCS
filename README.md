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


## Third step: Interpretation
