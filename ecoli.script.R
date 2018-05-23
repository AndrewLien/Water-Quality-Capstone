# SECTION 1: GENERAL SETUP ----
# Import packages and files. Combine 5 year's worth of data, 2013 - 2017.
library(dplyr)
library(tidyr)
library(magrittr)
library(ggplot2)
water2013 <- read.csv("2013.csv", stringsAsFactors = F)
water2014 <- read.csv("2014.csv", stringsAsFactors = F)
water2015 <- read.csv("2015.csv", stringsAsFactors = F)
water2016 <- read.csv("2016.csv", stringsAsFactors = F)
water2017 <- read.csv("2017.csv", stringsAsFactors = F)
water.raw <- rbind(water2013, water2014, water2015, water2015, water2016, water2017)

# Remove unnecessary columns to improve processing speed. "sample.samplingPoint" is not useful because their values are URLs (X.id retained as a unique identifier for each row). "codedResultInterpretation.interpretation" is not useful because the entire column is empty. "sample.samplingPoint.label" and "samplingPoint.notation" are removed because the names of the locations have too many levels to make any meaningful analysis."determinand.notation" is removed because it's redundant information: it's a numeric code assigned to each type of determinand, which is already given unique names in "determinand.label". Results with a descriptive qualifier are treated as equivalent to their numerical value. "sample.isComplianceSample" is not of interest. "X.id" is arbitrary and will be reintroduced later to spread columns.
water.raw$sample.samplingPoint <- NULL
water.raw$codedResultInterpretation.interpretation <- NULL
water.raw$sample.samplingPoint.notation <- NULL
water.raw$sample.samplingPoint.label <- NULL
water.raw$determinand.notation <- NULL
water.raw$determinand.definition <- NULL
water.raw$resultQualifier.notation <- NULL
water.raw$sample.purpose.label <- NULL
water.raw$sample.isComplianceSample <- NULL
water.raw$X.id <- NULL

# Renaming columns  
colnames(water.raw) <- c("time", "determinand.label", "result", "resultunit", "materialtype", "easting", "northing")

# Export
write.csv(x = water.raw, file = "water.raw.csv", row.names = FALSE)

# SECTION 2: FILTERING AND TIDYING ----
# Performing summary() on the data reveals physically impossible/improbable results, e.x. pH > 14. Something's wrong with data wrangling.
# Solution: in the aggregated data set, find the results that are physically unrealistic and identify the days that correspond to those results. going back to the raw data set, filter for those days to see how that data corresponding to that day before the rows get aggregated. Could filter for all rows that have pH higher than 14 or water temperature above 100 C
# Perhaps the issue is multiple measurements of the same parameters on the same day at the same location at different times of the day. Solution would then simply be to not truncate the time parameter

water.raw <- read.csv("water.raw.csv", stringsAsFactors = F)

# Filtering data to 5 most common material types
materialswithecoli <- names(head(sort(table(filter(water.raw, water.raw$determinand.label == "E.coli C-MF")$materialtype), decreasing = T), 5))
water.raw.ecoli <- filter(water.raw, match(water.raw$materialtype, materialswithecoli) > 0)

# Filtering data to only the most significant determinands.
ecolideterminands <- c("E.coli C-MF", "Temp Water", "pH", "O Diss %sat", "Oxygen Diss", "Sld Sus@105C", "SALinsitu", "Ammonia(N)", "Nitrite-N", "Nitrate-N", "COD as O2")
water.raw.ecoli <- filter(water.raw.ecoli, match(water.raw.ecoli$determinand.label, ecolideterminands) > 0 )
water.raw.ecoli %<>% droplevels()
water.raw.ecoli$determinand.label %<>% as.factor()

# Spread according to the column "determinand.label" to get tidy data.
water.raw.ecoli$X.id <- 1:nrow(water.raw.ecoli)
water.raw.ecoli <- spread(water.raw.ecoli, key = determinand.label, value = result)
water.raw.ecoli$X.id <- NULL

# Remove duplicate rows
water.raw.ecoli <- unique(water.raw.ecoli)

# Adding resultunit to column names.
for (i in 6:length(water.raw.ecoli)) {
  position <- grep(x = is.na(water.raw.ecoli[,i]), pattern = FALSE)[1]
  unit <- water.raw.ecoli[position, "resultunit"]
  colnames(water.raw.ecoli)[i] <- paste(colnames(water.raw.ecoli)[i], unit, sep = ".")
}
water.raw.ecoli$resultunit <- NULL

# Aggregate rows. 
water.raw.ecoli <- aggregate(water.raw.ecoli[,5:length(water.raw.ecoli)], water.raw.ecoli[,1:4], FUN = sum, na.rm = T)
water.raw.ecoli[water.raw.ecoli == 0] <- NA

