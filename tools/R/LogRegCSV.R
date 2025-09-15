library('haven')

LogRegCSV <- function(data, cycle, model){
  origin.data <- data
  adj.model <-model
  adj.model.list <- list()
  explanatory.var.sum <- ''
  topic <- model[[1]]
  factor.name <- model[[2]][[1]]
  dir.create(paste0('~/R_Study/AS/result/',topic,"/",factor.name),recursive = 'TRUE')
  storage.dir <- paste0('~/R_Study/AS/result/',topic,'/',factor.name)
  for (adj in adj.model[-1]){
    explanatory.var <- paste(unlist(adj),collapse = "+")
    explanatory.var.sum <- paste(explanatory.var.sum,'+',
                                 explanatory.var,
                                 collapse = '+')
    adj.model.list <- append(adj.model.list,explanatory.var.sum)
  }
  for (year in cycle) {
    for (form in adj.model.list){
      idx <- which(adj.model.list==form)
      formula.str <- paste(adj.model[1],'~',form)
      formula.obj <- as.formula(formula.str)
      model <- glm(formula = formula.obj, 
                   data=origin.data[which(origin.data$YEAR==year),], 
                   family=binomial(link = 'logit'))
      sum.model <- coef(summary(model))
      model.summary <- list('Odd Ratio' = exp(coef(model)),
                            '95% CI' = exp(confint(model)),
                            'P value' = sum.model[,'Pr(>|z|)'])
      write.csv(model.summary,file=paste0(storage.dir,'/',
                                          paste(year,idx),
                                          '.csv'))
    }
  }
  for(form in adj.model.list){
      idx <- which(adj.model.list==form)
      formula.str <- paste(adj.model[1],'~',form)
      formula.obj <- as.formula(formula.str)
      model <- glm(formula = formula.obj, 
                   data=origin.data, 
                   family=binomial(link = 'logit'))
      sum.model <- coef(summary(model))
      model.summary <- list('Odd Ratio' = exp(coef(model)),
                            '95% CI' = exp(confint(model)),
                            'P value' = sum.model[,'Pr(>|z|)'])
      write.csv(model.summary,file=paste0(storage.dir,'/',
                                          paste('Total',idx),
                                          '.csv'))    
      }
}