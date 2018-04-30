# Import packages and files. Combine 5 year's worth of data, 2013 - 2017.
library(dplyr)
water2013 <- read.csv("2013.csv", stringsAsFactors = F)
water2014 <- read.csv("2014.csv", stringsAsFactors = F)
water2015 <- read.csv("2015.csv", stringsAsFactors = F)
water2016 <- read.csv("2016.csv", stringsAsFactors = F)
water2017 <- read.csv("2017.csv", stringsAsFactors = F)
water.raw <- rbind(water2013, water2014, water2015, water2015, water2016, water2017)

# Remove unnecessary columns to improve processing speed. "X.id" and "sample.samplingPoint" are not useful because their values are URLss. "codedResultInterpretation.interpretation" is not useful because the entire column is empty. "sample.samplingPoint.label" and "samplingPoint.notation" are removed because the names of the locations have too many levels to make any meaningful analysis."determinand.notation" is removed because it's redundant information: it's a numeric code assigned to each type of determinand, which is already given unique names in "determinand.label".

water.raw$X.id <- NULL
water.raw$sample.samplingPoint <- NULL
water.raw$codedResultInterpretation.interpretation <- NULL
water.raw$sample.samplingPoint.notation <- NULL
water.raw$sample.samplingPoint.label <- NULL
water.raw$determinand.notation <- NULL

# Renaming columns  
colnames(water.raw) <- c("time", "determinand.label", "determinand.definition", "resultqualifier", "result", "resultunit", "materialtype", "compliance", "purpose", "easting", "northing")

# Convert time to POSIXct format, cutting off hours, minutes, and seconds.
water.raw$time %>%
  as.POSIXct(format = "%Y-%m-%dT%H:%M:%S") %>%
  substr(1, 10) %>%
  as.POSIXct(format = "%Y-%m-%d", tz = "GMT")

# Conversion to factors
water.raw$determinand.definition <- as.factor(water.raw$determinand.definition)
water.raw$materialtype <- as.factor(water.raw$materialtype)
water.raw$compliance <- as.factor(water.raw$compliance)
water.raw$resultqualifier <- as.factor(water.raw$resultqualifier)

# Filtering data to only the most frequently tested determinands. 
commondeterminandsnames <- names(head(sort(table(water.raw$determinand.label), decreasing = T), 10))
water.clean <- filter(water.raw, match(water.raw$determinand.label, commondeterminandsnames) > 0)
water.clean$determinand.label <- as.factor(water.clean$determinand.label)

# Export
write.csv(x = water.clean, file = "water.clean.csv")