# Filter to rows that have value for e. coli
water.raw.ecoli <- filter(water.raw.ecoli, is.na(water.raw.ecoli$`E.coli C-MF.no/100ml`) == F)

# Reorder rows to have e. coli adjacent to identifier columns.
water.raw.ecoli <- water.raw.ecoli[,c(1:4, 7, 5, 6, 8:length(water.raw.ecoli))]

# Export
write.csv(x = water.raw.ecoli, file = "water.raw.ecoli.csv", row.names = F)

# SECTION 3: EXPLORATORY ANALYSIS - conclusion: normal linear models won't be the most effective ----

water.raw.ecoli <- read.csv("water.raw.ecoli.csv", stringsAsFactors = F)

# Conversion: time from character to POSIXct. 
water.raw.ecoli$time %<>%
  as.POSIXct(format = "%Y-%m-%d", tz = "GMT")

# CORRELATIONS BETWEEN PARAMETERS AND E.COLI.
cor.ecoli <- NULL
for(i in 5:length(water.raw.ecoli)){
  assign(x = paste("x", i, sep = "-"), value = cor(x = water.raw.ecoli[i], y = water.raw.ecoli$E.coli.C.MF.no.100ml, use = "complete.obs"))
  cor.ecoli <- rbind(cor.ecoli, get(paste("x", i, sep = "-")))
}
rm(list = ls(pattern = "x-"))
rm(i)
row.names(cor.ecoli) <- colnames(water.raw.ecoli[,5:length(water.raw.ecoli)])

# Linear regression doesn't look promising, going to switch to splitting into groupings. Can perform linear regression later.
  
# E.COLI CORRELATION
# Ammonia vs. e. coli: no correlation
ggplot(water.raw.ecoli, aes(x = `Ammonia.N..mg.l`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# COD vs. e. coli: no correlation
ggplot(water.raw.ecoli, aes(x = `COD.as.O2.mg.l`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Nitrate vs. e. coli: more high e. coli at low nitrate
ggplot(water.raw.ecoli, aes(x = `Nitrate.N.mg.l`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Nitrite vs. e. coli: nearly no correlation
ggplot(water.raw.ecoli, aes(x = `Nitrite.N.mg.l`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Dissolved Oxygen vs. e. coli: no high ecoli after a certain point
ggplot(water.raw.ecoli, aes(x = `O.Diss..sat..`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Dissolved Oxygen 2 vs. e. coli:  no high ecoli after a certain point
ggplot(water.raw.ecoli, aes(x = `Oxygen.Diss.mg.l`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# pH vs. e. coli: high ecoli in a range
ggplot(water.raw.ecoli, aes(x = `pH.phunits`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# salinity vs. e. coli: high e. coli at lower salinity
ggplot(water.raw.ecoli, aes(x = `SALinsitu.ppt`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Solids dissolved vs. e. coli: decreasing e. coli with increasing solids
ggplot(water.raw.ecoli, aes(x = `Sld.Sus.105C.mg.l`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Temp vs. e. coli: high ecoli in a range
ggplot(water.raw.ecoli, aes(x = `Temp.Water.cel`, y = `E.coli.C.MF.no.100ml`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)

# TIME CORRELATION
# checking correlation to time. Both have an increase in summers.
ggplot(water.raw.ecoli, aes(x = time, y = `E.coli.C.MF.no.100ml`)) + geom_point(alpha = 0.2)
ggplot(water.raw.ecoli, aes(x = time, y = `Temp.Water.cel`)) + geom_point(alpha = 0.2)
# High irregularity, promising
ggplot(water.raw.ecoli, aes(x = time, y = `Sld.Sus.105C.mg.l`, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2)
# Almost flatline
ggplot(water.raw.ecoli, aes(x = time, y = `Oxygen.Diss.mg.l`)) + geom_point(alpha = 0.2)
ggplot(water.raw.ecoli, aes(x = time, y = `SALinsitu.ppt`)) + geom_point(alpha = 0.2)

# SECTION 4: TRANSFORMING DATA INTO BINARIES [IN PROGRESS] ----
# Objective: a script that can plug in what quantile of points will be used for modeling and output predictive power, then maximize the predictive power. Each parameter should have its own selection criteria.
# Inland bathing waters are considered poor quality when it is above 900 cfu/100ml e. coli, from the UK Environment Agency (https://environment.data.gov.uk/bwq/profiles/help-understanding-data.html). 

water.raw.ecoli <- read.csv("water.raw.ecoli.csv", stringsAsFactors = F)
water.raw.ecoli$E.coli.C.MF.conform <- water.raw.ecoli$E.coli.C.MF.no.100ml < 900

# plot e. coli and time to verify it's split correctly, color coded.
ggplot(water.raw.ecoli, aes(x = time, y = E.coli.C.MF.no.100ml, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.2) + ylim(low = 0, high = 2000)