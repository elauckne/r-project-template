'###############################################################################
#   R Project Template               ###########################################
#   Build Features                   ###########################################
################################################################################'


build_model_input <- function() {

  # input: Input file name with raw data
  # run_code: Run Code used to name output
  # sample: FALSE or number of samples to subset data
  # pre_Process: FALSE or string vector that defines pre-processing of the features
      # Caret preprocess options for method:
      # https://www.rdocumentation.org/packages/caret/versions/6.0-80/topics/preProcess
  
  # Return: None, write model input in RData File

  
'################################################'
### Load Data     ###############################
'################################################'
  
  flog.info('Load data file')
  
  dir_input <- paste0('data/raw/', input)
  abalone <- read.csv(dir_input)

  
'################################################'
### Build Features   ############################
'################################################'
  
  flog.info('Start Feature Building')
  
  if(sample!=F) abalone <- abalone[sample(nrow(abalone), sample), ]

  ### Extract x,y and IDs
  y <- abalone$Rings
  x <- abalone[,!names(abalone) %in% 'Rings']
  ids <- rownames(abalone)

  ### Transform categorical variables to numeric
  dmy_vars <- dummyVars(" ~ .", data = x,
                        fullRank = T)
  x <- data.frame(predict(dmy_vars, newdata = x))

  flog.info('Finished Feature Building')
  
  
'################################################'
### Save Features   #############################
'################################################'

  flog.info('Save Features')

### Only keep relevant objects
  final_objects <- c('ids', 'y', 'x', 'run_group', 'run_code')
  rm(list = setdiff(ls(), final_objects))

### Save
  dir_output <- paste0('data/output/features_', run_group, '_', run_code, '.RData')

  save(list = ls(all.names = TRUE), 
       file = dir_output, 
       envir = environment())
}