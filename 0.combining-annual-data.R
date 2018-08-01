# Import and combine 5 year's worth of data, 2013 - 2017.
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
