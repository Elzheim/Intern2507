library('haven')
library('dplyr')
library('naniar')
library('reticulate')

file.listing <- function(dir){
  file.names=readLines(filelist.dir)
  filelist.data <- gsub('\\\\', '/', file.names)
  topic.list <- unlist(strsplit(filelist.data[1],split = '\t'))
  year.list <- unlist(strsplit(filelist.data[2],split='\t'))
  file.list <- filelist.data[3:length(filelist.data)]
  file.list <- sort(file.list)
  
  return(list(topic=topic.list,year=year.list,file=file.list))
}