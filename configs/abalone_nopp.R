'###############################################################################
#   R Project Template               ###########################################
#   Config                           ###########################################
################################################################################'

# Description
    # Default config without preprocessing

# Define Run
    run_group <- 'abalone'    
    run_code <- 'nopp'
      
# Input Data
    input <- 'abalone.csv'
    sample <- F
	    
# Modeling
    models=c('rqlasso', 'glmnet', 'xgbTree')
    optimize <- 'RMSE'
    pre_Process <- F
    folds <- 5
    tune <- T
    tuneLength <- 3
    cores <- 3
    feature_importance <- F