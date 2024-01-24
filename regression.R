#Set up correct working directory 
setwd("/Users/torchi/Documents/GitHub/norc")

source("001_data_processing.R")
source("002_recode.R")

library(ggplot2)
library(glmnet)
library(stargazer)

head(df)
##Linear Regression

#Age as continuous variable (probably better to do logistic or non-linear regression)
lm1 <- lm(age ~ low_fs + income, data = df)
stargazer(lm1, type = "text", title = "Linear Regression Summary")

ggplot(df, aes(x = low_fs, y = age)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Linear Regression", x = "Independent Variable", y = "Dependent Variable")

#Conclusion: The low R-squared and adjusted R-squared suggests that this model does not explain the population very well.
#Standard error is high and with an F-stat close to 1 we can conclude that this model is not very statistically significant overall

##Logistic Regression 

#Age vs low_fs 

logit_model1 <- glm(low_fs ~ age, data = df, family = "binomial")
stargazer(logit_model1, type = "text", title = "Logistic Regression Summary")

ggplot(df, aes(x = age, y = low_fs)) +
  geom_point() +
  stat_smooth(method = "glm", family = "binomial", se = FALSE, color = "blue") +
  labs(title = "Logistic Regression", x = "Independent Variable", y = "Binary Dependent Variable")

#Conclusion: Very slight negative relationship as age increases, but not statistically significant. For every one unit increase in age, there is .02% decrease in low_fs
#Log likelihood indicates this model fits the dataset well, may be overfitting

#Using low_fs we can compare how much of a correlation there is with other listed in the questionnaire. Opting to control for age and income. 

#q8a:Healthy foods are too expensive (often/sometimes true, never true, etc.)
logit_model2 <- glm(low_fs ~ q8a + age + income, data = df, family = "binomial")
stargazer(logit_model2, type = "text", title = "Logistic Regression Summary")

#q1b:We couldn't afford to eat balanced meals (often/sometimes true, never true, etc.)
#Shows significant negative relationship between responses for q1b (I believe responses associated with a higher number) and low_fs
logit_model3 <- glm(low_fs ~ q1b + age + income, data = df, family = "binomial")
stargazer(logit_model3, type = "text", title = "Logistic Regression Summary")

#q5: In the last 12 months, did you ever eat less than you felt you should because there wasn't enough money for food?
#Significant negative correlation for q5 and income 
logit_model4 <- glm(low_fs ~ q5 + age + income, data = df, family = "binomial")
stargazer(logit_model4, type = "text", title = "Logistic Regression Summary")
