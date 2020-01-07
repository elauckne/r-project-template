'###############################################################################
#   R Project Template               ###########################################
#   Config                           ###########################################
################################################################################'

# Description
    # Add centering and scaling as preprocessing steps

# Define Run
    run_group <- 'abalone'    
    run_code <- 'cs'
      
# Input Data
    input <- 'abalone.csv'
    sample <- F
	    
# Modeling
    models <- c('rqlasso', 'glmnet', 'xgbTree')
    optimize <- 'RMSE'
    pre_Process <- c('center', 'scale')
    folds <- 5
    tune <- T
    tuneLength <- 3
    cores <- 3
    feature_importance <- F