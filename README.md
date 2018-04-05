# Water-Treatment-Capstone

## Background

Chemical additives in drinking water have been known to be on the one hand necessary to neutralize any harmful bacteria but on the hand also harmful towards humans themselves in the long run. 

## Proposal

To minimize public exposure to chemical additives while adding enough to neutralize harmful bateria in drinking water, water treatment facilities can adjust the amount of chemical additives added to drinking water based on the expected bacterial concentration in water for each season. 

## Approach

This project aims to use data from the [UK Environment Agency] (http://environment.data.gov.uk/water-quality/view/landing) to search for patterns in the [BOD] (https://en.wikipedia.org/wiki/Biochemical_oxygen_demand) as a function of the changing seasons, using data from 2017 as a case study to compensate for the large size of the data sets.

After using the dplyr and tidyr packages to organize the raw data, the ggplot2 package will be used to plot the the change in BOD against the time each sample was taken. 
