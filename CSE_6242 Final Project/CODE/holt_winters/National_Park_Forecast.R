install.packages('forecast')
library(forecast)
install.packages('xts')
library(xts)
install.packages('dplyr')
library(dplyr)
install.packages('MLmetrics')
library(MLmetrics)

data1 <- read.csv("C:/Users/olivi/Downloads/Data_Final.csv", header=TRUE)

parks <- unique(data1$Name)

parks <- parks[parks != "Channel Islands NP"]
parks <- parks[parks != "Congaree NP"]
parks <- parks[parks != "Gates of the Arctic NP & PRES"]
parks <- parks[parks != "Katmai NP & PRES"]
parks <- parks[parks != "Kenai Fjords NP"]
parks <- parks[parks != "Kobuk Valley NP"]
parks <- parks[parks != "Lake Clark NP & PRES"]
parks <- parks[parks != "Wrangell-St. Elias NP & PRES"]

forecasts_all <- data.frame(matrix(ncol=7, nrow=0))
colnames(forecasts_all)<- c("Point Forecast","Lo 80", "Hi 80", "Lo 95", "Hi 95","Date","Name" )

park_predictions_eval_all <- data.frame(matrix(ncol=6, nrow=0))
colnames(park_predictions_eval_all)<- c("Name","Percent_Difference_Combined", "No_Months_Low_Diff", "alpha","beta", "gamma")

