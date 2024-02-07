# Load in data
#source("001_data_processing.R")


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
                            lang_athome > 76 ~ "DK/Skipped/Refused"),
  gender_l = case_when(gender == 0 ~ "Unknown",
                       gender == 1 ~ "Male",
                       gender == 2 ~ "Female")
)


# Calculating household income brackets  -----------------------------

df <- df |>
  mutate(income_upper = case_when(
    income == 1 ~ 4999,
    income == 2 ~ 9999,
    income == 3 ~ 14999,
    income == 4 ~ 19999,
    income == 5 ~ 24999,
    income == 6 ~ 29999,
    income == 7 ~ 34999,
    income == 8 ~ 39999,
    income == 9 ~ 49999,
    income == 10 ~ 59999,
    income == 11 ~ 74999,
    income == 12 ~ 84999,
    income == 13 ~ 99999,
    income == 14 ~ 124999,
    income == 15 ~ 149999,
    income == 16 ~ 174999,
    income == 17 ~ 199999,
    income == 18 ~ 1000000
  ),
  income_lower = case_when(
    income == 1 ~ 0,
    income == 2 ~ 5000,
    income == 3 ~ 10000,
    income == 4 ~ 15000,
    income == 5 ~ 20000,
    income == 6 ~ 25000,
    income == 7 ~ 30000,
    income == 8 ~ 35000,
    income == 9 ~ 40000,
    income == 10 ~ 50000,
    income == 11 ~ 60000,
    income == 12 ~ 75000,
    income == 13 ~ 85000,
    income == 14 ~ 100000,
    income == 15 ~ 125000,
    income == 16 ~ 150000,
    income == 17 ~ 175000,
    income == 18 ~ 200000
  ),
  monthly_income_u = income_upper/12,
  monthly_income_l = income_lower/12
  )


# Creating snap income eligibility limits
hhsize <- c(1, 2, 3,4,5,6)
income_criteria <- c(1580,2137,2694,3250,3807,4364)
snap <- data.frame(hhsize, income_criteria)

# Adding to dataframe
df <- df |> right_join(snap, df,  by = "hhsize") |>
 mutate(snap_elig = ifelse(monthly_income_l < income_criteria, 1, 0))


