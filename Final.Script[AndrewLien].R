# COMBINING DATA

## Loading packages.
library(dplyr)
library(tidyr)
library(magrittr)
library(ggplot2)
library(scales)
library(RColorBrewer)
library(caTools)
library(ROCR)
library(effects)

## Import and combine 5 year's worth of data, 2013 - 2017.
water2013 <- read.csv("2013.csv", stringsAsFactors = F)
water2014 <- read.csv("2014.csv", stringsAsFactors = F)
water2015 <- read.csv("2015.csv", stringsAsFactors = F)
water2016 <- read.csv("2016.csv", stringsAsFactors = F)
water2017 <- read.csv("2017.csv", stringsAsFactors = F)
water.raw <- rbind(water2013, water2014, water2015, water2015, water2016, water2017)
rm(list=setdiff(ls(), "water.raw"))

## Remove unnecessary columns to improve processing speed. "sample.samplingPoint" is not useful because their values are URLs (X.id retained as a unique identifier for each row). "codedResultInterpretation.interpretation" is not useful because the entire column is empty. "sample.samplingPoint.label" and "samplingPoint.notation" are removed because the names of the locations have too many levels to make any meaningful analysis."determinand.notation" is removed because it's redundant information: it's a numeric code assigned to each type of determinand, which is already given unique names in "determinand.label". Results with a descriptive qualifier are treated as equivalent to their numerical value. "sample.isComplianceSample" is not of interest. "X.id" is arbitrary and will be reintroduced later to spread columns.
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
## Renaming columns  
colnames(water.raw) <- c("time", "determinand.label", "result", "resultunit", "materialtype", "easting", "northing")

## Export
write.csv(x = water.raw, file = "water.raw.csv", row.names = FALSE)

# FILTERING AND TIDYING

## Filtering


water.ecoli <- filter(water.raw, water.raw$materialtype == "RIVER / RUNNING SURFACE WATER" | water.raw$materialtype == "SEA WATER" | water.raw$materialtype == "ESTUARINE WATER" | water.raw$materialtype == "POND / LAKE / RESERVOIR WATER")
water.ecoli$materialtype %<>% as.factor()

significantdeterminands <- c("Temp Water", "pH", "Nitrite-N", "Orthophospht", "O Diss %sat", "Nitrate-N", "Oxygen Diss", "E.coli C-MF", "SALinsitu", "Cu Filtered", "BOD ATU", "Cu Filtered", "Ni- Filtered", "Bathers 100m", "Beach Users")

water.ecoli <- filter(water.ecoli, match(water.ecoli$determinand.label, significantdeterminands) > 0)

## Spread() and Aggregate()

water.ecoli$determinand.label %<>% as.factor()
water.ecoli$resultunit %<>% as.factor()
water.ecoli$id <- 1:nrow(water.ecoli)
water.ecoli <- spread(water.ecoli, key = determinand.label, value = result)
water.ecoli$id <- NULL

water.ecoli <- unique(water.ecoli)

for (i in 6:length(water.ecoli)) {
  position <- grep(x = is.na(water.ecoli[,i]), pattern = FALSE)[1]
  unit <- water.ecoli[position, "resultunit"]
  colnames(water.ecoli)[i] <- paste(colnames(water.ecoli)[i], unit, sep = ".")
}
water.ecoli$resultunit <- NULL

water.ecoli <- aggregate(water.ecoli[,5:length(water.ecoli)], water.ecoli[,1:4], FUN = sum, na.rm = T)
water.ecoli[water.ecoli == 0] <- NA

water.ecoli <- filter(water.ecoli, is.na(water.ecoli$`E.coli C-MF.no/100ml`) == F)

## Adding column to identify which coloumn are above/below the safety level of 900 cfu/100ml.

water.ecoli$E.coli.C.MF.conform <- water.ecoli$`E.coli C-MF.no/100ml` < 900
write.csv(x = water.ecoli, file = "water.ecoli.csv", row.names = F)

# EXPLORATORY ANALYSIS

water.ecoli <- read.csv("water.ecoli.csv", stringsAsFactors = F)

## Correlation Matrix

cor.table <- cor(water.ecoli[,5:length(water.ecoli)], use = "pairwise.complete.obs")
cor.table <- as.data.frame(cbind(rownames(cor.table), cor.table))
cor.table <- gather(cor.table, key = "V2", value = "cor.value", 2:length(cor.table))
cor.table$cor.value %<>% as.numeric()
ggplot(cor.table, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = cor.value), color = "white") +
  scale_fill_gradient(low = "white", high = "black") +
  ggtitle("Correlation Heat Map") +
  xlab("Determinand1") +
  ylab("Determinand2") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

