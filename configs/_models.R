'###############################################################################
#   R Project Template               ###########################################
#   Model Config                           ###########################################
################################################################################'


# rqlasso
  grid_rqlasso <- expand.grid(lambda = 5)

# glmnet
  grid_glmnet <- expand.grid(alpha = c(0,1), lambda = c(0,5,10))

# Cubist
  grid_cubist <- expand.grid(committees = 50, neighbors = 5)
  
# xgbTree
  grid_xgbTree <- expand.grid(nrounds = 300, max_depth = 8,
                              eta = 0.1,gamma = 0, min_child_weight = 2,
                              subsample = 0.8,colsample_bytree = 0.8)
# ranger
  grid_ranger <- expand.grid(mtry = 6, splitrule = 'variance', min.node.size = 2)
  
# extraTrees
  grid_extraTrees =  expand.grid(mtry = 6, numRandomCuts = 5)