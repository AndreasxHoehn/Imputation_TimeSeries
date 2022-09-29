### Meta ###

# Author: Andreas Hoehn
# Version: 1.0
# Date:  2022-09-26

# About: If data is not available for certain years or some areas, we can use
# multiple imputation. This program shows a fast N times imputation and stacking 
# of time series data using Amelia II and data table. It will create data with 
# gaps on the fly and should run as a stand alone program packages will be 
# installed automatically if required. If something breaks you will likely need 
# install "Rcpp" by hand via "install.packages(Rcpp)".

# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #

### Preparation ###

# deep clean work space
rm(list = ls())  
gc(full = TRUE) 

# set seed 
set.seed(20220926) 

# start benchmarking time 
benchmark_time <- list() 
benchmark_time$start <- Sys.time()

# List of Required Packages 
RequiredPackages <- c("data.table", "Amelia")

# ensure all packages are installed and loaded 
.EnsurePackages <- function(packages_vector) {
  new_package <- packages_vector[!(packages_vector %in% 
                                     installed.packages()[, "Package"])]
  if (length(new_package) != 0) {
    install.packages(new_package) }
  sapply(packages_vector, suppressPackageStartupMessages(require),
         character.only = TRUE)
}
.EnsurePackages(RequiredPackages)

# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #

### Definitions ###

definitions <- list()
definitions$no_imputations   <- 1000 # number of imputations 
definitions$rounding_results <- 1    # rounding of results 

# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #

### Create Some Longitudinal Long Format Data with Gaps ###

data_input <- data.table::data.table(
  LA_name = c(rep("Area A", times = 5), rep("Area B", times = 5)),
  year    = c(seq(2016,2020,1), seq(2016,2020,1)),
  indicator_1    = c(74.7,	80.3,	79.6,	NA,	81.7, 84.7,	NA,	86.1,	85.5,	87.6),
  indicator_2    = c(NA,	62.7,	NA,	60.9,	60.5,	65.8,	66.4, NA,	68.2,	68.7)) 


# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #

### Run Imputation and Stack Results ###

# run imputation
imputation <- Amelia::amelia(data_input, m = definitions$no_imputations,
                             ts = "year", cs = "LA_name")

# summary of imputaion: fraction of missing information
summary(imputation)

# N imputed datasets are stored as list in imputation$imputations -> to data.table
data_output <- data.table::rbindlist(imputation$imputations, idcol=TRUE)

# summary based on median
data_output <- data_output[, .(indicator_1 = round(median(indicator_1),
                                                   definitions$rounding_results),
                               indicator_2 = round(median(indicator_2),
                                                   definitions$rounding_results)),
                            by = c("LA_name","year")]
# print results
print(data_input)
print(data_output)

# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #

### Benchmark Time ###

benchmark_time$end <- Sys.time()
print(paste("Program Start: ", benchmark_time$start))
print(paste("Program End: ", benchmark_time$end))


# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #