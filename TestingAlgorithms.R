# functions I made
nearestNeighbor <- function(x) {
  stopifnot(is.ts(x)) 
  
  findNearestNeighbors <- function(x, i) {
    leftValid <- FALSE
    rightValid <- FALSE 
    numItLeft <- 1
    numItRight <- 1
    while (!leftValid) {
      leftNeighbor <- x[i - numItLeft]
      if (!is.na(leftNeighbor)) {
        leftValid <- TRUE
        leftNeighbor <- i - numItLeft
      }
      numItLeft <- numItLeft + 1
    }
    while (!rightValid) {
      rightNeighbor <- x[i + numItRight]
      if (!is.na(rightNeighbor)) {
        rightValid <- TRUE
        rightNeighbor <- i + numItRight
      }
      numItRight <- numItRight + 1
    }
    return(c(leftNeighbor, rightNeighbor))
  }
  
  for (i in 1:length(x)) {
    if (is.na(x[i])) {
      nearestNeighborsIndices <- findNearestNeighbors(x, i)
      a <- nearestNeighborsIndices[1]
      b <- nearestNeighborsIndices[2]
      if (i < ((a + b) / 2)) {
        x[i] <- x[a]
      } else {
        x[i] <- x[b]
      }
    }
  }
  return(x)
}
eval_performance <- function(x, X) {
  # x = original , X = interpolated 
  stopifnot(is.numeric(x), is.numeric(X), length(x) == length(X))
  
  n <- length(x)
  return <- list()
  
  # Coefficent of Correlation, r
  numerator <- sum((X - mean(X))*(x - mean(x)))
  denominator <- sqrt(sum((X - mean(X))^2)) * sqrt(sum((x - mean(x))^2))
  return$pearson_r <- numerator / denominator
  
  # r^2
  return$r_squared <- return$pearson_r^2  
  
  # Absolute Differences
  return$abs_differences <- sum(abs(X - x))
  
  # Mean Bias Error 
  return$MBE <- sum(X - x) / n
  
  # Mean Error 
  return$ME <- sum(x - X) / n
  
  # Mean Absolute Error 
  return$MAE <- abs(sum(x - X)) / length(x)
  
  # Mean Relative Error 
  if (length(which(x == 0)) == 0) {
    return$MRE <- sum((x - X) / x)  
  } else {
    return$MRE <- NA
  }
  
  # Mean Absolute Relative Error 
  if (length(which(x == 0)) == 0) {
    return$MARE <- sum((x - X) / x)
  } else {
    return$MARE <- NA 
  }
  
  # Mean Absolute Percentage Error 
  return$MAPE <- 100 * return$MARE
  
  # Sum of Squared Errors
  return$SSE <- sum((X - x)^2)
  
  # Mean Square Error 
  return$MSE <- 1 / n * return$SSE
  
  # Root Mean Squares, or Root Mean Square Errors of Prediction 
  if (length(which(x == 0)) == 0) {
    return$RMS <- sqrt(1 / n * sum(((X - x)/x)^2))
  } else {
    return$RMS <- NA 
  }
  
  # Mean Squares Error (different from MSE, referred to as NMSE)
  return$NMSE <- sum((x - X)^2) / sum((x - mean(x))^2)
  
  # Reduction of Error, also known as Nash-Sutcliffe coefficient 
  return$RE <- 1 - return$NMSE
  
  # Root Mean Square Error, also known as Root Mean Square Deviations
  return$RMSE <- sqrt(return$MSE)
  
  # Normalized Root Mean Square Deviations 
  return$NRMSD <- 100 * (return$RMSE / (max(x) - min(x)))
  
  # Root Mean Square Standardized Error 
  if (sd(x) != 0) {
    return$RMSS <- sqrt(1 / n * sum(( (X-x)/sd(x) )^2))  
  } else {
    return$RMSS <- NA 
  }
  
  
  return(return)
}

# load packages
library(tsinterp)
library(imputeTS)
library(zoo)
library(forecast)
library(MASS)

# set seed for reproducibility
set.seed(21)

# define time series
original_series <- list()
original_series[[1]] <- as.ts(airquality$Temp)
original_series[[2]] <- sunspots
original_series[[3]] <- as.ts(flux$PentOrig)
ts_names <- c("airquality Temp", 
              "sunspots",
              "flux Penticton")

# impose gaps on series
gaps <- list()
gapped_series <- list()
for (i in 1:length(original_series)) {
  n <- length(original_series[[i]])
  gaps[[i]] <- sample(2:(n - 1), floor(0.05 * n), replace = FALSE) # note: change 0.05 to whichever gap level you want
  gapped_series[[i]] <- original_series[[i]]
  gapped_series[[i]][gaps[[i]]] <- NA
}

algorithm_names <- c("Nearest Neighbor",
                     "Linear Interpolation", 
                     "Natural Cubic Spline",
                     "FMM Cubic Spline", 
                     "Hermite Cubic Spline",
                     "Stineman Interpolation",
                     "Kalman - ARIMA",
                     "Kalman - StructTS",
                     "Last Observation Carried Forward",
                     "Next Observation Carried Backward", 
                     "Simple Moving Average", 
                     "Linear Weighted Moving Average",
                     "Exponential Weighted Moving Average",
                     "Replace with Mean",
                     "Replace with Median", 
                     "Replace with Mode",
                     "Replace with Random",
                     "Hybrid Wiener Interpolator")
