# Water-Treatment-Capstone

## Background

Bathing or swimming in bodies of water that have significant e. coli levels can pose a health risk. E. coli is often tested for at beaches with a biological assay that can take some time to yield results. 

## Proposal

To get advance warning of risks of high e. coli levels as fast as possible, alternative tests that can yield results faster can be used to predict high e. coli levels.

## Approach

This project aims to use data from the [UK Environment Agency](http://environment.data.gov.uk/water-quality/view/landing) to search for correlations between the e. coli concentration and the results of various determinands, using data from 2013-2017.

After using the dplyr and tidyr packages to organize the raw data. All the results are stored within the same column, with the type of test the result is for on a separate column. The functions gather() and separate() will need to be used to reorganize the data into a tidy format such that the results for e. coli concentration and those of the alternative tests are isolated. Then ggplot2 will be used to visualize the relationships between each determinand and e. coli concentrations.

## Deliverables

This project will yield a predictive model that can anticipate high e. coli concentrttions within a certain confidence level.

# Additional Files

- The cleaned data set can be downloaded [here](https://drive.google.com/drive/folders/1CD8-oHrF6VQyjEdSL8v6PSWbstwB0T08?usp=sharing).
- "water.raw.csv" is a combination of all data from 2013-2017 with unnecessary rows removed.
- "water.raw.ecoli" is a data frame with extraneous material types and determinands removed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
