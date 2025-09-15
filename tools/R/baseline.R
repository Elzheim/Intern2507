library('haven')

tablingINT <- function(dataframe,year='Total',collist){
  data <- dataframe[,collist]
  dir.create(path=paste0('~/R_Study/AS/result/baseline/INT/',year))
  #mean sd
  data.Mean <- data.frame(as.list(colMeans(data, na.rm = TRUE)))
  data.SD <- data.frame(as.list(apply(data,2,sd,na.rm=TRUE)))
  data.aggre <- rbind.data.frame(data.Mean,data.SD)
  names(data.aggre) <- collist
  row.names(data.aggre) <- c('Mean','SD')
  write.csv(data.aggre, paste0('~/R_Study/AS/result/baseline/INT/',year,'/MeanSD.csv'))
}

tablingCNT <- function(dataframe, year='Total', collist){
  data <- dataframe[,collist]
  dir.create(path=paste0('~/R_Study/AS/result/baseline/CNT/',year))
  #CNT
  for(col in collist){
    data.table <- table(data[,col])
    write.csv(data.table, file=paste0('~/R_Study/AS/result/baseline/CNT/',year,'/',col,'.csv'))
  }
}

