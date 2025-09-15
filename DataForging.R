library('haven')
library('readxl')
library('dplyr')
library('naniar')
library('reticulate')
library('xportr')
library('transplantr')
library('psych')
library('ggplot2')
library('ztable')

#--------------------------데이터 합치기 과정-------------

#set working directory
system('python3 C:/Users/misty/Documents/R_Study/AS/tools/Python/ini.py')
wdir <- readLines('C:/Users/misty/Documents/R_Study/AS/tmp/dirlist.txt')
tmp.dir <- paste0(wdir,'/tmp/')
tooldir.python <- paste0(wdir,'/tools/Python')
tooldir.R <- paste0(wdir,'/tools/R')

#Run directing data files
python.dir <-gsub('/','\\\\',paste0(wdir, '/tools/Python/file_indexing.py')) 
system(paste('python3',shQuote(python.dir),'NHANES'))
filelist.dir <- paste0(tmp.dir,'filelist.txt')


#take file name
file.names=readLines(filelist.dir)
filelist.data <- gsub('\\\\', '/', file.names)

#read file list with directory
source(paste0(tooldir.R,'/filelist_reading.R'))
filelisting.data <- file.listing(dir=filelist.dir)

#merging data frames from listed directory
source(paste0(tooldir.R,'/data_merger.R'))
merged.data.frame <- data.merging(topic.list = filelisting.data$topic,
                           year.list = filelisting.data$year,
                           file.list = filelisting.data$file)

#get factor question
source(paste0(tooldir.R,'/squary.R'))
quary.list <- sourceQ(paste0(wdir,'/quary/quary_topic.xlsx'))

#data selection from merged directory
source(paste0(tooldir.R,'/table_selection.R'))
selected.data.frame <- table.selection(factor.list = quary.list,df=merged.data.frame)

#data loading into temporary folder
xportr_write(selected.data.frame, path=paste0(tmp.dir,'selectDF.xpt'))
save(quary.list,file=paste0(tmp.dir,'qList.RData'))

#--------------------데이터 합치기 끝---------------------

#주요 변수 계산
selected.data.frame$DPQANS <- rowSums(is.na(selected.data.frame[,quary.list$name.DPQ]))
selected.data.frame$ANSBIN <- NA
selected.data.frame$ANSBIN <- ifelse(selected.data.frame$DPQANS<5, 1, NA)
selected.data.frame$DRMTCAFF <- rowSums(selected.data.frame[,c("DR1TCAFF",'DR2TCAFF')],na.rm='TRUE')/2
selected.data.frame$DRMTCAFF <- ifelse(is.na(selected.data.frame$DR1TCAFF)&is.na(selected.data.frame$DR2TCAFF),NA, selected.data.frame$DRMTCAFF)


#결측 확인 리스트 받기
exlist <- readLines(paste0(wdir,'/quary/exclude.txt'))

#결측치 제거거
int_cnt <- 1
for(source in exlist){
  for(cols in source){
    if (int_cnt==1){
      data.cleaned <- selected.data.frame[complete.cases(selected.data.frame[,cols]),]
      int_cnt <- int_cnt+1
    } else {
      data.cleaned <- data.cleaned[complete.cases(data.cleaned[,cols]),]
      int_cnt <- int_cnt+1
    }
  }
}
#Depression 계산산
data.cleaned$DPQSCR <- rowSums(data.cleaned[,quary.list$name.DPQ],na.rm='TRUE')


#covariates pre-processing
data.cleaned$PAQVIG <- rowSums(data.cleaned[,c("PAD200",'PAQ605')],na.rm='TRUE')
data.cleaned$PAQVIG <- replace(data.cleaned$PAQVIG,data.cleaned$PAQVIG>=3,NA)
data.cleaned$PAQMOD <- rowSums(data.cleaned[,c('PAD320','PAQ620')],na.rm='TRUE')
data.cleaned$PAQMOD <- replace(data.cleaned$PAQMOD,data.cleaned$PAQMOD>=3,NA)
data.cleaned$INDF <- rowSums(data.cleaned[,c('INDFMINC','INDFMIN2')],na.rm = 'TRUE')
data.cleaned$INDH <- rowSums(data.cleaned[,c('INDHHINC','INDHHIN2')],na.rm = 'TRUE')
data.cleaned$RIAGENDR <- data.cleaned$RIAGENDR-1
data.cleaned$SMQ020 <- data.cleaned$SMQ020-1
data.cleaned$SMQ020 <- replace(data.cleaned$SMQ020,data.cleaned$SMQ020>2,NA)
data.cleaned$SMQ040 <- replace(data.cleaned$SMQ040,data.cleaned$SMQ040>3,NA)
data.cleaned$SMQ050Q <- replace(data.cleaned$SMQ050Q,data.cleaned$SMQ050Q>72,NA)


