### Data Set 1: Biomedical Data

## Read Data
nordata = read.table("normals.txt", header=TRUE)
cardata = read.table("carriers.txt", header=TRUE)

## Binding Data
posdiagnosis = cbind(cardata, rep("positive", nrow(cardata)))
negdiagnosis = cbind(nordata, rep("negative", nrow(nordata)))
colnames(posdiagnosis)[7] <- "diagnosis"
colnames(negdiagnosis)[7] <- "diagnosis"
alldata = rbind(posdiagnosis, negdiagnosis)

# Converting dates into number of days since 1977-12-31
days = alldata[,2]
days = gsub("\\s", "0", format(days, width=max(nchar(days))))
days = paste("19", substr(days,5,6), "-", substr(days,1,2), "-15", sep="") 
days = as.Date(days)
days = as.numeric(difftime(days, "1977-12-31"))
alldata[,2] = days

## Exploratory Analysis with PCA
pca = prcomp(alldata[,1:6])
pcabiplot = biplot(pca, cex=0.6, main="Unscaled Biplot of PC1 against PC2")

pcas = prcomp(alldata[,1:6], scale=TRUE)
pcasbiplot = biplot(pcas, cex=0.6, main="Scaled Biplot of PC1 against PC2")

## Plots
plot(pca$x[,1], pca$x[,2], xlab = "PC1", ylab = "PC2", main="Unscaled Scores Plot for PC1 against PC2", pch = 20, col="blue")
points(pca$x[1:67,1], pca$x[1:67,2], pch=20, col="red")
legend("bottomleft", legend = c("Positive","Negative"), pch = 20, cex=0.9, col = c("red","blue"))

plot(pcas$x[,1], pcas$x[,2], xlab = "PC1", ylab = "PC2", main="Scaled Scores Plot for PC1 against PC2", pch = 20, col="blue")
points(pcas$x[1:67,1], pcas$x[1:67,2], pch=20, col="red")
legend("bottomright", legend = c("Positive","Negative"), pch = 20, cex=0.9, col = c("red","blue"))

plot(pcas)
summary(pcas)
boxplot(alldata[1:6])
pcas$rotation

## Investigating the relationship between date and measurements
# Plots
par(mfrow=c(2,2))
# M1
plot(alldata[,2], alldata[,3], xlab = "Days", ylab = "m1", main="", pch = 20, col="blue", cex=1)
abline(lm(alldata[,3]~alldata[,2]), col="black")
# M2
plot(alldata[,2], alldata[,4], xlab = "Days", ylab = "m2", main="", pch = 20, col="orange", cex=1)
abline(lm(alldata[,4]~alldata[,2]), col="black")
# M3
plot(alldata[,2], alldata[,5], xlab = "Days", ylab = "m3", main="", pch = 20, col="purple", cex=1)
abline(lm(alldata[,5]~alldata[,2]), col="black")
# M4
plot(alldata[,2], alldata[,6], xlab = "Days", ylab = "m4", main="", pch = 20, col="green", cex=1)
abline(lm(alldata[,6]~alldata[,2]), col="black")
mtext("Relationship between measurements and number of days after 31-12-1997 blood sample is taken", side = 3, line = -2, outer = TRUE)


## Investigating the relationship between age and measurements  
# M1
plot(alldata[,1], alldata[,3], xlab = "Age", ylab = "m1", main="", pch = 20, col="blue", cex=1)
abline(lm(alldata[,3]~alldata[,1]), col="black")
# M2
plot(alldata[,1], alldata[,4], xlab = "Age", ylab = "m2", main="", pch = 20, col="orange", cex=1)
abline(lm(alldata[,4]~alldata[,1]), col="black")
# M3
plot(alldata[,1], alldata[,5], xlab = "Age", ylab = "m3", main="", pch = 20, col="purple", cex=1)
abline(lm(alldata[,5]~alldata[,1]), col="black")
# M4
plot(alldata[,1], alldata[,6], xlab = "Age", ylab = "m4", main="", pch = 20, col="green", cex=1)
abline(lm(alldata[,6]~alldata[,1]), col="black")
mtext("Relationship between measurements and age of patient", side = 3, line = -2, outer = TRUE)


