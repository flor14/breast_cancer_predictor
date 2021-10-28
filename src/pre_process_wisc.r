# author: Tiffany Timbers
# date: 2019-12-18

"Cleans, splits and pre-processes (scales) the Wisconsin breast cancer data (from http://mlr.cs.umass.edu/ml/machine-learning-databases/breast-cancer-wisconsin/wdbc.data).
Writes the training and test data to separate feather files.

Usage: src/pre_process_wisc.r --input=<input> --out_dir=<out_dir>
  
Options:
--input=<input>       Path (including filename) to raw data (feather file)
--out_dir=<out_dir>   Path to directory where the processed data should be written
" -> doc


library(tidyverse)
library(caret)
library(tidymodels)
library(docopt)
library(arrow) 
set.seed(2020)

opt <- docopt(doc)
main <- function(input, out_dir){
  # read data and convert class to factor
  raw_data <- arrow::read_feather("data/raw/wdbc.feather") #input
  colnames(raw_data) <- c("id",
                          "class",
                          "mean_radius",
                          "mean_texture",
                          "mean_perimeter", 
                          "mean_area",
                          "mean_smoothness",
                          "mean_compactness",
                          "mean_concavity",
                          "mean_concave_points",
                          "mean_symmetry",
                          "mean_fractal_dimension",
                          "se_radius",
                          "se_texture",
                          "se_perimeter", 
                          "se_area",
                          "se_smoothness",
                          "se_compactness",
                          "se_concavity",
                          "se_concave_points",
                          "se_symmetry",
                          "se_fractal_dimension",
                          "max_radius",
                          "max_texture",
                          "max_perimeter", 
                          "max_area",
                          "max_smoothness",
                          "max_compactness",
                          "max_concavity",
                          "max_concave_points",
                          "max_symmetry",
                          "max_fractal_dimension")
  raw_data <- raw_data |> 
    select(-id) |>    
  mutate(class = as.factor(class))
  
  # split into training and test data sets
  split <- rsample::initial_split(raw_data, prop = 0.75)
  training_data <- rsample::training(split)
  testing_data <- rsample::testing(split)
  
  # scale test data using scale factor
   class_rec <- recipes::recipe(class ~ ., data = training_data) 
  sum_rec <- summary(class_rec)
  
  # scale test data using scale factor

  training_scaled <- prep(class_rec) |> 
    bake(new_data = NULL)
  
  test_scaled <- prep(class_rec) |> 
    bake(new_data = testing_data)
  
  # write scale factor to a file
  try({
    dir.create(out_dir)
  })
 # saveRDS(sum_rec, file = paste0(out_dir, "/recipe.rds"))
  
  # write training and test data to feather files
  write_feather(training_scaled, paste0(out_dir, "/training.feather"))
  write_feather(test_scaled, paste0(out_dir, "/test.feather"))
}

main(opt[["--input"]], opt[["--out_dir"]])