data.cleaned$GENDR <- NA
data.cleaned[which(data.cleaned$RIAGENDR==0),]$GENDR <- 'M'
data.cleaned[which(data.cleaned$RIAGENDR==1),]$GENDR <- 'F'
data.cleaned$ETH1 <- NA
data.cleaned[which(data.cleaned$RIDRETH1==1),]$ETH1 <- 'Mex'
data.cleaned[which(data.cleaned$RIDRETH1==2),]$ETH1 <- 'His'
data.cleaned[which(data.cleaned$RIDRETH1==3),]$ETH1 <- 'Wht'
data.cleaned[which(data.cleaned$RIDRETH1==4),]$ETH1 <- 'Blk'
data.cleaned[which(data.cleaned$RIDRETH1==5),]$ETH1 <- 'Oth'
data.cleaned$EDUC2 <- NA
data.cleaned[which(data.cleaned$DMDEDUC2==1),]$EDUC2 <- '9TH'
data.cleaned[which(data.cleaned$DMDEDUC2==2),]$EDUC2 <- '12TH'
data.cleaned[which(data.cleaned$DMDEDUC2==3),]$EDUC2 <- 'HSC'
data.cleaned[which(data.cleaned$DMDEDUC2==4),]$EDUC2 <- 'AAg'
data.cleaned[which(data.cleaned$DMDEDUC2==5),]$EDUC2 <- 'Col'


#Binary
data.cleaned$PAQBIN <- ifelse(data.cleaned$PAQVIG==1|data.cleaned$PAQMOD==1,1,0)
data.cleaned$ALQBIN <- ifelse(data.cleaned$ALQ101==1|data.cleaned$ALQ110==1, 1, 0)
data.cleaned$DPQBIN <- ifelse(data.cleaned$DPQSCR>=10,1,0)


#이상치 제거 카페인 섭취량 기준
#data.cleaned.outlier <- data.cleaned[complete.cases(data.cleaned$CAFFQNT),]
#xportr_write(data.cleaned.outlier,path='~/R_Study/AS/tmp/NHANES3.xpt')


#Day1 Day2 카페인 섭취 log
data.cleaned$DRLTCAFF <- log(data.cleaned$DRMTCAFF)
data.cleaned[which(data.cleaned$DRLTCAFF<=0),]$DRLTCAFF <- 0
data.cleaned$CAFFCATE <- NA
data.cleaned[which(data.cleaned$DRMTCAFF<38),]$CAFFCATE <- 'None'
data.cleaned[which(data.cleaned$DRMTCAFF<90&data.cleaned$DRMTCAFF>=38),]$CAFFCATE <- 'Low'
data.cleaned[which(data.cleaned$DRMTCAFF<400&data.cleaned$DRMTCAFF>=90),]$CAFFCATE <- 'Mod'
data.cleaned[which(data.cleaned$DRMTCAFF>=400),]$CAFFCATE <- 'High'

#-----quantile calculate------------------
data.cleaned$CAFFQNT <- NA
data.cleaned$DAY1QNT <- NA
quantile.var <- c('DRMTCAFF','DR1TCAFF')
masking.var <- c('CAFFQNT','DAY1QNT')
int_cnt <- 1
for (var in quantile.var){
  qnt <- quantile(data.cleaned[,var],na.rm='TRUE')
  mvar <- masking.var[int_cnt]
  int <- 1
  for (q in qnt[1:4]){
    data.cleaned[which(data.cleaned[,var]>=q),][,mvar] <- paste0('Q',int)
    int <- int+1
  }
  dir.create('~/R_Study/AS/result/CNT/Total',recursive = TRUE)
  write.csv(table(data.cleaned[,mvar]),paste0('~/R_Study/AS/result/CNT/Total/',mvar,'.csv'))
  int_cnt <- int_cnt+1
}

