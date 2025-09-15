library('haven')
library('rms')
library('ggplot2')
source('~/R_Study/AS/tools/R/LogRegCSV.R')

data <- read_xpt('~/R_study/AS/tmp/NHANES1.xpt')

dd <- datadist(data)
options(datadist = dd)
#--------------------------preprocess ------------------------------------------

data$CyQNT1 <- as.factor(data$CyQNT1)
data$CyQNT1 <- relevel(data$CyQNT1,ref='Q1')
data$CyQNTM <- as.factor(data$CyQNTM)
data$CyQNTM <- relevel(data$CyQNTM,ref='Q1')
data$CAFFQNT <- as.factor(data$CAFFQNT)
data$CAFFQNT <- relevel(data$CAFFQNT,ref='Q1')
data$DAY1QNT <- as.factor(data$DAY1QNT)
data$DAY1QNT <- relevel(data$DAY1QNT,ref='Q1')
data$CAFFCATE <- as.factor(data$CAFFCATE)
data$CAFFCATE <- relevel(data$CAFFCATE, ref='None')
Relience.var <- 'DPQBIN'
Independent.var <- c('DRMTCAFF','CAFFCATE','CAFFQNT','CyQNTM','CyQNT1')
Cycle <- names(table(data$YEAR))
#--------------------------verification-----------------------------------------
ANOVA.CAFFM <- aov(DRMTCAFF~YEAR, data=data)
ANOVA.CAFFL <- aov(DRLTCAFF~YEAR, data=data)
ANOVA.DPQ <- aov(DPQBIN~YEAR, data=data)
summary(ANOVA.CAFFM)
#summary(ANOVA.CAFFL)
summary(ANOVA.DPQ)

TukeyHSD(ANOVA.CAFFM)
#TukeyHSD(ANOVA.CAFFL)
TukeyHSD(ANOVA.DPQ)
ru.CAFF.total <- kruskal.test(DRMTCAFF~YEAR, data=data)

#Processing Analysis for ReVar with year, Cate, qnt-----------------------------
for (var in Independent.var){
  modeling <- adjmodel <- list(Relience.var,
                               list(var,'RIDAGEYR','GENDR'),
                               list('RIDRETH1','INDF+INDH','DMDEDUC2'),
                               list('SMQ020','PAQBIN','ALQBIN'))
  LogRegCSV(data=data,cycle=Cycle,model=modeling)
  
}

#--------------------------RCS graph--------------------------------------------

rcsmodel <- lrm(DPQBIN~rcs(DRMTCAFF,4),data=data)
ggplot(Predict(rcsmodel, DRMTCAFF, ref.zero=T, fun=exp))+
  ggtitle("RCS for Caffeine and Depression Odd ratio")+
  xlab("Log transformed Caffeine intake")+
  ylab('Depression Odd ratio')+
  theme_bw()
