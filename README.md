# Water-Treatment-Capstone

## Background

Bathing or swimming in bodies of water that have significant e. coli levels pose a health risk. E. coli is often tested with a biological assay that can take some time to yield results. 

## Proposal

To get advance warning of risks of high e. coli levels more quickly, alternative chemical tests that can yield results faster can be used to predict high e. coli levels.

## Approach

This project aims to use data from the [UK Environment Agency](http://environment.data.gov.uk/water-quality/view/landing) to search for correlations between the e. coli concentration and the results of various determinands, using data from 2013-2017.

After using the dplyr and tidyr packages to organize the raw data. All the results are stored within the same column, with the type of test the result is for on a separate column. The functions gather() and separate() will need to be used to reorganize the data into a tidy format such that the results for e. coli concentration and those of the alternative tests are isolated. Then ggplot2 will be used to visualize the relationships between each determinand and e. coli concentrations.

## Deliverables

This project will yield a predictive model that can anticipate high e. coli concentrttions within a certain confidence level.

# Project Files

- "ecoli.script.R" is the script used to wrangle and explore the data
    - Section 1 (lines 1-31): GENERAL SETUP. This shows data wrangling from the original files pulled from the UK Environmental Agency.
    - Section 2 (lines 32-77): FILTERING AND TIDYING. This shows how the combined raw data was filtered for determinands of interest and converted into tidy format.
    - Section 3 (lines 78-129): EXPLORATORY ANALYSIS 1. Relationships between e. coli concentrations and each parameter aren't linear and require an alternative approach to predictive modeling.
    - Section 4 (lines 130- ongoing): TRANSFORMING DATA INTO BINARIES
- "water.raw.csv" is a combination of all data from 2013-2017 with unnecessary rows removed. This is created and processed in Section 1. Due to upload file size limitations on Github, this file is stored on a [Google Drive folder.] (https://drive.google.com/drive/folders/1CD8-oHrF6VQyjEdSL8v6PSWbstwB0T08?usp=sharing)
- "water.raw.ecoli" is a data frame with extraneous material types and determinands removed. This is derived from "water.raw.csv" and wrangled in Section 2.
