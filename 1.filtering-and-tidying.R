# Import packages and files
library(dplyr)
library(tidyr)
library(magrittr)
water.raw <- read.csv("water.raw.csv", stringsAsFactors = F)

# Filtering data to 5 most common material types
materialswithecoli <- names(head(sort(table(filter(water.raw, water.raw$determinand.label == "E.coli C-MF")$materialtype), decreasing = T), 5))
water.raw.ecoli <- filter(water.raw, match(water.raw$materialtype, materialswithecoli) > 0)

# Filtering data to only the most significant determinands.
ecolideterminands <- c("E.coli C-MF", "Temp Water", "pH", "Oxygen Diss", "Sld Sus@105C", "SALinsitu", "Ammonia(N)", "Nitrite-N", "Nitrate-N", "COD as O2")
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
rm(list=setdiff(ls(), "water.raw.ecoli"))