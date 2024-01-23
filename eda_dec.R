library(tidyverse)
library(haven)
library(janitor)
library(expss)
library(survey)


# Read in data -------------------------------------------------------------------

df <- read_sav("data/dec/Amplify AAPI_M4 December 2023 Final Data.sav") |> clean_names()
colnames(df)
unique(df$state)

# Recode values -------------------------------------------------------------------
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
  ),
  region4 = case_when(region4 == 1 ~ "Northeast",
                      region4 == 2 ~ "Midwest",
                      region4 == 3 ~ "South",
                      region4 == 4 ~ "West",
                      )
)

# Exploring access to cultural foods by state -------------------------------------

df$rock3
unique(df$region4)
colnames(df)

df <- df |> mutate(rock3_s = case_when(rock3 <=2 ~ "Easy",
                                       rock3 == 3 ~ "Not easy",
                                       rock3 == 4 ~ "Not easy",
                                       rock3 == 5 ~ "I don't seek these foods"))

df |> group_by(region4, rock3_s) |> 
  summarise(count = n()) |> 
  group_by(region4)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) |>
  pivot_wider(names_from = region4, values_from = proportional_count, values_fill = 0)