## Correlated Variables

### Oxygen.Diss.mg.l and O.Diss..sat..
ggplot(water.ecoli, aes(x = Oxygen.Diss.mg.l, y = O.Diss..sat.., color = E.coli.C.MF.conform)) +
  geom_point(alpha = 0.2) +
  facet_wrap(~materialtype, scales = "free")

### Oxygen.Diss.mg.l and Temp.Water.cel
ggplot(water.ecoli, aes(x = Temp.Water.cel, y = Oxygen.Diss.mg.l, color = E.coli.C.MF.conform)) +
  geom_point(alpha = 0.2) +
  facet_wrap(~materialtype, scales = "free")

### SALinsitu.ppt and Cu.Filtered.ug.l
ggplot(water.ecoli, aes(x = SALinsitu.ppt, y = Cu.Filtered.ug.l, color = E.coli.C.MF.conform)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~materialtype, scales = "free")

### Removing Correlated Variables
water.ecoli$O.Diss..sat.. <- NULL

## Testing Frequencies
frequencytable <- aggregate(x = is.na(select(water.ecoli, c(5:18))) == F, by = select(water.ecoli, 2), FUN = sum)
frequencytable <- t(frequencytable)
colnames(frequencytable) <- frequencytable[1,]
frequencytable <- as.data.frame(frequencytable[-1,])
frequencytable <- cbind(rownames(frequencytable), frequencytable)
colnames(frequencytable)[1] <- "determinand"
frequencytable <- gather(frequencytable, key = "materialtype", value = "count", 2:5)
frequencytable$materialtype %<>% as.factor()
frequencytable$count %<>% as.numeric()

ggplot(frequencytable, aes(x = materialtype, y = count, fill = determinand)) + 
  geom_bar(position = "fill", stat = "identity") +
  scale_fill_manual(values = colorRampPalette(brewer.pal(9, "Set1"))(length(unique(frequencytable$determinand)))) +
  scale_y_continuous(label = percent) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

## Investigating Relationships to E. Coli

### Water.Temp.cel
water.ecoli.Temp <- select(filter(water.ecoli, is.na(water.ecoli$Temp.Water.cel) == 0), c(1:4, "E.coli.C.MF.no.100ml", "Temp.Water.cel", "E.coli.C.MF.conform"))
water.ecoli.Temp <- cbind(water.ecoli.Temp, cut(water.ecoli.Temp$Temp.Water.cel, 30))
colnames(water.ecoli.Temp)[8] <- "bin"
ggplot(water.ecoli.Temp, aes(x = bin)) +
  geom_bar(aes(fill = factor(E.coli.C.MF.conform)), width = 0.9, stat = "count", position = "dodge") +
  scale_color_discrete(name = "conforms", breaks = c(T, F), labels = c("True", "False")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ materialtype, scales = "free") +
  ggtitle("E. Coli Conformance count and Water Temperature")

### pH
water.ecoli.pH <- select(filter(water.ecoli, is.na(water.ecoli$pH.phunits) == 0), c(1:4, "E.coli.C.MF.no.100ml", "pH.phunits", "E.coli.C.MF.conform"))
water.ecoli.pH <- cbind(water.ecoli.pH, cut(water.ecoli.pH$pH.phunits, 30))
colnames(water.ecoli.pH)[8] <- "bin"
ggplot(water.ecoli.pH, aes(x = bin)) +
  geom_bar(aes(fill = factor(E.coli.C.MF.conform)), width = 0.9, stat = "count", position = "dodge") +
  scale_color_discrete(name = "conforms", breaks = c(T, F), labels = c("True", "False")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ materialtype, scales = "free") +
  ggtitle("E. Coli Conformance count and pH")

### Dissolved Oxygen
water.ecoli.oxygen.diss <- select(filter(water.ecoli, is.na(water.ecoli$Oxygen.Diss.mg.l) == 0), c(1:4, "E.coli.C.MF.no.100ml", "Oxygen.Diss.mg.l", "E.coli.C.MF.conform"))
water.ecoli.oxygen.diss <- cbind(water.ecoli.oxygen.diss, cut(water.ecoli.oxygen.diss$Oxygen.Diss.mg.l, 30))
colnames(water.ecoli.oxygen.diss)[8] <- "bin"
ggplot(water.ecoli.oxygen.diss, aes(x = bin)) +
  geom_bar(aes(fill = factor(E.coli.C.MF.conform)), width = 0.9, stat = "count", position = "dodge") +
  scale_color_discrete(name = "conforms", breaks = c(T, F), labels = c("True", "False")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ materialtype, scales = "free") +
  ggtitle("E. Coli Conformance count and Dissolved Oxygen")

