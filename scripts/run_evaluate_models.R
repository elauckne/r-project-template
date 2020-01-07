'###############################################################################
#   R Project Template               ###########################################
#   Build Models                     ###########################################
################################################################################'  


run_evaluate_models <- function() {
  
  
  # run_code: Run Code used to grab correct input and name output
  # folds: Number of CV folds
  # models: List of caret models to be run
  # tuneLength: Number of levels for each tuning parameters to be generated
  # optimize: Evaluation metric to be optimized by train function
  # feature_importance: Boolean for calculating Feature Importance
  # cores: Number of cores for parallel processing
  
  # Return Predictions, Evaluations and Plots for run Models in RData File
  
  
'################################################'
### Load Data     ###############################
'################################################'
  
  flog.info("Load Data")
  
  # Train Data
  dir_data <- paste0('data/output/features_', run_group, '_', run_code, '.RData')
  load(dir_data)

  # Parameters
  dir_para <- paste0('data/output/tunings_', run_group, '_', run_code, '.RData')

  if(file_test("-f", dir_para)){
    load(dir_para)
    flog.info("Tuning Parameters available")
  } else best_tunes <- NULL
  
  
'################################################'
### Model     ###################################
'################################################'

  ### Load predefined Model parameters
  source('configs/_models.R')
  
  ### Define Folds and Training control
  cv_folds <- createFolds(y, k = folds, returnTrain = T)
  trControl <- trainControl(method="cv", index = cv_folds, 
                            savePredictions = 'final', allowParallel = T)
  
  ### Parallel (All models run in parallel)
  cl <- makePSOCKcluster(cores)
  registerDoParallel(cl)
  
  ### Train Models
  model_results <- paste0('result_', models)
  models_worked <- list()
  
  
  for(model in models) {
    
    start <- Sys.time()
    
    # If tuned parameters available for model, run with best grid
    # If predefined parameters available for model, run with these
    # otherwise use tuneLength
    model_paras <- paste('grid', model, sep='_')
    
    if(!is.null(best_tunes[[model]])) {
      
      flog.info("Running Model with Tunings: %s", model)
      best_grid <- best_tunes[[model]]
      md <- try({train(x, y, method = model, metric = optimize, preProcess=pre_Process,
                       trControl = trControl, tuneGrid = best_grid)})
    
    } else if(exists(model_paras)) {
      
      flog.info("Running Model with preset Parameters: %s", model)
      grid <- get(model_paras)
      md <- try({train(x, y, method = model, metric = optimize,
                       trControl = trControl, tuneGrid = grid)})
    
    } else {
      
      flog.info("Running Model: %s", model)
      md <- try({train(x, y, method = model, metric = optimize,
                       trControl = trControl, tuneLength = tuneLength)})
      
    }
    
    # Log success/failure
    if(class(md) == "try-error") {
      flog.error("Failed Model: %s", model)
      next
    }
    
    flog.info("Finished Model: %s", model)
    
    duration <- round(as.numeric(difftime(Sys.time(), start), 
                                 units="hours") * 3600, 1)
    
    models_worked <- append(models_worked, model)
    
    md_pred <- md$pred[c('rowIndex', 'obs', 'pred')]
    md_pred <- md_pred[order(md_pred$rowIndex),] 
    md_pred <- md_pred[c('obs', 'pred')]
    md_pred <- cbind(ids, md_pred)
    colnames(md_pred) <- c('id', 'obs', 'tst_pred')
    md_pred['tst_pred'][md_pred['tst_pred'] < 0] <- 0
    
    trn_pred <- predict.train(md,x)
    md_pred['trn_pred'] <- trn_pred
    
    md_pred[,-1] <- lapply(md_pred[,-1], function(x) round(as.numeric(x)))
    md_pred <- data.frame(md_pred)
    
    assign(paste0('result_', model), 
           list(name = model,
                duration = duration,
                object = md,
                final_model = md$finalModel,
                resample = md$resample,
                bestTune = md$bestTune,
                preds = md_pred))
  }
  
  models = unlist(models_worked)
  model_results <- paste0('result_', models)
  
  ### Stop Cluster / Register Sequential
  stopCluster(cl)
  registerDoSEQ()
  
  flog.info('Evaluate Models')
  
  
  '################################################'
  ### Evaluate Models #############################
  '################################################'
  ### Duration
  durations <- foreach(md = model_results, .combine = rbind) %do% {
    durations <- data.frame(model = get(md)$name, 
                            duration = get(md)$duration)
    durations
  }
  
  plot_duration <- ggplot(durations, 
                          aes(x = reorder(model, -duration), 
                              y = duration)) + 
    geom_bar(stat = "identity") + coord_flip() + 
    labs(x = "Model", y = "Time")
  
  
  ### Boxplot Model
  cv_results <- foreach(model = models, 
                        .combine = rbind) %do% {
                          md <- get(paste0('result_', model))
                          md_df <- data.frame(md$resample)
                          md_df['model'] <- md$name 
                          
                          md_df
                        }
  
  cv_results_melt <- melt(cv_results, 
                          measure.vars=c("RMSE","MAE", "Rsquared"))
  
  plot_boxplot <- ggplot(cv_results_melt, 
                         aes(x=model, y=value, fill=variable)) + 
    geom_boxplot(fill = 'gray80', alpha = 0.7) +
    facet_wrap(~variable, scale="free") + xlab('') + ylab('')
  
  ### Get Best Model for RMSE
  metrics_mat <- matrix(nrow = length(models), ncol = 3)
  i = 1
  for(model in models) { 
    md <- get(paste0('result_', model))
    metrics_mat[i, ] <- postResample(md$preds$obs, 
                                     md$preds$tst_pred)
    i = i+1
  }
  rownames(metrics_mat) <- models
  colnames(metrics_mat) <- c('RMSE', 'Rsquared', 'MAE')
  
  best_model <- models[apply(metrics_mat,2,which.min)[optimize]]
  
  # Save all model results
  metrics_df <- data.frame(round(metrics_mat,2))
  metrics_df$model <- rownames(metrics_df)
  metrics_df$run_code <- run_code
  
  for (model in models) {
    paras <- get(paste0('result_', model))$bestTune
    paras <- paste(names(paras), as.character(paras[1,]))
    metrics_df[model,'parameters'] <- paste(paras, collapse = ' ')
  }
  
  results_file <- paste0('data/results/results_', run_group, '.csv')
  if(file_test("-f", results_file)) {
    metrics_df_old <- read.csv(results_file)
    metrics_df <- rbind(metrics_df_old, metrics_df)
  } 
  
  write.csv(metrics_df, results_file, row.names = F)
  
  
  '################################################'
  ### Best Model #############################
  '################################################'
  
  flog.info('Get Best Model')
  
  best_mod <- get(paste0('result_', best_model))
  best_mod_paras <- best_mod$bestTune
  
  ### Plot Prediction vs Truth 
  plot_predvstruth <- ggplot(best_mod$preds, 
                             aes(x = obs, y = round(tst_pred))) +
    geom_point() +
    geom_abline(intercept=0, slope=1, linetype=2) +
    xlab("Truth") + ylab("Prediction") +
    ggtitle(paste0(best_mod$name, ": Prediction vs Truth"))
  
  
  ### Feature Importance (Permutation)
  ### http://amunategui.github.io/variable-importance-shuffler/
  
  if(feature_importance == T) {
    
    flog.info('Calculate Feature Importance')
    
    y_hat <- predict(object=best_mod$object, x)
    rmse_ref = sqrt((sum((y-y_hat[[2]])^2))/nrow(x))
    
    shuffletimes <- 100
    rmse_means <- c()
    
    for (feature in colnames(x)) {
      rmse_feat <- c()
      x_shuffle <- x
      for (iter in 1:shuffletimes) {
        x_shuffle[,feature] <- sample(x_shuffle[,feature], length(x_shuffle[,feature]))
        y_hat <- predict(object=best_mod$object, x_shuffle)
        rmse_feat <- c(rmse_feat, sqrt((sum((y-y_hat[[2]])^2))/nrow(x)))
      }
      rmse_means <- c(rmse_means,  mean((rmse_feat - rmse_ref)/rmse_ref))
    }
    best_imp <- data.frame('feature'= colnames(x), 
                           'importance'= rmse_means)
    best_imp <- head(best_imp, 10)
    plot_imp <- ggplot(best_imp, 
                       aes(x=reorder(feature, importance), 
                           y=importance)) +
      geom_bar(stat='identity') + coord_flip() + 
      ylab("Importance") + xlab("Features") + 
      ggtitle(paste0(best_mod$name, ": Feature Importance"))
  }
  
  if(feature_importance == F) plot_imp <- NA
  
  ### Compare Train/Test Performance
  trn_tst_mat <- matrix(nrow = 2, ncol = 3)
  trn_tst_mat[1, ] <- postResample(best_mod$preds$obs, 
                                   best_mod$preds$tst_pred)
  trn_tst_mat[2, ] <- postResample(best_mod$preds$obs, 
                                   best_mod$preds$trn_pred)
  
  rmsle_tst <- rmsle(best_mod$preds$obs, best_mod$preds$tst_pred)
  rmsle_trn <- rmsle(best_mod$preds$obs, best_mod$preds$trn_pred)
  trn_tst_mat <- cbind(trn_tst_mat, c(rmsle_tst, rmsle_trn))
  
  rownames(trn_tst_mat) <- c('Test', 'Train')
  colnames(trn_tst_mat) <- c('RMSE', 'R2', 'MAE', 'RMSLE')
  trainvstest <- round(trn_tst_mat,3)
  
  ### Save predicition table
  pred_table <- best_mod$preds
  
  
  '################################################'
  ### Save Model Information ######################
  '################################################'
  
  flog.info('Saving Model Results')
  
  ### Only keep relevant objects
  final_objects <- c('plot_duration', 'plot_boxplot', 
                     'best_model', 'best_mod_paras',
                     'plot_predvstruth', 'plot_imp', 
                     'trainvstest', 'pred_table', 'run_code', 'predict_kpi')
  rm(list = setdiff(ls(), final_objects))
  
  ### Save
  save(list = ls(all.names = TRUE), 
       file = paste0('data/output/models_', run_group, '_', run_code, '.RData'), 
       envir = environment())
}