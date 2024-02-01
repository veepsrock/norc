# Load in data
source("001_data_processing.R")


# Recode values
df <- df |> mutate(
  age4_l= case_when(age4 ==1 ~ "18-29",
                  age4 ==2 ~ "30-44",
                  age4 ==3 ~ "45-59",
                  age4 ==4 ~ "60+",
                  age4 == 9 ~ "Under 18"
  ),
  asianorigin_l = case_when(asianorigin ==1 ~ "Chinese",
                          asianorigin ==2 ~ "Asian Indian",
                          asianorigin ==3 ~ "Filipino",
                          asianorigin ==4 ~ "Vietnamese",
                          asianorigin ==5 ~ "Korean",
                          asianorigin ==6 ~ "Japanese",
                          asianorigin ==7 ~ "NHPI",
                          asianorigin ==8 ~ "Other singular AAPI",
                          asianorigin ==9 ~ "Multiple AAPI"),
  coo_l = case_when(coo == 1 ~ "In the US",
                  coo == 2 ~ "Outside the US",
                  coo > 2 ~ "Don't know/Skipped/Refused"),
  income4_l = case_when(income4 == 1 ~ "Less than $30,000",
                        income4 == 2 ~ "$30,000 to under $60,000",
                        income4 == 3 ~ "$60,000 to under $100,000",
                        income4 == 4 ~ "100,000 or more"),
  region4_l = case_when(region4 == 1 ~ "Northeast",
                       region4 == 2 ~ "Midwest",
                       region4 == 3 ~ "South",
                       region4 == 4 ~ "West")
)
