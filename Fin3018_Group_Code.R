library(xts)
library(fpp2)
library(urca)
library(vars)


################################################################################
## Data Analysis

################################################################################

################################################################################
## Download and format data
################################################################################

#Save data and R to same location then set working directory to source file to run code

#Download data
Period_3 <- read.csv("Period 3.csv", header = TRUE)

#format date
Period_3$Date <- as.Date(Period_3$Date, format = "%d/%m/%Y")

#Format as time series (xts)
xts_MSCI_Index <- xts(Period_3$MSCI.World.Index.USD, order.by = Period_3$Date)
head(xts_MSCI_Index)

################################################################################
## Plots for Index and Log returns
################################################################################

#Plot for Index
plot(xts_MSCI_Index,
     col = "steelblue",
     lwd = 1,
     ylab = "Index Price",
     xlab = "Date",
     main = "MSCI World Index")

#Create log returns
log_returns <- xts(100 * diff(log(xts_MSCI_Index)))

#Creating a plot for log returns
plot(log_returns,
     col = "steelblue",
     lwd = 1,
     ylab = "Logarithm Return(%)",
     xlab = "Date",
     main = "MSCI World Index log returns ")

################################################################################
## Split to Train and test data
################################################################################

xts_MSCI_Index_train <- window(xts_MSCI_Index, end = '2024-08-08')
xts_MSCI_Index_test <- window(xts_MSCI_Index, start = '2024-08-09')

log_returns_train <- window(log_returns, end = '2024-08-08')
log_returns_test <- window(log_returns, start = '2024-08-09')


################################################################################
## Plots of Train
################################################################################
# plots

#Creating a plot for log returns
plot(xts_MSCI_Index_train,
     col = "steelblue",
     lwd = 1,
     ylab = "Index Price",
     xlab = "Date",
     main = "MSCI World Index Train results")

#Creating a plot for log returns
plot(log_returns_train,
     col = "steelblue",
     lwd = 1,
     ylab = "Log Returns(%)",
     xlab = "Date",
     main = "Log Returns Train results")


################################################################################
## Autocorrelation 
################################################################################

# ACF & PACF plots
acf(xts_MSCI_Index_train)
pacf(xts_MSCI_Index_train)

acf(na.omit(log_returns_train))
pacf(na.omit(log_returns_train))

################################################################################
##Dickey fuller test
################################################################################

ur.df(xts_MSCI_Index_train, type = "none")
#The Value of the test statistic is: 1.5087 with critical value -2.86

ur.df(xts_MSCI_Index_train, type = "trend")
#The test statistic is: -2.5211, 3.0245, 3.2136 with critical value -3.43

ur.df(na.omit(log_returns_train, type = "none"))
#The test statistic is: -13.8987 with critical value -2.86
ur.df(na.omit(log_returns_train, type = "trend"))
#The test statistic is: -13.8987 with critical value -3.43




################################################################################
## ARIMA Estimation and Forecasting

################################################################################

################################################################################
##Arima models
################################################################################

arima.auto <- auto.arima(xts_MSCI_Index_train)
#arima.auto AIC 3618.31 , BIC 3642.27
arima.ar1 <- Arima(xts_MSCI_Index_train, order = c(1,1,0))
#arima.ar1 AIC 3625.74, BIC 3633.72
arima.ar <- Arima(xts_MSCI_Index_train, order = c(1,0,0))
#arima.ar AIC 3648.46, BIC 3660.45

################################################################################
##Residuals
################################################################################

checkresiduals(arima.auto)

checkresiduals(arima.ar1)

checkresiduals(arima.ar)

################################################################################
##forecasts
################################################################################

fcast <- forecast(arima.auto, h = length(xts_MSCI_Index_test))

fcast2 <- forecast(arima.ar1, h = length(xts_MSCI_Index_test))

fcast3 <- forecast(arima.ar, h = length(xts_MSCI_Index_test))

#we only need to plot one of the above that we choose but have all 3 below

################################################################################
##Visualization
################################################################################

#Create prediction intervals
fcast.xts <- xts(fcast$mean, order.by = index(xts_MSCI_Index_test))
predictioninterval.low <- xts(fcast$lower[,2], order.by = index(xts_MSCI_Index_test))
predictioninterval.high <- xts(fcast$upper[,2], order.by = index(xts_MSCI_Index_test))


#merge all required into one xts item

full.xts <- merge(xts_MSCI_Index, fcast.xts,
                  predictioninterval.low, predictioninterval.high)


#data: A black line.

#Forecasted values: A blue line for the predicted future values.

#95% prediction interval: A light blue shaded area 

ggplot(full.xts) +
  geom_line(aes(x=index(full.xts), y=xts_MSCI_Index)) +
  geom_line(aes(x=index(full.xts), y=fcast.xts), colour ="red") +
  geom_ribbon(aes(x = index(full.xts),ymin = predictioninterval.low,
                  ymax = predictioninterval.high), fill = "blue", alpha = 0.2)

################################################################################
##Forecast
################################################################################

