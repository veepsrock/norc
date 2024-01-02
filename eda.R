library(tidyverse)
library(haven)
library(janitor)


# Read in data -------------------------------------------------------------------

df <- read_sav("data/nov/[9800] Amplify AAPI M3 November 2023 - Final Data.sav") |> clean_names()

 
# Coding food security status ----------------------------------------------------

# Responses of “often” or “sometimes” on questions HH3 and HH4, and “yes” on AD1, AD2, and AD3 are coded as affirmative (yes). Responses of “almost every month” and “some months but not every month” on AD1a are coded as affirmative (yes). The sum of affirmative responses to the six questions in the module is the household’s raw score on the scale.
df <- df |> mutate(hh3 = case_when(q1a <3 ~ 1),
                   hh4 = case_when(q1b <3 ~ 1),
                   ad1 = case_when(q3 == 1 ~ 1),
                   ad1a = case_when(q4 <3 ~ 1),
                   ad2 = case_when(q5 == 1 ~ 1),
                   ad3 = case_when(q6 == 1 ~ 1)) |>
           rowwise() |>
           mutate(score = sum(c(hh3, hh4, ad1, ad1a, ad2, ad3), na.rm = T))

# Get breakdown of scores
df |> count(score)


# Double check breakdown is accurately calculated ----------------------------------------------------

# Getting total values for affirmative 'yes' in original df
sum_df <- df |>
  summarise(
    q1a = sum(q1a < 3, na.rm = T),
    q1b = sum(q1b < 3, na.rm = T),
    q3 = sum(q3 == 1, na.rm = T),
    q4 = sum(q4 < 3, na.rm = T),
    q5 = sum(q5 == 1, na.rm = T),
    q6 = sum(q6 ==1, na.rm = T)
  ) |>
  summarise_all(sum)

# Getting total values for affirmative 'yes' in calculated values
scores_df <- df |> 
  select(hh3, hh4, ad1, ad1a, ad2, ad3) |>
  summarise_all(sum, na.rm = T) |>
  summarise_all(sum)

scores_df 
sum_df
