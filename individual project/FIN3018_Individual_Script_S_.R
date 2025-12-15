library(xts)
library(fpp2)
library(urca)
library(fGarch) 
library(ggplot2)  
library(forecast)

################################################################################
#DATA COMPARISON
################################################################################

# Load Data
period_1_data <- read.csv("Period 1.csv", header = TRUE)

# Format Date
period_1_data$Date <- as.Date(period_1_data$Date, format = "%d/%m/%Y")

# Create time series
xts_index <- xts(period_1_data$S.P.500.Industrials, order.by = period_1_data$Date)
head(xts_index)


###### Creating plots for index and log return(full series)

# Create plot for S&P 500 Industrials Index
plot(xts_index,
     col = "darkblue",
     lwd = 1,
     ylab = "Index Price",
     xlab = "Date",
     main = "S&P 500 Industrials Index")

# Calculate log return
xts_log_returns <- 100*diff(log(xts_index))
xts_log_returns <- na.omit(xts_log_returns)

# Create plot for log returns
plot(xts_log_returns,
     col = "darkblue",
     lwd = 1,
     ylab = "Log return (%)",
     xlab = "Date",
     main = "S&P 500 Industrials Log Returns")

# Create training and testing sets for Index (80%train 20%test)
index_train <- window(xts_index, end = '2009-7-20')
index_test <- window(xts_index, start = '2009-7-21')

# Create training and testing sets for log returns
log_returns_train <- window(xts_log_returns, end = '2009-7-20')
log_returns_test <- window(xts_log_returns, start = '2009-7-21') 



######Stationary Tests(Training set)

#### Index value training set 
# Creating Index training set plot 
plot(index_train, main = "Index training data plot")

# Creating ACF plot of index value 
acf(index_train, main = "Index training data ACF")

# Creating PACF plot of index value
pacf(index_train, main = "Index traing data PACF")

# Using Dickey-Fuller test in index value
summary(ur.df(index_train, type = "trend"))


#### Log returns training set
# Creating Log returns set plot
plot(log_returns_train, main = "Log returns training data plot")

# Creating ACF plot of log returns
acf(na.omit(log_returns_train), main = "Log returns training data ACF")

# Creating PACF plot of log returns
pacf(na.omit(log_returns_train), main = "Log returns training data PACF")

# Using Dickey-Fuller test in log returns
summary(ur.df(na.omit(log_returns_train), type = "none"))


################################################################################
#ARIMA ESTIMATION AND FORECASTING 
################################################################################
arima_individual <- Arima(index_train, order = c(2,1,2))

# Show the coefficients of the model
summary(arima_individual)


#### Residuals analysis
# Check residuals
checkresiduals(arima_individual)


#### Forecasts
h_arima <- length(index_test)
fcast_arima_individual <- forecast(arima_individual, h = h_arima)

#### Data Visualization

# Create xts objects for the forecast
fcast.xts <- xts(fcast_arima_individual$mean, order.by = index(index_test))
predictioninterval.low <- xts(fcast_arima_individual$lower[,2], order.by = index(index_test))
predictioninterval.high <- xts(fcast_arima_individual$upper[,2], order.by = index(index_test))

# Merge all data
full.xts <- merge(xts_index,
                  fcast.xts,
                  predictioninterval.low,
                  predictioninterval.high)

# Plot using ggplot and geom_ribbon
ggplot(full.xts) +
  # Plot for Full time series of index values
  geom_line(aes(x = index(full.xts), y = xts_index), colour = "black") +
  
  # Plot for Forecasted index values
  geom_line(aes(x = index(full.xts), y = fcast.xts), colour = "red") +
  
  # Plot for 95% prediction intervals
  geom_ribbon(aes(x = index(full.xts),
                  ymin = predictioninterval.low,
                  ymax = predictioninterval.high),
              fill = "blue", alpha = 0.2) +
  
  labs(title = "ARIMA(2,1,2) Forecast for S&P 500 Industrials",
       x = "Date",
       y = "Index Price") +
  theme_minimal()

#### Calculate forecast accuracy
accuracy(fcast_arima_individual, index_test)


################################################################################
#GARCH ESTIMATION AND FORECASTING
################################################################################

# Estimate GARCH(1,1) model
log_returns_train_decimals <- as.numeric(na.omit(log_returns_train))
log_returns_test_decimals <- as.numeric(na.omit(log_returns_test)) 

garch_individual <- garchFit(formula = ~ garch(1,1),
                             data = log_returns_train_decimals,
                             trace = FALSE)

# Show the coefficients of the model
summary(garch_individual)


#### Residuals analysis
garch_residuals <- residuals(garch_individual, standardize = TRUE)

# ACF of standardized residuals
acf(garch_residuals, main = "GARCH Standardized Residuals ACF")

# ACF of squared standardized residuals 
acf(garch_residuals^2, main = "GARCH Squared Standardized Residuals ACF")


#### Forecasts
h_garch <- length(log_returns_test_decimals)

fcast_garch_individual <- predict(garch_individual, n.ahead = h_garch, plot = FALSE)


#### Data Visualization
# Extract forecast values
forecast_return <- fcast_garch_individual$meanForecast
forecast_std_dev <- fcast_garch_individual$standardDeviation

# Calculate 95% prediction intervals
upper_pi <- forecast_return + 1.96 * forecast_std_dev
lower_pi <- forecast_return - 1.96 * forecast_std_dev

# Create xts objects for plotting
full_log_returns <- rbind(log_returns_train, log_returns_test) 
colnames(full_log_returns) <- "actual"

test_dates <- index(log_returns_test) 


forecast_xts <- xts(forecast_return, order.by = test_dates) 
colnames(forecast_xts) <- "forecast"
upper_xts <- xts(as.matrix(upper_pi), order.by = test_dates)
colnames(upper_xts) <- "upper"
lower_xts <- xts(as.matrix(lower_pi), order.by = test_dates)
colnames(lower_xts) <- "lower"


# Combine all data
full_xts_garch <- merge(full_log_returns, forecast_xts, lower_xts, upper_xts)

# Plot for GARCH (1,1)

ggplot(full_xts_garch) +
  geom_line(aes(x = index(full_xts_garch), y = actual), colour = "black") +
  
  geom_line(aes(x = index(full_xts_garch), y = forecast), colour = "red") +
  
  geom_line(aes(x = index(full_xts_garch), y = lower), colour = "blue") + 
  
  geom_line(aes(x = index(full_xts_garch), y = upper), colour = "blue") + 
  labs(title = "GARCH(1,1) Forecast for S&P 500 Industrials Log Returns",
       x = "Date",
       y = "Log Return (%)") +
  theme_minimal()


#### Calculate forecast accuracy
accuracy(f = forecast_return, x = log_returns_test_decimals)

