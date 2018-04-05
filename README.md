# Water-Treatment-Capstone

## Background

Chemical additives in drinking water have been known to be on the one hand necessary to neutralize any harmful bacteria but on the hand also harmful towards humans themselves in the long run. 

## Proposal

To minimize public exposure to chemical additives while adding enough to neutralize harmful bateria in drinking water, water treatment facilities can adjust the amount of chemical additives added to drinking water based on the expected bacterial concentration in water for each season. 

## Approach

This project aims to use data from the [UK Environment Agency] (http://environment.data.gov.uk/water-quality/view/landing) to search for patterns in the [BOD] (https://en.wikipedia.org/wiki/Biochemical_oxygen_demand) as a function of the changing seasons, using data from 2017 as a case study to compensate for the large size of the data sets.

After using the dplyr and tidyr packages to organize the raw data. All the results are stored within the same column, with the type of test the result is for on a separate column. The functions gather() and separate() will need to be used to reorganize the data into a tidy format such that the results for "BOD ATU" and "TIME/DATE" are isolated. Then ggplot2 will be used to plot the the change in BOD against the time each sample was taken. 

## Deliverables

This project will yield a correlation between time and BOD levels in water and present the information in a paper that outlines the long-term health dangers of chemical additives in drinking water, the plotted data, and the potential future research that can be done to identify how much chemical additive is needed to keep bacterial concentrations in drinking water below regulation levels.

## Similar work done

- [Seasonal variations in the risk of gastrointestinal illness on a tropical recreational beach] (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4271456/): This work used membrane filtration and culture methods on water samples to screen for bacterial concentration. This study demonstrated that seasons and bacterial concentration are correlated.
- [Factors and Mechanisms Affecting Seasonal Changes in the Prevalence of Microbiological Indicators of Water Quality and Nutrient Concentrations in Waters of the Białka River Catchment, Southern Poland] (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4975758/): This study also demonstrated that seasons had a direct correlation with bacterial concentrations in water, using both membrane filtration method and ion chromatography.

# Notes

- The trend that bacterial concentration increases in summertime and decreases in the winter has already been demonstrated. How can this dataset be used to 
