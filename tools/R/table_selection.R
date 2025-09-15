library('haven')
library('dplyr')
library('naniar')
library('reticulate')

table.selection <- function(factor.list, df){
  initial.cnt <- 1
  for (factorset in factor.list){
    for (factor in factorset){
      if(initial.cnt==1){
        selected.table <- data.frame(df[,factor])
        names(selected.table) <- factor
        initial.cnt <- initial.cnt+1
      } else{
        selected.table[factor] <- df[,factor]
        initial.cnt <- initial.cnt+1
      }
    }
  }
  return(selected.table)
}

