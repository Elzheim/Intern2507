library('haven')
library('dplyr')
library('naniar')
library('reticulate')

data.merging <- function(
    topic.list, year.list, file.list){
  topic.variables <- list()
  topic.length <- length(topic.list)
  year.length <- length(year.list)
  file.length <- length(file.list)
  initial.cnt <- 1
  for (topic in topic.list){
    year_cnt <- 1
    target.idx <- which(grepl(topic,file.list[1:file.length]),c(1:file.length))
    topic.dataframe <- read_xpt(file.list[target.idx[1]])
    topic.dataframe$YEAR <- year.list[year_cnt]
    year_cnt <- year_cnt+1
    for (idx in target.idx[-1]){
      tmp.dataframe <- read_xpt(file.list[idx])
      tmp.dataframe$YEAR <- year.list[year_cnt]
      topic.dataframe <- bind_rows(topic.dataframe,tmp.dataframe)
      year_cnt <- year_cnt +1
    }
    topic.coln <- colnames(topic.dataframe)
    topic.variables[topic] <- list(colnames(topic.dataframe))
    if (initial.cnt==1){
      global.dataframe <- topic.dataframe
      global.coln <- colnames(global.dataframe)
    } else {
      intersect.coln <- intersect(global.coln,topic.coln)
      global.dataframe <- merge(global.dataframe,topic.dataframe,by=intersect.coln, all=TRUE)
    }
    global.coln <- union(global.coln,topic.coln)
    initial.cnt=initial.cnt+1
  }
  return(global.dataframe)
}