## Investigating Relationships to Location
ggplot(water.ecoli, aes(x = easting, y = northing, color = materialtype)) +
  geom_point(alpha = 0.2)

## Investigating Relationships to Time

### Temp.Water.cel
ggplot(water.ecoli, aes(x = time, y = Temp.Water.cel, color = E.coli.C.MF.conform)) +
  geom_point(alpha = 0.2)

### BOD ATU
ggplot(water.ecoli, aes(x = time, y = BOD.ATU.mg.l, color = E.coli.C.MF.conform)) +
  geom_point(alpha = 0.2)

# MODELING

water.ecoli <- read.csv("water.ecoli.csv", stringsAsFactors = F)
water.ecoli$materialtype %<>% as.factor()
water.ecoli$time %<>% as.POSIXct(format = "%Y-%m-%dT%H:%M:%S")
water.ecoli$O.Diss..sat.. <- NULL

## Feature Engineering

### Time to Seasons
water.ecoli$season <- substr(water.ecoli$time, 6, 7)
water.ecoli$season <- gsub(pattern = "09|10|11", replacement = "fall", x = water.ecoli$season)
water.ecoli$season <- gsub(pattern = "12|01|02", replacement = "winter", x = water.ecoli$season)
water.ecoli$season <- gsub(pattern = "03|04|05", replacement = "spring", x = water.ecoli$season)
water.ecoli$season <- gsub(pattern = "06|07|08", replacement = "summer", x = water.ecoli$season)

