Time Series Interpolation Algorithms
========================================================
author: Melissa Van Bussel
date: February 25th, 2019
autosize: false



Time Series
========================================================

- A sequence of observations, $\{X_t\}$,  one taken at each time $t$ and arranged in chronological order
- Stock market predictions, weather forecasting, natural disaster prediction / prevention
- Typically make the assumption of evenly spaced observations

<img src="testingtalk-figure/unnamed-chunk-1-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

Trends
==========================================================

<img src="testingtalk-figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

Trends
==========================================================

<img src="testingtalk-figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

Trends
==========================================================

<img src="testingtalk-figure/unnamed-chunk-4-1.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />

Removing Trends
==========================================================

- Trends can be removed by *differencing* or by taking transformations

Removing Exponential Trends
==========================================================

<img src="testingtalk-figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />

Removing Linear Trends: Differencing
==========================================================

<img src="testingtalk-figure/unnamed-chunk-6-1.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

Why would we want to remove trends?
==========================================================

- We want to predict future observations
- which... means we need to model past observations 
- and... to model past observations requires *stationarity*

Stationary Processes
==========================================================

- Roughly speaking, a stationary process is one which isn't a function of time.
- Formally: A process $Y_1, Y_2, ...$ is weakly stationary iff: 

$$
\begin{split}
&\text{1. } \textbf{E}[Y_t] = \mu \quad \forall t \\
&\text{2. } \textbf{Var}[Y_t] = \sigma^2 \quad \forall t, \sigma^2 < \infty \\
&\text{3. } \textbf{Cov}[Y_t, Y_s] = \gamma(|t - s|) \quad \forall t,s \text{ for some } \gamma(h) \\ 
\end{split}
$$

where $\gamma(h)$ is the autocovariance function. 

Time for a Diagram!
=========================================================

- On the chalkboard!

An example of a stationary process: White Noise
=========================================================

- WN processes have two parameters: $\mu$ and $\sigma^2$

<img src="testingtalk-figure/unnamed-chunk-7-1.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" style="display: block; margin: auto;" />

An example of a non-stationary process: Random Walks
=========================================================

- We don't have time to go into details, but for those of you who remember random walks from previous courses: they're non-stationary. 

<img src="testingtalk-figure/unnamed-chunk-8-1.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />

The Autoregressive (AR) Model
==========================================================

- AR is an entire family of processes
- We consider the simplest case: AR(1)
- An AR(1) process regresses the current observation on the previous observation.

AR(1) Processes
==========================================================

A process $Y_1, Y_2$, ... is an AR(1) process if: 

$$
Y_t - \mu = \phi (Y_{t-1} - \mu) + \epsilon_t, \quad \epsilon_t \sim WN(\mu, \sigma_{\epsilon}^2)
$$

- We won't go too deep into the details due to time constraints, but we will model a time series using an AR(1) process

Modeling and Forecasting using an AR(1) Model
==========================================================

- Consider a series that contains the US inflation rate by month
- Load the data: 


```r
data(Mishkin, package = "Ecdat")
inflation <- Mishkin[, 1]
```

Modeling and Forecasting using an AR(1) Model
==========================================================

- Fit the AR(1) Model to it: 
<small>

```r
AR1_inflation <- arima(inflation, order = c(1, 0, 0))
AR1_inflation
```

```

Call:
arima(x = inflation, order = c(1, 0, 0))

Coefficients:
         ar1  intercept
      0.5960     3.9745
s.e.  0.0364     0.3471

sigma^2 estimated as 9.713:  log likelihood = -1255.05,  aic = 2516.09
```
</small>
Modeling and Forecasting using an AR(1) Model
==========================================================

- Plot the original series and the AR(1) Model on top of it:


```r
fitted_vals <- inflation - residuals(AR1_inflation)
plot(inflation, main = "US Monthly Inflation Rates",
     xlim = c(1950, 1991))
lines(fitted_vals, type = "l",
      ylab = "Inflation Rate",
      col = "red",
      lty = 2)
legend("topright",
       legend = c("Y", "Yhat"),
       col = c("black", "red"),
       lty = c(1, 2))
```

Modeling and Forecasting using an AR(1) Model
==========================================================

<img src="testingtalk-figure/unnamed-chunk-12-1.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />

Modeling and Forecasting using an AR(1) Model
==========================================================

<small style = "font-size:0.7em">

```r
AR_forecast <- predict(AR1_inflation, n.ahead = 12)$pred
AR_forecast_se <- predict(AR1_inflation, n.ahead = 12)$se
plot(inflation, main = "US Monthly Inflation Rates",
     xlim = c(1980, 1991),
     ylab = "Inflation Rate")
lines(fitted_vals, type = "l",
      col = "red",
      lty = 2)
points(AR_forecast, type = "l", col = "blue")
points(AR_forecast - 1.96 * AR_forecast_se, 
       type = "l", col = "blue", lty = 2)
points(AR_forecast + 1.96 * AR_forecast_se, 
       type = "l", col = "blue", lty = 2)
legend("topright",
       legend = c("Y", "Yhat", "Forecasted Values", "95 percent CI"),
       col = c("black", "red", "blue", "blue"),
       lty = c(1, 2, 1, 2),
       cex = 0.8)
```
</small>

Modeling and Forecasting using an AR(1) Model
==========================================================

<img src="testingtalk-figure/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />

ARIMA Models
==========================================================

- The example we just did was very simplistic
- Typically use ARMA or ARIMA models

So...what's the project?
========================================================

- As we just saw, it's really easy to model stationary time series
- It's a few lines of code
- But...not all data is nice

What's happening here?
========================================================



<img src="testingtalk-figure/unnamed-chunk-16-1.png" title="plot of chunk unnamed-chunk-16" alt="plot of chunk unnamed-chunk-16" style="display: block; margin: auto;" />

Why else might there be missing values?
==========================================================

- Dealing with these missing values is the goal of this Honours Project

Ok, so, why'd you bother talking about stationarity?
==========================================================

- In reality, it's rare to have stationary processes.
- That's fine, because you can transform non-stationary processes into stationary processes
- BUT, how do you interpolate missing values in non-stationary processes?

Current Problems
==========================================================

- Not many algorithms that address non-stationary data 
- Many algorithms are not implemented / freely available  
- Performance of these algorithms has been evaluated inconsistently 
- "Cherry Picking" (criteria, and example series)

Goals 
==========================================================

- Implement existing interpolation algorithms in R, create open source / freely available package
- Test a variety of interpolation algorithms on both simulated and real-world data (non-stationary)
- Evaluate performance of algorithms with a number of criteria instead of just one
- Algorithm of particular interest is written by our very own Wes
- Sophie will explore this topic in much more depth for her thesis

References
==========================================================

- Wesley S. Burr. Air Pollution and Health: Time Series Tools and Analysis. Queen's University, PhD thesis. 2012.

- Wesley S. Burr (2012). `tsinterp`: A Time Series Interpolation Package for `R`. R Package.

- Mathieu Lepot, Jean-Baptiste Aubin, and Francois H.L.R. Clemens. Interpolation in Time Series: An Introductive Overview of Existing Methods, Their Performance and Uncertainty Assessment. Water 2017, 9(10), 796.

- DataCamp. "Introduction to Time Series Analysis" and "ARIMA Modeling with R".