## Preparing data for classifiers
# Splitting data into training and test, 70% and 30% resp.
n = nrow(alldata)
trainIndex = sample(1:n, size=round(0.7*n), replace=FALSE)
train = alldata[trainIndex,]
test = alldata[-trainIndex,]

## Performing classifier models
# LDA
library(MASS)
ldamodel = lda(train[,1:6], train[,7])

ldatrain = predict(ldamodel, train[,1:6])
real = train[,7]
table(predicted=ldatrain$class, real=real)
accuracy=(87+35)/dim(train)[1]
accuracy
#90.0%
ldatest = predict(ldamodel, test[,1:6])
real = test[,7]
table(predicted=ldatest$class, real=real)
accuracy = (37+15)/dim(test)[1]
accuracy
#90.0%

# Naive Bayes
library(naivebayes)
nbmodel = naive_bayes(train[,1:6], train[,7], usekernel=T)

nbtrain = predict(nbmodel,train[,1:6])
real = train[,7]
table(predicted=nbtrain, real=real)
accuracy = (87+39)/dim(train)[1]
accuracy
#92.6%
nbtest = predict(nbmodel, test[,1:6])
real = test[,7]
table(predicted=nbtest, real=real)
accuracy = (37+16)/dim(test)[1]
accuracy
#91.4%

#QDA
qdamodel = qda(train[,1:6],train[,7])

qdatrain = predict(qdamodel,train[,1:6])
table(predicted = qdatrain$class, real=train[,7])
accuracy = (88+36)/dim(train)[1]
accuracy
#91.2%
qdatest = predict(qdamodel,test[,1:6])
table(predicted=qdatest$class, real=test[,7])
accuracy = (37+16)/dim(test)[1]
accuracy
#91.4%

### Comparing Classifiers using ROC curve
library(pROC)
library (ROCR)

## Test data
real = test[,7]
# LDA AUC
auc_lda = roc((real), as.numeric(ldatest$class))
# Naive Bayes AUC (test)
auc_nb = roc(real, as.numeric(nbtest))
#QDA AUC (test)
auc_qda=roc(real, as.numeric(qdatest$class))

## Training data
real = train[,7]
# LDA AUC
auc_lda = roc(real, as.numeric(ldatrain$class))
# Naive Bayes AUC
auc_nb = roc(real, as.numeric(nbtrain))
#QDA AUC
auc_qda = roc(real, as.numeric(qdatrain$class))


#ROC CURVES FOR TRAIN
#NB
pred_nb = predict(nbmodel, train[,1:6], type="prob")
rates_nb = prediction(pred_nb[,2], train[,7])
perf_nb = performance(rates_nb, "tpr", "fpr")

#LDA
pred_lda = predict(ldamodel, train[,1:6], type = "prob")
rates_lda = prediction(pred_lda$posterior[,2], train[,7])
perf_lda = performance(rates_lda, "tpr", "fpr")

#QDA
pred_qda = predict(qdamodel, train[,1:6], type = "prob")
rates_qda = prediction(pred_qda$posterior[,2], train[,7])
perf_qda = performance(rates_qda, "tpr", "fpr")

#together
par(mfrow=c(1,1))
plot(perf_nb,col = "red", lty=1, main ="ROC Curve Comparison of Naive Bayes, LDA and QDA")
plot(perf_lda, col= "blue", add=TRUE, lty=2)
plot(perf_qda, col="green", add=TRUE, lty=3)
legend("bottomright", inset = 0.05,
       legend = c("Naive Bayes", "LDA","QDA"),
       col=c("red", "blue","green"), lty = 1:2, text.font=2,cex=0.6)


#ROC CURVES FOR TEST
## Test data
real = test[,7]
# LDA AUC
auc_lda = roc(real, as.numeric(ldatest$class))
# Naive Bayes AUC
auc_nb = roc(real, as.numeric(nbttest))
#QDA AUC
auc_qda = roc(real, as.numeric(qdatest$class))


#NB
pred_nb = predict(nbmodel, test[,1:6], type="prob")
rates_nb = prediction(pred_nb[,2], as.factor(test[,7]))
perf_nb = performance(rates_nb, "tpr", "fpr")

