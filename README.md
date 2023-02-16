# Blinding in tDCS

I want to show how to check the blinding of participants within a tDCS study.

Literature suggestions:

- <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/>
- <https://cran.r-project.org/web/packages/BI/index.html>

## Theoretical Background

- we are interested in two different blinding indices (BI): James' BI and Bang's BI

### James' BI

- James' BI is not treatment arm specific (no closer look within the subgroups)
- James' BI ranges from 0 to 1
- 0 representing total lack of blinding (all participants guess right)
- 1 representing complete blinding (all participants guess wrong)
  - could be also problematic: may indicate "unblinding" in the opposite direction
- 0.5 representing completely random blinding (half the participants guess correct, half guess right)
- lack of blinding can be considered if the upper bound of the (two-sided) confidence interval is below 0.5 (<https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/>)

### Bang's BI

- Bang's BI is treatment arm specific (looks at the blinding within each treatment)
- Bang's BI ranges from -1 to 1
- 0 representing completly random blinding (half the participants guess correct, half guess right)
- 1 representing complete unblinding (all participants guess right)
- -1 representing all participants guess their treatment wrong
  - could be also problematic: may indicate "unblinding" in the opposite direction
- if -0.2 <= Bang's BI <= 0.2: blinding is considered to be successful
- lack of blinding can be considered if relevant limit of the one-sided confidence interval does not cover 0 (<https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8533681/>)

## First step: Create the data set

- in order to gain data about the blinding, you can use the TES questionnaire from Table 11 ("Questionnaire of sensations related to transcranial electrical stimulation (TES)" <https://pubmed.ncbi.nlm.nih.gov/28709880/>)
- you ask the participants to guess in which group they have been
- they can select: treatment, placebo or don't know
- the table should contain (at least) the following variables: id, group, guess

## Second step: Analysis with R

- in order to test the "pipeline", you can use the example data (example_blinding.xlsx) and the R code (tES_blinding.R)
- required packages: BI
- read the data and create a table for your manuscript

### Preparation

```r


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

x <- data.matrix(response_pivot)[, 2:3]

```

### applying the blinding index  

```r
BI(x)
BI(x, alternative.B = "greater")
BI(x, alternative.B = "less")             

```

## Third step: Interpretation

### James' BI

```r

          Estimate Std. Error 95% LCL (2-Sided) 95% UCL (2-Sided)
 Overall 0.6125215 0.06646557         0.4822513         0.7427916
```

- James’ BI estimate was 0.6 (95% CI: 0.5-0.7) implying that the participants were effectively blinded
  - 0.5 representing completely random blinding (half the participants guess correct, half guess right)
  - lack of blinding can be considered if the upper bound of the (two-sided) confidence interval is below 0.5
    - 0.7 > 0.5

### Bang's BI

```r
    BI(x)
            Estimate Std. Error 95% LCL (2-Sided) 95% UCL (2-Sided)
Treatment -0.1153846  0.1747942        -0.4579750         0.2272058
Placebo    0.1153846  0.1661158        -0.2101963         0.4409655

BI(x, alternative.B="greater")
             Estimate Std. Error 95% LCL (1-Sided) 95% UCL (1-Sided)
Treatment -0.1153846  0.1747942        -0.4028956                 1
Placebo    0.1153846  0.1661158        -0.1578515                 1 

```

- the Bang’s BI for the anodal group was -0.1 (95% CI: -1, 0.2) and 0.1 (95% CI: -1, 0.4) for the sham group
- this result indicates that blinding was effective within the two stimulation conditions
  - 0 representing completly random blinding (half the participants guess correct, half guess right)
  - if -0.2 <= Bang's BI <= 0.2: blinding is considered to be successful
  - lack of blinding can be considered if relevant limit of the one-sided confidence interval does not cover 0