for (park in parks){
  print(park)
  
  # Get data for each individual park as list of parks is looped through
  data1 %>% filter(data1$Name == park) %>% mutate(Visits = ifelse(Visits == 0, 1,Visits)) -> park_data1
  
  # Get the training data
  park_data1 %>% filter(park_data1$Year <= 2018,  park_data1$Year >= 1979) -> park_data2
  
  # Get the test data and align the date format with the Holt Winters output date format
  park_data1 %>% filter(park_data1$Year == 2019 ) -> park_data_2019
  park_data_2019$Date <- as.Date(park_data_2019$Date)
  park_data_2019 %>% mutate(Date = format(park_data_2019$Date,"%b %Y")) -> park_data_2019
  
  # Set timeseries data up for Holt Winters
  park_data2 %>% select(Date, Visits) -> park_data
  timeseries <- ts(park_data[,-1], start=c(1979,1), end=c(2018,12), frequency = 12)
  stl(timeseries, "periodic") -> fit1
  
  # Set up hyperparameter ranges for holt winters variations
  alphas = c(.1,.2,.3,.4,.5,.6,.7,.8,.9)
  betas = c(.1,.2,.3,.4,.5,.6,.7,.8,.9)
  gammas = c(.1,.2,.3,.4,.5,.6,.7,.8,.9)
  
  # Set up dataframe for storing results of variations of holt winters
  best_hyperparameters <- data.frame(matrix(ncol=5, nrow=0))
  colnames(best_hyperparameters)<- c("alpha","beta", "gamma", "Percent_Difference_Combined", "No_Months_Low_Diff")
  
  
  # Run holt winters and compare predictions to actuals for each combination of hyperparameters
  for (i in alphas){
    for (j in betas){
      for (k in gammas){
        # Run holt winters for this combination of hyper parameters and generate forecast
        hw <- HoltWinters(timeseries, seasonal = "multiplicative", alpha=i, beta=j, gamma=k)
        hw_fore <- forecast(hw,60)
        
        # Format forecast as dataframe for comparison to actuals
        as.data.frame(hw_fore) -> hw_fore_df
        hw_fore_df$Date <- rownames(hw_fore_df)
        rownames(hw_fore_df)<-NULL
        
        # Join the predicted dataset with the original data for 2019
        park_data_2019  %>% left_join(hw_fore_df, by='Date') -> joined_actuals_predicted
        joined_actuals_predicted %>% select(Name, Visits, Date, 'Point Forecast') %>% rename(Actuals = Visits, Predicted = 'Point Forecast') -> joined_actuals_predicted
        
        # Get the Percent_Difference between the actual and predicted visitation for each month in 2019
        joined_actuals_predicted %>% mutate(Percent_Difference = abs(Actuals - Predicted)/Actuals) -> joined_actuals_predicted
        
        # Get the mean of the Percent_Difference of each month and get a resulting Percent_Difference_Combined for the year
        # No_Months_Low_Diff is the number of months where the percent difference was less than a certain threshold (here it is 10%)
        park_predictions_eval <- joined_actuals_predicted %>% group_by(Name) %>% summarise(Percent_Difference_Combined = sum(Percent_Difference)/12,
                                                                                           No_Months_Low_Diff = sum(ifelse(abs(Percent_Difference)<.1, 1,0)))
        
        # Store the metrics and hyperparameters so that results can be compared between hyperparameter combinations
        best_hyperparameters<-rbind(best_hyperparameters, c(i,j,k,park_predictions_eval$Percent_Difference_Combined,park_predictions_eval$No_Months_Low_Diff))
        
      }
    }
  }
  
  
  # Find the best combination of hyperparameters by filtering the variations down 
  # first by the percent difference and then by the number of months with a percent difference below the accepted threshold
  colnames(best_hyperparameters)<- c("alpha","beta", "gamma", "Percent_Difference_Combined", "No_Months_Low_Diff")
  best_options <- best_hyperparameters %>% slice_min(Percent_Difference_Combined)
  best_option <-best_options %>% slice_max(No_Months_Low_Diff)
  
  a <- best_option$alpha[1]
  b <- best_option$beta[1]
  c <- best_option$gamma[1]
  
  # Forecast using Holt Winters model with the chosen hyperparameters
  hw <- HoltWinters(timeseries, seasonal = "multiplicative", alpha=a, beta=b, gamma=c)
  hw_fore <- forecast(hw,60)
  
  # Format forecast as dataframe for comparison to actuals
  as.data.frame(hw_fore) -> hw_fore_df
  hw_fore_df$Date <- rownames(hw_fore_df)
  rownames(hw_fore_df)<-NULL
  
  # Join the predicted dataset with the original data for 2019 
  park_data_2019  %>% left_join(hw_fore_df, by='Date') -> joined_actuals_predicted
  joined_actuals_predicted %>% select(Name, Visits, Date, 'Point Forecast') %>% rename(Actuals = Visits, Predicted = 'Point Forecast') -> joined_actuals_predicted
  
  # Get the Percent_Difference between the actual and predicted visitation for each month in 2019
  joined_actuals_predicted %>% mutate(Percent_Difference = abs(Actuals - Predicted)/Actuals) -> joined_actuals_predicted
  
  # Get the mean of the Percent_Difference of each month and get a resulting Percent_Difference_Combined for the year
  # No_Months_Low_Diff is the number of months where the percent difference was less than a certain threshold (here it is 10%)
  park_predictions_eval <- joined_actuals_predicted %>% group_by(Name) %>% summarise(Percent_Difference_Combined = sum(Percent_Difference)/12,
                                                                                     No_Months_Low_Diff = sum(ifelse(abs(Percent_Difference)<.1, 1,0)),
                                                                                     MAPE = MAPE(Predicted, Actuals) )
  
  hw_fore_df$Name <- park
  
  park_predictions_eval$alpha <- a
  park_predictions_eval$beta <- b
  park_predictions_eval$gamma <- c
  
  # Add park's forecast for 2019-2024 to main forecast dataframe
  forecasts_all <- rbind(forecasts_all, hw_fore_df)
  
  # Add park's forecasting results to main evaluation dataframe
  park_predictions_eval_all <- rbind(park_predictions_eval_all, park_predictions_eval)

}

mean(park_predictions_eval_all$Percent_Difference_Combined)
mean(park_predictions_eval_all$No_Months_Low_Diff)
median(park_predictions_eval_all$Percent_Difference_Combined)
median(park_predictions_eval_all$No_Months_Low_Diff)

write.csv(park_predictions_eval_all, "C:/Users/olivi/Downloads/park_predictions_eval.csv")
write.csv(forecasts_all, "C:/Users/olivi/Downloads/park_predictions.csv")