#LDA
pred_lda = predict(ldamodel, test[,1:6], type = "prob")
rates_lda = prediction(pred_lda$posterior[,2], test[,7])
perf_lda = performance(rates_lda, "tpr", "fpr")

#QDA
pred_qda = predict(qdamodel, test[,1:6], type = "prob")
rates_qda = prediction(pred_qda$posterior[,2], test[,7])
perf_qda = performance(rates_qda, "tpr", "fpr")

#together
plot(perf_nb,col = "red", lty=1, main ="ROC Curve Comparison of Naive Bayes, LDA and QDA")
plot(perf_lda, col= "blue", add=TRUE, lty=2)
plot(perf_qda, col="green", add=TRUE, lty=3)
legend("bottomright", inset = 0.05,
       legend = c("Naive Bayes", "LDA","QDA"),
       col=c("red", "blue","green"), lty = 1:2, text.font=2,cex=0.6)






# Testing different combinations of measurements

library(naivebayes)

# all m - 92.6% [training],  91.4% [test]
nbmodel = naive_bayes(train[,1:6], train[,7], usekernel=T)
nbtrain = predict(nbmodel, train[,1:6])
real = train[,7]
table(predicted=nbtrain, real=real)
accuracy = (87+39)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:6])
real = test[,7]
table(predicted=nbtest, real=real)
accuracy = (37+16)/dim(test)[1]
accuracy

# m1 - 89.7% [training], 86.2% [test]
nbmodel = naive_bayes(train[,1:3], train[,7], usekernel=T)
nbtrain = predict(nbmodel,train[,1:3])
real = train[,7]
table(predicted=nbtrain, real=real)
accuracy = (88+34)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:3])
real = test[,7]
table(predicted=nbtest, real=real)
accuracy = (37+13)/dim(test)[1]
accuracy

# m2 - 80.9% [training],  70.7% [test]
alldata2 = alldata[,-3]
alldata2 = alldata2[,-4]
alldata2 = alldata2[,-4]
train = alldata2[trainIndex,]
test = alldata2[-trainIndex,]

nbmodel = naive_bayes(train[,1:3], train[,4], usekernel=T)
nbtrain = predict(nbmodel,train[,1:3])
real = train[,4]
table(predicted=nbtrain, real=real)
accuracy = (79+31)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:3])
real = test[,4]
table(predicted=nbtest, real=real)
accuracy = (31+10)/dim(test)[1]
accuracy

#m3 88.2% [training], 84.5% [test]
alldata3 = alldata[,-3]
alldata3 = alldata3[,-3]
alldata3 = alldata3[,-4]
train = alldata3[trainIndex,]
test = alldata3[-trainIndex,]

nbmodel = naive_bayes(train[,1:3], train[,4], usekernel=T)
nbtrain = predict(nbmodel,train[,1:3])
real = train[,4]
table(predicted=nbtrain, real=real)
accuracy = (88+32)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:3])
real = test[,4]
table(predicted=nbtest, real=real)
accuracy = (37+12)/dim(test)[1]
accuracy

#m4 89.0% [training], 84.4% [test]
alldata4 = alldata[,-3]
alldata4 = alldata4[,-3]
alldata4 = alldata4[,-3]
train = alldata4[trainIndex,]
test = alldata4[-trainIndex,]

nbmodel = naive_bayes(train[,1:3], train[,4], usekernel=T)
nbtrain = predict(nbmodel,train[,1:3])
real = train[,4]
table(predicted=nbtrain, real=real)
accuracy = (87+34)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:3])
real = test[,4]
table(predicted=nbtest, real=real)
accuracy = (36+13)/dim(test)[1]
accuracy

#m1&m2 91.2% [training], 86.2% [test]
alldata12 = alldata[,-5]
alldata12 = alldata12[,-5]
train = alldata12[trainIndex,]
test = alldata12[-trainIndex,]

nbmodel = naive_bayes(train[,1:4], train[,5], usekernel=T)
nbtrain = predict(nbmodel,train[,1:4])
real = train[,5]
table(predicted=nbtrain, real=real)
accuracy = (89+35)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:4])
real = test[,5]
table(predicted=nbtest, real=real)
accuracy = (37+13)/dim(test)[1]
accuracy

