# PREPARATION

# Import packages and files
library(dplyr)
library(tidyr)
library(ggplot2)
water2017 <- read.csv("2017.csv")

# Remove unnecessary columns to improve processing speed. "X.id" and "sample.samplingPoint" are not useful because their values are URLs and will therefore be removed. "codedResultInterpretation.interpretation" are not useful because the entire column is empty.
water2017$X.id <- NULL
water2017$sample.samplingPoint <- NULL
water2017$codedResultInterpretation.interpretation <- NULL

# Convert sample.sampleDateTime to POSIXct format
water2017$sample.sampleDateTime <- as.POSIXct(water2017$sample.sampleDateTime, format = "%Y-%m-%dT%H:%M:%S")

# ORGANIZING THE DATASET BY TYPE OF TEST CONDUCTED

# Identifying the most frequently occuring determinand.label values
sorted.determinand.labels <- sort(table(water2017$determinand.label), decreasing = T)
head(sorted.determinand.labels, 10)

# Creating new data frames based on the type of test performed, identified by the column "determinand.label" (just the 10 most frequent cases).Note: not sure if this is necessary.
BOD.ATU <- filter(water2017, water2017$determinand.label == "BOD ATU")
Ammonia <- filter(water2017, water2017$determinand.label == "Ammonia(N)")
Sld.Sus.105C <- filter(water2017, water2017$determinand.label == "Sld Sus@105C")
Temp.Water <- filter(water2017, water2017$determinand.label == "Temp Water")
pH <- filter(water2017, water2017$determinand.label == "pH")
Nitrite.N <- filter(water2017, water2017$determinand.label == "Nitrite-N")
N.Oxidised <- filter(water2017, water2017$determinand.label == "N Oxidised")
Orthophospht <- filter(water2017, water2017$determinand.label == "Orthophospht")
Nitrate.N <- filter(water2017, water2017$determinand.label == "Nitrate-N")
O.Diss.sat <- filter(water2017, water2017$determinand.label == "O Diss %sat")

# EXPLORATORY ANALYSIS

# Compare relationship between test results and time.

# Creating function for plotting each test type's results WRT time.
plot.time <- function(x) {
  ggplot(x, aes(x = sample.sampleDateTime, y = result)) +
    geom_point(alpha = 0.1) +
    geom_smooth()
}
# Plot 1: BOD ATU vs Time... No trend observed.
plot.time(BOD.ATU) + ylim(c(0,50))
# Plot 2: Ammonia vs Time... Slight decrease in July- September
plot.time(Ammonia) + ylim(c(0, 50))
# Plot 3: Solids Suspended at 105C vs Time... Slight increase in winter-spring and decrease in summer-fall.
plot.time(Sld.Sus.105C) + ylim(c(0,100))
# Plot 4: Temperature of water vs Time... Significant increase in summer, decrease in winter, as expected.
plot.time(Temp.Water) + ylim(c(0,50))
# Plot 5: pH of water vs Time... Slight increase in April. Perhaps this corresponds to rainfall? Could compare this rainfall pattern.
plot.time(pH) + ylim(c(6,10))
# Plot 6: Nitrogen content from Nitrite vs Time... No trend observed.
plot.time(Nitrite.N) + ylim(c(0,5))
# Plot 7: N-Oxidised vs Time... Slight decrease from July - September.
plot.time(N.Oxidised) + ylim(c(0,75))
# Plot 8: Orthophospht vs Time... Slight increase in summer and decrease in winter.
plot.time(Orthophospht) + ylim(c(0,5))
# Plot 9: Nitrogen content from Nitrate vs Time. Slight decrease from July - September.
plot.time(Nitrate.N) + ylim(c(0, 50))
# Plot 10: O Diss %sat vs Time... Slight increase in April - June.
plot.time(O.Diss.sat) + ylim(c(0, 200))

# Compare relationship between test results and easting-northing position.

# Create function for plotting each test type's results WRT position. Problem: high outliers prevent color gradient from distinguishing between values closer to the average. Perhaps limit selection of observations to ones which have values within 2 standard deviations of the mean.
plot.position <- function(x) {
  ggplot(x, aes(x = sample.samplingPoint.easting,  y = sample.samplingPoint.northing, col = result)) +
    geom_point(alpha = 0.1) +
    scale_color_continuous(low = "red", high = "blue")
}

# Compare relationship between material type (x-axis) and various tests. Set each test as a member of a group.

ggplot(pH, aes(y = sample.sampledMaterialType.label, x = result)) +
  geom_point(alpha = 0.05) +
  geom_errorbar(ymin = sample.sampledMaterialType.label - sd(sample.sampledMaterialType.label), ymax = sample.sampledMaterialType.label + sd(sample.sampledMaterialType.label))

