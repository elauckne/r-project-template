'###############################################################################
#   R Project Template               ###########################################
#   Utils                            ###########################################
################################################################################'


source('scripts/build_model_input.R')
source('scripts/tune_parameters.R')
source('scripts/run_evaluate_models.R')


load_libs <- function(){
    
    # Install/Load all libraries necessary for project
  
    pkg <- c("data.table", "ggplot2", "dplyr", "gridExtra",  
             "foreach", "doParallel", "caret", "DataExplorer", 
             "reshape2", "here", "futile.logger", "Metrics", "knitr",
             "kableExtra")
    
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
          install.packages(new.pkg, dependencies = TRUE)
    
    status <- sapply(pkg, require, character.only = TRUE)
    if(sum(status == F) > 0) {stop(); status} else status
    
}

load_config <- function(config){
    
    config_dir <- paste0('configs/', config)
    source(config_dir)
    
}