#m1&m3 90.4% [training], 86.2% [test]
alldata13 = alldata[,-4]
alldata13 = alldata13[,-5]
train = alldata13[trainIndex,]
test = alldata13[-trainIndex,]

nbmodel = naive_bayes(train[,1:4], train[,5], usekernel=T)
nbtrain = predict(nbmodel,train[,1:4])
real = train[,5]
table(predicted=nbtrain, real=real)
accuracy = (88+35)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:4])
real = test[,5]
table(predicted=nbtest, real=real)
accuracy = (37+13)/dim(test)[1]
accuracy

#m1&m4 91.2% [training], 88.0% [test]
alldata14 = alldata[,-4]
alldata14 = alldata14[,-4]
train = alldata14[trainIndex,]
test = alldata14[-trainIndex,]

nbmodel = naive_bayes(train[,1:4], train[,5], usekernel=T)
nbtrain = predict(nbmodel,train[,1:4])
real = train[,5]
table(predicted=nbtrain, real=real)
accuracy = (88+36)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:4])
real = test[,5]
table(predicted=nbtest, real=real)
accuracy = (37+14)/dim(test)[1]
accuracy

#m2&m3 89.7% [training], 82.8% [test]
alldata23 = alldata[,-3]
alldata23 = alldata23[,-5]
train = alldata23[trainIndex,]
test = alldata23[-trainIndex,]

nbmodel = naive_bayes(train[,1:4], train[,5], usekernel=T)
nbtrain = predict(nbmodel,train[,1:4])
real = train[,5]
table(predicted=nbtrain, real=real)
accuracy = (86+36)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:4])
real = test[,5]
table(predicted=nbtest, real=real)
accuracy = (34+14)/dim(test)[1]
accuracy

#m2&m4 87.5% [training], 86.2% [test]
alldata24 = alldata[,-3]
alldata24 = alldata24[,-4]
train = alldata24[trainIndex,]
test = alldata24[-trainIndex,]

nbmodel = naive_bayes(train[,1:4], train[,5], usekernel=T)
nbtrain = predict(nbmodel,train[,1:4])
real = train[,5]
table(predicted=nbtrain, real=real)
accuracy = (82+37)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:4])
real = test[,5]
table(predicted=nbtest, real=real)
accuracy = (36+14)/dim(test)[1]
accuracy

#m3&m4 90.4% [training], 87.9% [test]
alldata34 = alldata[,-3]
alldata34 = alldata34[,-3]
train = alldata34[trainIndex,]
test = alldata34[-trainIndex,]

nbmodel = naive_bayes(train[,1:4], train[,5], usekernel=T)
nbtrain = predict(nbmodel,train[,1:4])
real = train[,5]
table(predicted=nbtrain, real=real)
accuracy = (86+37)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:4])
real = test[,5]
table(predicted=nbtest, real=real)
accuracy = (37+14)/dim(test)[1]
accuracy

#m1&m2&m3 92.6% [training], 86.2% [test]
alldata123 = alldata[,-6]
train = alldata123[trainIndex,]
test = alldata123[-trainIndex,]

nbmodel = naive_bayes(train[,1:5], train[,6], usekernel=T)
nbtrain = predict(nbmodel,train[,1:5])
real = train[,6]
table(predicted=nbtrain, real=real)
accuracy = (89+37)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:5])
real = test[,6]
table(predicted=nbtest, real=real)
accuracy = (37+13)/dim(test)[1]
accuracy

#m2&m3&m4 91.2% [training], 89.7% [test]
alldata234 = alldata[,-3]
train = alldata234[trainIndex,]
test = alldata234[-trainIndex,]

nbmodel = naive_bayes(train[,1:5], train[,6], usekernel=T)
nbtrain = predict(nbmodel,train[,1:5])
real = train[,6]
table(predicted=nbtrain, real=real)
accuracy = (85+39)/dim(train)[1]
accuracy
nbtest = predict(nbmodel, test[,1:5])
real = test[,6]
table(predicted=nbtest, real=real)
accuracy = (36+16)/dim(test)[1]
accuracy
