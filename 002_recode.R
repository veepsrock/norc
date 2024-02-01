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
                       region4 == 4 ~ "West"),
  snap = case_when(q9 == 1 ~ "Enrolled in past",
                   q9 == 2 ~ "Currently enrolled",
                   q9 == 3 ~ "Not enrolled",
                   q9 == 77 ~ "I don't know",
                   q9 >97 ~ "Skipped/Refused"
                   ),
  internet_l = case_when(internet == 0 ~ "Non-internet household",
                         internet == 1 ~ "Internet household"),
  metro_l = case_when(metro == 0 ~ "Non-Metro Area",
                      metro == 1 ~ "Metro Area"),
  lang_athome_l = case_when(lang_athome ==  1 ~"English",
                            lang_athome ==  2 ~"Chinese",
                            lang_athome ==  3 ~"Korean",
                            lang_athome ==  4 ~"Tagalog",
                            lang_athome ==  5 ~"Vietnamese",
                            lang_athome ==  6 ~"Other Language",
                            lang_athome > 76 ~ "DK/Skipped/Refused")
)


# Get binary values for access to SNAP  -----------------------------
# 1 means currently enrolled or has enrolled previously
# 0 No or don't know
