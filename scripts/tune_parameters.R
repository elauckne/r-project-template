'###############################################################################
#   R Project Template               ###########################################
#   Hyperparameter Tuning            ###########################################
################################################################################'


tune_parameters <- function() {


'################################################'
### Load Data     ###############################
'################################################'
  
  dir_input <- paste0('data/output/features_', run_group, '_', run_code, '.RData')
  load(dir_input)


'################################################'
### Tuning Configuration  #######################
'################################################'
  trControl <- trainControl(method = "cv", number = folds, 
                            allowParallel = T)
  best_tunes <- list()


'################################################'
### rqlasso   ###################################
'################################################'

  model <- 'rqlasso'
  if(model %in% models) {
  grid <- expand.grid(lambda = seq(from = 0, to = 10, by = 0.5))
  
  flog.info('Start tuning model %s', model)

  md <- train(x, y, method = model, metric = optimize, 
                trControl = trControl, tuneGrid = grid, preProcess=pre_Process)
  best_tune <- data.frame(md$bestTune)
  best_tunes[[model]] <- best_tune
  assign(paste0('md_tune_', model), md)

  flog.info('Finished tuning model %s', model)
  }

'################################################'
### glmnet   ####################################
'################################################'

  model <- 'glmnet'
  if(model %in% models) {
  grid <- expand.grid(alpha = c(0,1), #alpha=1 -> lasso, alpha=0 -> ridge 
                      lambda = seq(from = 0, to = 10, by = 0.5))
  
  flog.info('Start tuning model %s', model)
  
  md <- train(x, y, method = model, metric = optimize, 
              trControl = trControl, tuneGrid = grid, preProcess=pre_Process)
  best_tune <- data.frame(md$bestTune)
  best_tunes[[model]] <- best_tune
  assign(paste0('md_tune_', model), md)
  
  flog.info('Finished tuning model %s', model)
  }
  
'################################################'
### cubist   ####################################
'################################################'

  model <- 'cubist'
  if(model %in% models) {
  grid <- expand.grid(committees = seq(10, 100, 10), 
                          neighbors = c(0,3,5,7,9))
  
  flog.info('Start tuning model %s', model)
  
  md <- train(x, y, method = model, metric = optimize, 
              trControl = trControl, tuneGrid = grid, preProcess=pre_Process)
  best_tune <- data.frame(md$bestTune)
  best_tunes[[model]] <- best_tune
  assign(paste0('md_tune_', model), md)
  
  flog.info('Finished tuning model %s', model)
  }

'################################################'
### xgboost   ###################################
'################################################'
### Lots of parameters, tuned in 2 rounds for performance reasons

  model <- 'xgbTree'
  if(model %in% models) {
  grid = expand.grid(
    nrounds = seq(from = 100, to = 1000, by = 300),
    max_depth = c(4, 8, 12),
    eta = c(0.025, 0.1, 0.3),
    gamma = 0, 
    min_child_weight = 1,
    subsample = 1,
    colsample_bytree = 1
  )
  
### Run Tuning 1
  
  flog.info('Start 1st tuning model %s', model)
  
  md <- train(x, y, method = model, metric = optimize, 
              trControl = trControl, tuneGrid = grid, preProcess=pre_Process)
  best_tune <- data.frame(md$bestTune)
  best_tunes[[model]] <- best_tune
  assign(paste0('md_tune_', model), md)

  flog.info('Finished 1st tuning model %s', model)


### Run Tuning 2 grabbing parameters from first run

  flog.info('Start 2nd tuning model %s', model)
  
  grid = expand.grid(
    nrounds = best_tunes[[model]][, 'nrounds'],
    max_depth = best_tunes[[model]][, 'max_depth'],
    eta = best_tunes[[model]][, 'eta'],
    gamma = 0, 
    min_child_weight = c(1,2,3),
    subsample = c(0.8, 1),
    colsample_bytree = c(0.8, 1)
  )
  
  md <- train(x, y, method = model, metric = optimize, 
              trControl = trControl, tuneGrid = grid, preProcess=pre_Process)
  best_tune <- data.frame(md$bestTune)
  
  best_tunes[[model]] <- best_tune
  assign(paste0('md_tune_', model, '2'), md)
  
  flog.info('Finished 2nd tuning model %s', model)
  }

'################################################'
### Save Parameters   ###########################
'################################################'
### Clear Workspace
  ws <- ls()
  final_objects <- c(ws[ws %like% 'md_tune_'], 'best_tunes')
  rm(list = setdiff(ls(), final_objects))

### Save
  dir_output <- paste0('data/output/tunings_', run_group, '_', run_code, '.RData')
  
  save(list = ls(all.names = TRUE), 
       file = dir_output, 
       envir = environment())
  
  }







# #md <- train(x_kpi, y_kpi, method = model, metric = optimize, 
# #            trControl = trControl, tuneGrid = grid)
# 
# md <- md_tune_glmnet_ppm
# 
# tuneplot <- function(x, probs = .90) {
#   ggplot(x) +
#     coord_cartesian(ylim = c(quantile(x$results$MAE, probs = probs), min(x$results$MAE))) +
#     theme_bw()
# }
# 
# tuneplot(md)
# md$bestTune
