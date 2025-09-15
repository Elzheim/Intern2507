library('readxl')

sourceQ <- function(path){
  excelquary <- read_excel(paste0(wdir,'/quary/quary_topic.xlsx'))
  topic.name <- names(excelquary)
  factor.list <- list()
  for(name in topic.name){
    clean.list <- c(name=na.omit(excelquary[,name]))
    factor.list <- c(factor.list,clean.list)
  }
  return(factor.list)
}