### pH to pH.ecolirange
ggplot(water.ecoli, aes(x = pH.phunits,  y = E.coli.C.MF.no.100ml, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.3)
nonconform.pH <- filter(water.ecoli, is.na(water.ecoli$pH.phunits) == F & water.ecoli$E.coli.C.MF.conform == F)
nonconform.pH.mean <- mean(nonconform.pH$pH.phunits)
nonconform.pH.sd <- sd(nonconform.pH$pH.phunits)
water.ecoli$pH.ecolirange <- ifelse(water.ecoli$pH.phunits < nonconform.pH.mean + 2*nonconform.pH.sd & water.ecoli$pH.phunits > nonconform.pH.mean - 2*nonconform.pH.sd, T, F)

### Temp to temp.ecolirange
ggplot(water.ecoli, aes(x = Temp.Water.cel,  y = E.coli.C.MF.no.100ml, color = E.coli.C.MF.conform)) + geom_point(alpha = 0.3)
nonconform.temp <- filter(water.ecoli, is.na(water.ecoli$Temp.Water.cel) == F & water.ecoli$E.coli.C.MF.conform == F)
nonconform.temp.mean <- median(nonconform.temp$Temp.Water.cel)
nonconform.temp.sd <- sd(nonconform.temp$Temp.Water.cel)
water.ecoli$temp.ecolirange <- ifelse(water.ecoli$Temp.Water.cel < nonconform.temp.mean + 2*nonconform.temp.sd & water.ecoli$Temp.Water.cel > nonconform.temp.mean - 2*nonconform.temp.sd, T, F)

### Normalization
mean <- mapply(water.ecoli[,7:17], FUN = "mean", na.rm = T)
stdev <- mapply(water.ecoli[,7:17], FUN = "sd", na.rm = T)
water.ecoli[,7:17] %<>% sweep(., 2, FUN = "-", mean) %>% sweep(., 2, FUN = "/", stdev)

### Splitting Data set into Testing and Training sets
set.seed(123)
split.labels <- sample.split(Y = water.ecoli[,1], SplitRatio = 1/2)
data.train <- subset(water.ecoli, split.labels == T)
data.test <- subset(water.ecoli, split.labels == F)

## Model0 [baseline model, using Zero Rule Algorihm]

### Confusion Matrix
summary(data.test$E.coli.C.MF.conform)

### Metrics
testsize0 <- 30366 + 8360
AUC0 <- 0
sensitivity0 <- 30366/(30366 + 0) # TP/(TP + FN)
falsepositive0 <- 8360/(8360 + 0)
f1score0 <-  2*30366/(2*30366 + 8360 + 0) # 2*TP/(2*TP + FP + FN)
accuracy0 <- 30366/(30366+8360) # (TP + TN)/total

## Model1 [SALinsitu.ppt + Oxygen.Diss.mg.l]

### Creating model1
data.train1 <- filter(data.train, is.na(data.train$SALinsitu.ppt) == F & is.na(data.train$Oxygen.Diss.mg.l) == F)
model1 <- glm(E.coli.C.MF.conform ~ SALinsitu.ppt + Oxygen.Diss.mg.l, data = data.train1, family = "binomial")
summary(model1)

### ROC Curve
data.test1 <- filter(data.test, is.na(data.test$SALinsitu.ppt) == F & is.na(data.test$Oxygen.Diss.mg.l) == F)
testsize1 <- nrow(data.test1)
train.predict1 <- predict(model1, type = "response", newdata = data.test1)

ROCR.pred1 <- prediction(train.predict1, data.test1$E.coli.C.MF.conform)
ROCR.perf1 <- performance(ROCR.pred1, "tpr", "fpr")
plot(ROCR.perf1, colorize = TRUE, print.cutoffs.at = seq(0, 1, 0.1), text.adj = c(-0.2, 1.7))

AUC1 <- performance(ROCR.pred1, "auc")
AUC1 <- as.numeric(AUC1@y.values)

### Confusion Matrix and metrics
confusionmatrix1<- table(data.test1$E.coli.C.MF.conform, train.predict1 > 0.7)
confusionmatrix1
sensitivity1 <- confusionmatrix1[2,2]/(confusionmatrix1[2,2] + confusionmatrix1[2,1])
accuracy1 <- (confusionmatrix1[1,1] + confusionmatrix1[2,2])/sum(confusionmatrix1)
falsepositive1 <- confusionmatrix1[1,2]/(confusionmatrix1[1,2] + confusionmatrix1[1,1])
precision1 <- confusionmatrix1[2,2]/(confusionmatrix1[2,2] + confusionmatrix1[2,1])
recall1 <- confusionmatrix1[2,2]/(confusionmatrix1[2,2] + confusionmatrix1[1,2])
f1score1 <- 2/(1/recall1 + 1/precision1)

## Model2 [SALinsitu.ppt + Oxygen.Diss.mg.l*season]

### Creating model2
data.train2 <- filter(data.train, is.na(data.train$SALinsitu.ppt) == F & is.na(data.train$Oxygen.Diss.mg.l) == F)
model2 <- glm(E.coli.C.MF.conform ~ SALinsitu.ppt + Oxygen.Diss.mg.l*season, data = data.train2, family = "binomial")
summary(model2)

### ROC Curve
data.test2 <- filter(data.test, is.na(data.test$SALinsitu.ppt) == F & is.na(data.test$Oxygen.Diss.mg.l) == F & is.na(data.test$season) == F)
testsize2 <- nrow(data.test2)
train.predict2 <- predict(model2, type = "response", newdata = data.test2)
ROCR.pred2 <- prediction(train.predict2, data.test2$E.coli.C.MF.conform)
ROCR.perf2 <- performance(ROCR.pred2, "tpr", "fpr")
plot(ROCR.perf2, colorize = TRUE, print.cutoffs.at = seq(0, 1, 0.1), text.adj
     = c(-0.2, 1.7))
AUC2 <- performance(ROCR.pred2, "auc")
AUC2 <- as.numeric(AUC2@y.values)

### Confusion Matrix and metrics
confusionmatrix2<- table(data.test2$E.coli.C.MF.conform, train.predict2 > 0.7)
confusionmatrix2
sensitivity2 <- confusionmatrix2[2,2]/(confusionmatrix2[2,2] + confusionmatrix2[2,1])
accuracy2 <- (confusionmatrix2[1,1] + confusionmatrix2[2,2])/sum(confusionmatrix2)
precision2 <- confusionmatrix2[2,2]/(confusionmatrix2[2,2] + confusionmatrix2[2,1])
recall2 <- confusionmatrix2[2,2]/(confusionmatrix2[2,2] + confusionmatrix2[1,2])
f1score2 <- 2/(1/recall2 + 1/precision2)
falsepositive2 <- confusionmatrix2[1,2]/(confusionmatrix2[1,2] + confusionmatrix2[1,1])

## model3 [SALinsitu.ppt + Oxygen.Diss.mg.l + pH.ecolirange + temp.ecolirange]

### Creating model3
data.train3 <- filter(data.train, is.na(data.train$SALinsitu.ppt) == F & is.na(data.train$Oxygen.Diss.mg.l) == F & is.na(data.train$pH.ecolirange) == F & is.na(data.train$temp.ecolirange) == F)
model3 <- glm(E.coli.C.MF.conform ~ SALinsitu.ppt + Oxygen.Diss.mg.l + pH.ecolirange + temp.ecolirange, data = data.train3, family = "binomial")
summary(model3)

### ROC Curve
data.test3 <- filter(data.test, is.na(data.test$SALinsitu.ppt) == F & is.na(data.test$Oxygen.Diss.mg.l) == F & is.na(data.test$pH.ecolirange) == F & is.na(data.test$temp.ecolirange) == F)
testsize3 <- nrow(data.test3)
train.predict3 <- predict(model3, type = "response", newdata = data.test3)
ROCR.pred3 <- prediction(train.predict3, data.test3$E.coli.C.MF.conform)
ROCR.perf3 <- performance(ROCR.pred3, "tpr", "fpr")
plot(ROCR.perf3, colorize = TRUE, print.cutoffs.at = seq(0, 1, 0.1), text.adj
     = c(-0.2, 1.7))
AUC3 <- performance(ROCR.pred3, "auc")
AUC3 <- as.numeric(AUC3@y.values)

### Confusion matrix and metrics
confusionmatrix3<- table(data.test3$E.coli.C.MF.conform, train.predict3 > 0.7)
confusionmatrix3
sensitivity3 <- confusionmatrix3[2,2]/(confusionmatrix3[2,2] + confusionmatrix3[2,1])
accuracy3 <- (confusionmatrix3[1,1] + confusionmatrix3[2,2])/sum(confusionmatrix3)
precision3 <- confusionmatrix3[2,2]/(confusionmatrix3[2,2] + confusionmatrix3[2,1])
recall3 <- confusionmatrix3[2,2]/(confusionmatrix3[2,2] + confusionmatrix3[1,2])
f1score3 <- 2/(1/recall3 + 1/precision3)
falsepositive3 <- confusionmatrix3[1,2]/(confusionmatrix3[1,2] + confusionmatrix3[1,1])

## model4 [SALinsitu.ppt]

### Creating model4
data.train4 <- filter(data.train, is.na(data.train$SALinsitu.ppt) == F)
model4 <- glm(E.coli.C.MF.conform ~ SALinsitu.ppt, data = data.train4, family = "binomial")
summary(model4)

### ROC Curve
data.test4 <- filter(data.test, is.na(data.test$SALinsitu.ppt) == F)
testsize4 <- nrow(data.test4)
train.predict4 <- predict(model4, type = "response", newdata = data.test4)
ROCR.pred4 <- prediction(train.predict4, data.test4$E.coli.C.MF.conform)
ROCR.perf4 <- performance(ROCR.pred4, "tpr", "fpr")
plot(ROCR.perf4, colorize = TRUE, print.cutoffs.at = seq(0, 1, 0.1), text.adj
     = c(-0.2, 1.7))
AUC4 <- performance(ROCR.pred4, "auc")
AUC4 <- as.numeric(AUC4@y.values)

### Confusion matrix and metrics
confusionmatrix4<- table(data.test4$E.coli.C.MF.conform, train.predict4 > 0.9)
confusionmatrix4
sensitivity4 <- confusionmatrix4[2,2]/(confusionmatrix4[2,2] + confusionmatrix4[2,1])
accuracy4 <- (confusionmatrix4[1,1] + confusionmatrix4[2,2])/sum(confusionmatrix4)
precision4 <- confusionmatrix4[2,2]/(confusionmatrix4[2,2] + confusionmatrix4[2,1])
recall4 <- confusionmatrix4[2,2]/(confusionmatrix4[2,2] + confusionmatrix4[1,2])
f1score4 <- 2/(1/recall4 + 1/precision4)
falsepositive4 <- confusionmatrix4[1,2]/(confusionmatrix4[1,2] + confusionmatrix4[1,1])

# RESULTS

parameter <- c("test size", "AUC of ROC", "sensitivity", "falsepositive", "f1score", "accuracy")
modelresults0 <- c(testsize0, AUC0, sensitivity0, falsepositive0, f1score0, accuracy0)
modelresults1 <- c(testsize1, AUC1, sensitivity1, falsepositive1, f1score1, accuracy1)
modelresults2 <- c(testsize2, AUC2, sensitivity2, falsepositive2, f1score2, accuracy2)
modelresults3 <- c(testsize3, AUC3, sensitivity3, falsepositive3, f1score3, accuracy3)
modelresults4 <- c(testsize4, AUC4, sensitivity4, falsepositive4, f1score4, accuracy4)
comparison <- as.data.frame(rbind(modelresults0, modelresults1, modelresults2, modelresults3, modelresults4))
colnames(comparison) <- parameter
rownames(comparison) <- c("model0", "model1", "model2", "model3", "model4")
comparison

# Model1 is the best model.