#Accuracy test on forecast
accuracy(fcast,xts_MSCI_Index_test)
# RMSE = 172.24
# MAE = 164.41
# MAPE = 4.41


################################################################################
## GARCH

################################################################################
# fitting GARCH (1,1) 

# use fGarch package to model GARCH (1,1) 
install.packages("fGarch") 
library(fGarch) 

# convert to decimals and remove na values as GARCH expects decimals 
log_returns_train_decimals <- na.omit(log_returns_train / 1) 
log_returns_test_decimals <- na.omit(log_returns_test / 1) 


##fit standard GARCH (1,1) 
GARCHMODEL<- garchFit(~ garch(1,1), data = log_returns_train_decimals, trace = FALSE) 

summary(GARCHMODEL) 


#RESULTS 

#mu/ mean- very small 0.0008454, statistically significant at the 5% level 

#variance- omega 3.6e-06, not statistically significant 

#variance- alpha- 0.09 statistically significant, 9% of current volatility comes from new shocks 

#variance- beta 0.84 meaning 84% of volatility comes from yesterday's volatility. this is very strong evidence as it is statistically significant at 0.1% 

#volatility persistence is close to 1 (0.84+0.09=0.93) indicating the volatility is highly persistent 



##forecast the fitted model above, ensuring its the same size as test data 

forecast.GARCHMODEL <- predict(GARCHMODEL, n.ahead = length(log_returns_test_decimals), plot = TRUE) 



##analyse the residuals. ACF of residuals and ACF of squared residuals should be near zero to indicate our model modeled mean and volatility well 

GARCHresiduals <- residuals(GARCHMODEL, standardize = TRUE) 

acf(GARCHresiduals) 

acf(GARCHresiduals^2) 





#from GARCH Model- LJUNG-BOX test- all residuals >0.05b therefore no significant autocorrelation left in residuals and no ARCH effects left. thereforte, mean equation is well specified and volatility is well captured by the model 

#Ljung-Box Test     R    Q(10)  17.7864882 0.058673873 

#Ljung-Box Test     R    Q(15)  22.4167519 0.097332982 

#Ljung-Box Test     R    Q(20)  31.3076337 0.051257969 

#Ljung-Box Test     R^2  Q(10)  16.9469383 0.075546377 

#Ljung-Box Test     R^2  Q(15)  21.3754336 0.125256841 

#Ljung-Box Test     R^2  Q(20)  28.4856736 0.098391724 



##Calculate 95% prediction intervals for your forecasted return using forecasted return ± 1.96 × √forecasted return 

forecastreturn <- forecast.GARCHMODEL$meanForecast 

forecaststd <- forecast.GARCHMODEL$standardDeviation 

upperpredictioninterval <- forecastreturn + 1.96 * forecaststd 

lowerpredictioninterval <- forecastreturn - 1.96 * forecaststd 



################################################################################ 

##GARCH Visualization 

################################################################################ 

library(ggplot2) 

library(xts) 

library(zoo) 

# convert train and test returns to xts

log_returns_train_decimals <- xts(log_returns_train, order.by = index(xts_MSCI_Index_train))
log_returns_test_decimals <- xts(log_returns_test, order.by = index(xts_MSCI_Index_test))

# merge full (train and test) actual log returns into one xts object 
# used rbind as error kept appearign when using c 

fulllogreturns <- rbind(log_returns_train_decimals, log_returns_test_decimals)

colnames(fulllogreturns) <- "actual"


#create xts objects for forecasts and intervals ordered by test set dates 

testdates <- index(log_returns_test_decimals) 

forecastxts <- xts(forecastreturn, order.by = testdates) 
colnames(forecastxts)<- "forecast"

upperintervalxts <- xts(upperpredictioninterval, order.by = testdates) 
colnames(upperintervalxts)<- "upper"

lowerintervalxts <- xts(lowerpredictioninterval, order.by = testdates) 
colnames(lowerintervalxts)<- "lower"

#now merge all required series intoone xts object fullxts

fullxts <- merge(fulllogreturns, forecastxts, lowerintervalxts, upperintervalxts) 

#now plot using ggplot (xts only)

ggplot(fullxts)+
  
  #historical log returns
  
  geom_line(aes(x = index(fullxts), y= actual), colour = "black")+
  
  #forecasted returns
  
  geom_line(aes(x = index(fullxts), y= forecast), colour = "red")+
  
  #lower prediction
  
  geom_line(aes(x = index(fullxts), y = lower), colour = "blue") +
  
  #upper prediction
  
  geom_line(aes(x = index(fullxts), y = upper), colour = "blue") +
  #plot labels
  
  labs(
    title = "GARCH (1,1) Forecast for MSCI World Index Log Returns",
    x= "Date",
    y= "Log Return (%)"
  )+
  
  theme_minimal()

# Calculate measures of forecast accuracy
# Quantified the accuracy of our GARCH model's point forecasts for future log returns.

library(forecast)
forecastaccuracy <- accuracy(f = forecastreturn, x = log_returns_test_decimals)
print(forecastaccuracy)

















