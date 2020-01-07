'###############################################################################
#   R Project Template               ###########################################
#   Build Pipeline                   ###########################################
################################################################################'


# Set Working Directory
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Source Functions
  source('scripts/utils.R')
  load_libs()

# Load Configuration for specific run
  load_config('abalone_nopp.R')
  
# Build Model Input
  build_model_input()

# Tune Paramters
  if(tune==T) tune_parameters()

# Run and Evaluate Models
  run_evaluate_models()
