# R Project Template

This R Project Template is derived from several real world projects on structured data and makes it easy to run different configurations (preprocessing, models, hypertuning) and evaluate their performance afterwards. It uses configuration files to specify details of a run and Markdown Reports to visualize data and results. 

Author: Enrico Lauckner ([GitHub](github.com/elauckne))

### Pipeline

Starting point, loads and runs specific configurations. It contains the following functions:

* build_model_input: Data Preparation/Feature Engineering, needs to output IDs, x and y. This has to be tailored to the specific data set
* tune_parameters: Optional customized parameter tuning, which does not use carets grids for candidates
* run_evaluate_models: Runs models (optionally with tuned parameters) and outputs results for evaluation


### Configs

**Define Run**

Run group and run code description create a distinct name, which is used for all outputs of a run:

* run_group: Description for the version of the dataset, e.g. timestamp. All models within a group can be evaluated against each other
* run_code: Description for the specific methods that are used on the run group, e.g. types of preprocessing, models, finetuning and more

**Input Data**
* input: Raw input data (only csv supported so far)
* sample: If not false, set for optional sampling, e.g. 0.5 for 50% of the data

**Modeling**

* models: List of models from [caret catalog](https://topepo.github.io/caret/available-models.html), e.g. c('rqlasso', 'glmnet', 'xgbTree')
* optimize: Evaluation metric to optimze, e.g. 'RMSE'
* pre_Process: List of preprocessing steps from [caret catalog](https://www.rdocumentation.org/packages/caret/versions/6.0-80/topics/preProcess), e.g. c('center', 'scale')
* folds: Number of folds in cross-validation
* tune: Boolean, true for customized parameter tuning, false for caret tuning or no tuning depending on tuneLength
* tuneLength: Size of the caret tuning grid (if tune is false)
* cores: Number of processing cores
* feature_importance: Boolean for calculating feature importance using permutation

**Model Config**

The special model config ('_models.R') contains parameters or grids of parameter candidates for each model, which are used if tune is false

### Reports

Markdown reports created with knitr and RStudio

* EDA: Exploratory Data Analysis of the raw input data
* Model Evaluation: Evaluation of model output of a run group and code, e.g. models_abalone_cs.RData
* Hyperparameter Tuning: Results for different parameters of each model, also dependent on run group and code


### To Do
* Adapt for Classification problems, currently only Regression problems can be run
* Add Model interpretation like SHAP or LIME
* Add Unit Tests
* Add functionality for automated ML
* Create Docker Image
