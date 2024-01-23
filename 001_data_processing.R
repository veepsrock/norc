library(tidyverse)
library(haven)
library(janitor)
library(expss)
library(survey)


# Read in data -------------------------------------------------------------------

df <- read_sav("data/nov/[9800] Amplify AAPI M3 November 2023 - Final Data - 20240109.sav") |> clean_names()

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

# Calculate food security status
df <- df |> mutate(
  fs = case_when(score <2 ~ "high",
                 score > 1 ~ "low")
)

# Coding nutrition security status ----------------------------------------------------

# Response of "hard" or "somewhat" hard on question 7 considered low nutrition security 
df <- df |> mutate(
  ns = case_when(q7 <4 ~ "low",
                 q7 == 4 ~ "high",
                 q7 == 5 ~ "high")
)


# Get binary values for low food security and low nutrition security -----------------------------
# 1 means low security
# 0 means high security 

df <- df |>
  mutate(low_fs = case_when(fs == "low" ~ 1,
                            fs == "high" ~ 0),
         low_ns = case_when(ns == "low" ~ 1,
                            ns == "high" ~ 0))

