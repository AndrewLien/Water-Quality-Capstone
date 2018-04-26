# DATA WRANGLING

# Import packages and files
library(dplyr)
library(tidyr)
library(ggplot2)
water2017 <- read.csv("2017.csv", stringsAsFactors = F)

# Remove unnecessary columns to improve processing speed. "X.id" and "sample.samplingPoint" are not useful because their values are URLs and will therefore be removed. "codedResultInterpretation.interpretation" are not useful because the entire column is empty. "sample.samplingPoint.label" is removed because the names of the locations have too many levels to make any meaningful analysis."determinand.notation" is removed because it's redundant information: it's a numeric code assigned to each type of determinand, which is already given unique names in "determinand.label".

water2017$X.id <- NULL
water2017$sample.samplingPoint <- NULL
water2017$codedResultInterpretation.interpretation <- NULL
water2017$sample.samplingPoint.notation <- NULL
water2017$sample.samplingPoint.label <- NULL
water2017$determinand.notation <- NULL

# Renaming columns  
colnames(water2017) <- c("time", "determinand.label", "determinand.definition", "resultqualifier", "result", "resultunit", "materialtype", "compliance", "purpose", "easting", "northing")

# Convert time to POSIXct format
water2017$time <- as.POSIXct(water2017$time, format = "%Y-%m-%dT%H:%M:%S")

# Conversion to factors [might not be advantageous]
water2017$determinand.label <- as.factor(water2017$determinand.label)
water2017$determinand.definition <- as.factor(water2017$determinand.definition)
water2017$materialtype <- as.factor(water2017$materialtype)
water2017$compliance <- as.factor(water2017$compliance)

# Focusing data to only the 25 most frequently tested determinands. Set others to NULL. Combine other years to this dataset. Use grepl(commonnames) to return logical vector, add together and if greater than 1 than there's a true; keep that row. lapply(grepl)
commondeterminandsnames <- as.factor(names(head(sort(table(water2017$determinand.label), decreasing = T), 10)))
water2017cut <- filter(water2017, match(water2017$determinand.label, commondeterminandsnames) > 0)

# Remove outliers from each determinand, defined as values that are more than 2 standard deviations away from the mean. This is to allow scaling of axes of plots that better visualize trends. Create a for loop: filter by commondeterminandsnames, then filter according to a 2*sd margin. These are recombined as water2017cleaned.
for (x in 1:length(commondeterminandsnames)) {
  assign(paste("i", x, sep = "-"), filter(water2017cut, water2017cut$determinand.label == commondeterminandsnames[x]))
  assign(paste("j", x, sep = "-"), filter(paste("i", x, sep = "-"), paste("i", x, sep = "-")$result > mean(paste("i", x, sep = "-")) - 2*sd(paste("i", x, sep = "-")) & water2017cut$result < mean(paste("i", x, sep = "-")) + 2*sd(paste("i", x, sep = "-"))))
water2017cleaned <- rbind(water2017cleaned, paste("j", x, sep = "-"))
}


# ORGANIZING THE DATASET BY TYPE OF TEST CONDUCTED

# Creating new data frames based on the type of test performed, identified by the column "determinand.label" (just the 10 most frequent cases).Note: not sure if this is necessary. This filtering function can be done in a loop: filtering through the 10 most common levels. Use a for loop to cycle through each element of a vector.
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

# Creating function for plotting each test type's results WRT time. Place all levels into a vector. Filter dataframe
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

