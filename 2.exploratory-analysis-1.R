# Import files and packages
library(ggplot2)
water.raw.ecoli <- read.csv("water.raw.ecoli.csv", stringsAsFactors = F)
water.raw.ecoli$time <- as.POSIXct(water.raw.ecoli$time, format = "%Y-%m-%d", tz = "GMT")

# CORRELATIONS BETWEEN PARAMETERS AND E.COLI - conclusion: normal linear models won't be the most effective
cor.ecoli <- NULL
for(i in 5:length(water.raw.ecoli)){
  assign(x = paste("x", i, sep = "-"), value = cor(x = water.raw.ecoli[i], y = water.raw.ecoli$E.coli.C.MF.no.100ml, use = "complete.obs"))
  cor.ecoli <- rbind(cor.ecoli, get(paste("x", i, sep = "-")))
}
rm(list = ls(pattern = "x-"))
rm(i)
row.names(cor.ecoli) <- colnames(water.raw.ecoli[,5:length(water.raw.ecoli)])

# E.COLI CORRELATIONS
# Ammonia vs. e. coli: no correlation
ggplot(water.raw.ecoli, aes(x = `Ammonia.N..mg.l`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# COD vs. e. coli: no correlation
ggplot(water.raw.ecoli, aes(x = `COD.as.O2.mg.l`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# Nitrate vs. e. coli: more high e. coli at low nitrate
ggplot(water.raw.ecoli, aes(x = `Nitrate.N.mg.l`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# Nitrite vs. e. coli: nearly no correlation
ggplot(water.raw.ecoli, aes(x = `Nitrite.N.mg.l`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# Dissolved Oxygen 2 vs. e. coli:  no high ecoli after a certain point
ggplot(water.raw.ecoli, aes(x = `Oxygen.Diss.mg.l`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# pH vs. e. coli: high ecoli in a range
ggplot(water.raw.ecoli, aes(x = `pH.phunits`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# salinity vs. e. coli: high e. coli at lower salinity
ggplot(water.raw.ecoli, aes(x = `SALinsitu.ppt`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# Solids dissolved vs. e. coli: decreasing e. coli with increasing solids
ggplot(water.raw.ecoli, aes(x = `Sld.Sus.105C.mg.l`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)
# Temp vs. e. coli: high ecoli in a range
ggplot(water.raw.ecoli, aes(x = `Temp.Water.cel`, y = `E.coli.C.MF.no.100ml`, color = materialtype)) + geom_point(alpha = 0.2)

# TIME CORRELATIONS
# checking correlation to time. Both have an increase in summers.
ggplot(water.raw.ecoli, aes(x = time, y = `E.coli.C.MF.no.100ml`)) + geom_point(alpha = 0.2)
ggplot(water.raw.ecoli, aes(x = time, y = `Temp.Water.cel`)) + geom_point(alpha = 0.2)
# High irregularity, promising
ggplot(water.raw.ecoli, aes(x = time, y = `Sld.Sus.105C.mg.l`, color = materialtype)) + geom_point(alpha = 0.2)
# Almost flatline
ggplot(water.raw.ecoli, aes(x = time, y = `Oxygen.Diss.mg.l`)) + geom_point(alpha = 0.2)
ggplot(water.raw.ecoli, aes(x = time, y = `SALinsitu.ppt`)) + geom_point(alpha = 0.2)