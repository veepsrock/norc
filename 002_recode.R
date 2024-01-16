# Load in data
source("001_data_processing.R")


# Recode values
df <- df |> mutate(
  age4= case_when(age4 ==1 ~ "18-29",
                  age4 ==2 ~ "30-44",
                  age4 ==3 ~ "45-59",
                  age4 ==4 ~ "60+",
                  age4 == 9 ~ "Under 18"
  ),
  asianorigin = case_when(asianorigin ==1 ~ "Chinese",
                          asianorigin ==2 ~ "Asian Indian",
                          asianorigin ==3 ~ "Filipino",
                          asianorigin ==4 ~ "Vietnamese",
                          asianorigin ==5 ~ "Korean",
                          asianorigin ==6 ~ "Japanese",
                          asianorigin ==7 ~ "NHPI",
                          asianorigin ==8 ~ "Other singular AAPI",
                          asianorigin ==9 ~ "Multiple AAPI"
                          
  ),
  coo = case_when(coo == 1 ~ "In the US",
                  coo == 2 ~ "Outside the US",
                  coo > 2 ~ "Don't know/Skipped/Refused"                 
  )
)