algorithm_calls <- c("nearestNeighbor(", 
                     "na.approx(", 
                     "na.spline(method = 'natural', object = ",
                     "na.spline(method = 'fmm', object = ", 
                     "na.spline(method = 'monoH.FC', object = ", 
                     "na.interpolation(option = 'stine', x = ", 
                     "na.kalman(model = 'auto.arima', x = ", 
                     "na.kalman(model = 'StructTS', x = ",
                     "imputeTS::na.locf(option = 'locf', x = ", 
                     "imputeTS::na.locf(option = 'nocb', x = ", 
                     "na.ma(weighting = 'simple', x = ",
                     "na.ma(weighting = 'linear', x = ", 
                     "na.ma(weighting = 'exponential', x = ",
                     "na.mean(option = 'mean', x = ", 
                     "na.mean(option = 'median', x = ",
                     "na.mean(option = 'mode', x = ", 
                     "na.random(",
                     "interpolate(gap = gaps[[j]], progress = FALSE, z = ")
performance <- list()
for (i in 1:length(algorithm_names)) {
  performance[[i]] <- list()
  names(performance)[i] <- algorithm_names[i]
  for (j in 1:length(original_series)) {
    function_call <- paste(algorithm_calls[i], "gapped_series[[j]]", ")", sep = "")
    if (algorithm_names[i] == "Hybrid Wiener Interpolator"){
      interpolated_series <- paste(function_call, "[[1]]", sep = "")
      performance[[i]][[j]] <- eval_performance(eval(parse(text = interpolated_series)), original_series[[j]])  
    } else {
      performance[[i]][[j]] <- eval_performance(eval(parse(text = function_call)), original_series[[j]])  
    }
    names(performance[[i]])[j] <- ts_names[j]
  }
}

# note: change the 0.05 to whichever level you used. 
# Don't accidentally write over your files! 
setwd("~/School/Trent/Fourth Year/MATH4800/Performances")
performance_0.05 <- performance
save(performance_0.05, file = "performance_0.05.RDa")

performance_matrices <- list()
for (k in 1:17) {
  df <- data.frame(matrix(nrow = length(algorithm_names),
                          ncol = length(original_series)))
  rownames(df) <- algorithm_names
  colnames(df) <- ts_names
  for (i in 1:length(algorithm_names)) {
    for (j in 1:length(original_series)) {
      df[i, j] <- performance[[i]][[j]][k]
    }
  }
  performance_matrices[[k]] <- df
}
# again, change 0.05 to whichever gap level you used
# don't accidentally write over your files
performance_matrices_0.05 <- performance_matrices
save(performance_matrices_0.05, file = "performance_matrices_0.05.RDa")

# find which ones performed best and worst 
best_performance <- data.frame(matrix(nrow = 17, 
                                      ncol = length(original_series)))
worst_performance <- data.frame(matrix(nrow = 17, 
                                       ncol = length(original_series)))
rownames(best_performance) <- names(performance[[1]][[1]])
colnames(best_performance) <- ts_names
rownames(worst_performance) <- names(performance[[1]][[1]])
colnames(worst_performance) <- ts_names
for (k in 1:17) {
  for (j in 1:length(original_series)) {
    if (k == 7 | k == 8 | k == 9 | k == 12) {  # omit ones where we have NaNs 
      best_performance[k, j] <- NA
      worst_performance[k, j] <- NA
    } else {
      if (k == 1 | k == 2 | k == 14) {
        index_best <- which.max(performance_matrices[[k]][ , j])
        index_worst <- which.min(performance_matrices[[k]][ , j])
      } else { 
        index_best <- which.min(performance_matrices[[k]][ , j])
        index_worst <- which.max(performance_matrices[[k]][ , j])
      }
      best_performance[k, j] <- rownames(performance_matrices[[k]])[index_best]
      worst_performance[k, j] <- rownames(performance_matrices[[k]])[index_worst]
    }
  }
}
# again, change 0.05 to whichever gap level you used
# don't accidentally write over your files
best_performance_0.05 <- best_performance
worst_performance_0.05 <- worst_performance
save(best_performance_0.05, file = "best_performance_0.05.RDa")
save(worst_performance_0.05, file = "worst_performance_0.05.RDa")

# Now let's load all of them back in. 
setwd("C:/Users/Melissa/School/Trent/Fourth Year/MATH4800/Performances")
for (i in 1:length(list.files())) {
  load(list.files()[i])  
}

# Determine which algorithm performed the "best" for each of the datasets
# at each of the gap levels
gap_levels <- c("0.05", "0.10", "0.15", "0.20", "0.25")
library(plyr)
best <- data.frame(matrix(nrow = length(gap_levels),
                          ncol = length(ts_names)))
rownames(best) <- gap_levels
colnames(best) <- ts_names
worst <- data.frame(matrix(nrow = length(gap_levels),
                           ncol = length(ts_names)))
rownames(worst) <- gap_levels
colnames(worst) <- ts_names
# get frequency of each element in the "sunspots" column of the best_performance_0.05 data.frame
# then take the one which had the highest frequency 
for (l in 1:length(gap_levels)) {
  for (j in 1:length(ts_names)) {
    freqs <- count(eval(parse(text = paste("best_performance_", gap_levels[l], sep = ""))), j)
    # get rid of the NA row
    freqs <- freqs[-which(is.na(freqs[[1]])),]
    best[l, j] <- freqs[[1]][which.max(freqs[[2]])]
    freqs <- count(eval(parse(text = paste("worst_performance_", gap_levels[l], sep = ""))), j)
    # get rid of the NA row
    freqs <- freqs[-which(is.na(freqs[[1]])),]
    worst[l, j] <- freqs[[1]][which.max(freqs[[2]])]
  }
}
save(best, file = "best.RDa")
save(worst, file = "worst.RDa")