data.cleaned$CyQNTM <- NA
data.cleaned$CyQNT1 <- NA
cycle <- names(table(data.cleaned$YEAR))
qntcl <- c('CyQNTM','CyQNT1')
count <- c('DRMTCAFF','DR1TCAFF')
for (year in cycle){
  for (i in c(1,2)){
    col1 <- count[i]
    col2 <- qntcl[i]
    qnt <- quantile(data.cleaned[which(data.cleaned$YEAR==year),][col1], na.rm = 'TRUE')
    int <- 1
    for (cut in qnt[1:4]){
      data.cleaned[which(data.cleaned$YEAR==year&data.cleaned$DRMTCAFF>=cut),][col2] <- paste0('Q',int)
      int <- int+1
    }
    dir.create(paste0('~/R_Study/AS/result/CNT/',year),recursive = TRUE)
    write.csv(table(data.cleaned[which(data.cleaned$YEAR==year),][col2]),file=paste0('~/R_Study/AS/result/CNT/',year,'/',col2,".csv"))
  }
}

xportr_write(data.cleaned,path=paste0(tmp.dir,'NHANES0.xpt'))

summary.list <- readLines(paste0(wdir,'/quary/Subject.txt'))

data.summary <- data.cleaned[,summary.list]
xportr_write(data.summary,path=paste0(tmp.dir,'NHANES1.xpt'))

intcollist <- readLines('~/R_Study/AS/quary/TablingINT.txt')
cntcollist <- readLines('~/R_Study/AS/quary/TablingCNT.txt')

source(paste0(tooldir.R,'/baseline.R'))
for(year in names(table(data.summary$YEAR))){
  tablingINT(dataframe = data.summary[which(data.summary$YEAR==year),],year = year, collist=intcollist)
  tablingCNT(dataframe = data.summary[which(data.summary$YEAR==year),],year = year, collist=cntcollist)
}
tablingINT(dataframe = data.summary,collist = intcollist)
tablingCNT(dataframe = data.summary,collist = cntcollist)

for (year in filelisting.data$year){
  tmp.data.year <- data.summary[which(data.summary$YEAR==year),]
  tableing(tmp.data.year, year=year)
}

table.2005 <- data.summary[which(data.summary$YEAR=='0506'),]
table.2007 <- data.summary[which(data.summary$YEAR=='0708'),]
table.2009 <- data.summary[which(data.summary$YEAR=='0910'),]

count.list <- c('RIAGENDR','DMDEDUC2','SMQ020','PAQBIN','ALQBIN','DPQBIN')
count.data <- data.frame()
emp.list <- list()
for (y in filelisting.data$year){
  y <- y
  g <- as.character(table(data.summary[which(data.summary$YEAR==y),]$RIAGENDR)[[2]])
  s <- as.character(table(data.summary[which(data.summary$YEAR==y),]$SMQ020)[[2]])
  p <- as.character(table(data.summary[which(data.summary$YEAR==y),]$PAQBIN)[[2]])
  a <- as.character(table(data.summary[which(data.summary$YEAR==y),]$ALQBIN)[[2]])
  d <- as.character(table(data.summary[which(data.summary$YEAR==y),]$DPQBIN)[[2]])
  
  tmp.list <- list('Year'=y,
                   'Gender'=g,
                   'Current Smoking'=s,
                   'Physical Activity'=p,
                   'Alcohol'=a,
                   'Depression'=d)
  emp.list <- cbind(emp.list,tmp.list)
  count.data <- merge(count.data,as.data.frame(tmp.list))
}

tmp.list <- list('Year'='0510',
                 'Gender'=as.character(table(data.summary$RIAGENDR)[[2]]),
                 'Current Smoking'=as.character(table(data.summary$SMQ020)[[2]]),
                 'Physical Activity'=as.character(table(data.summary$PAQBIN)[[2]]),
                 'Alcohol'=as.character(table(data.summary$ALQBIN)[[2]]),
                 'Depression'=as.character(table(data.summary$DPQBIN)[[2]])
)
emp.list <- cbind(emp.list,tmp.list)
write.csv(emp.list,file='~/R_Study/AS/result/count.csv')
