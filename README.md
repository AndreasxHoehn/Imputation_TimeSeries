# Imputation_TimeSeries

This is a minimum working working example which illustrates how to impute gaps in time series or cross-sectional data

Based on Amelia's algorithm, it will impute everything that is missing based on everything that is available N times

It will then stack the results based on the mean or median in 1 final dataset.

All required packages will be downloaded automatically

N = 1,000 imputed datasets

Fast stacking of results via data.table functions with time benchmark

