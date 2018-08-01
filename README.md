# Water-Treatment-Capstone

## Background

Bathing or swimming in bodies of water that have significant e. coli levels pose a health risk. E. coli bacteria normally live in the intestines of healthy people, but there are some strains that can cause severe abdominal cramps, diarrhea, fever, and sometimes vomiting, such as [E. coli O157:H7](https://www.medicalnewstoday.com/articles/68511.php). Most people will recover within a week, but this can be life-threatening in infants and in people with weakened-immune systems.  

To minize the number of e. coli infections, warnings are issued by the UK Environment Agency when e. coli concentration is measured to be higher than a safe level of [900 cfu/100ml](https://environment.data.gov.uk/bwq/profiles/help-understanding-data.html). However, a limitation of this warning is that the [e. coli concentration test](https://www.epa.gov/sites/production/files/2015-08/documents/method_1604_2002.pdf) takes at least 24 hours to perform. This is due to the fact that most biological assays require time for organisms to incubate.

## Proposal

In order to improve the warning speed when there's an e. coli level too high, the conditions which are associated with high e. coli concentrations can be monitored and used as an advance warning. By observing the results of chemical tests for which results can be obtained faster, it's possible to build a model that can predict, within a certain accuracy, when e. coli levels will be unsafe for swimming or bathing.

## Approach

This project aims to use data from the [UK Environment Agency](http://environment.data.gov.uk/water-quality/view/landing) to search for correlations between the e. coli concentration and the results of various determinands, using data from 2013-2017.

The raw data is organized into tidy format using tidyr and dplyr, such that different tests that have the same time, place, and material type are collapsed into the same observation. This data is then explored using ggplot2 to identify which variables are correlated to each other and which are most strongly correlated to e. coli levels. By identifying variables that have significant relationships to e. coli concentration, a logistical regression model is created to predict whether e. coli concentrations will be above or below safe levels.

**Note that because this data is so large, the sections "COMBINING ANNUAL DATA" and "FILTERING AND TIDYING DATA" are run separately to generate the file "water.ecoli.csv". This file is loaded to this script instead of loading each individual year's data and wrangling them. This is a limitation that arises due to limited computing power. Nevertheless, each step of the wrangling process is still described.**

## Deliverables

The objective of this project is to develop a model that can predict, based on different test results, whether a given sample will have an e. coli concentration above safe levels, within a certain confidence level.

# Project Files

- "water.ecoli.csv": the filtered and tidied dataset
- "2013.csv", "2014.csv", "2015.csv", "2016.csv", "2017.csv", and "water.raw.csv": these raw files are too large to be uploaded on github and are stored in a google drive folder at the following location: ____________
- "0.combining-annual-data.R": combines each individual year's data into one file, "water.raw.csv".
- "1-filtering-and-tidying.Rmd" 
- "2-exploratory-analysis.Rmd"
- "3-modeling.Rmd"
- "Final.Report[AndrewLien].Rmd"
- "Final.Presentation[AndrewLien].pptx"
- "Final.Script[AndrewLien].R": compiled, script only.
