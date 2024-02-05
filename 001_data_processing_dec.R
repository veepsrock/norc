library(tidyverse)
library(haven)
library(janitor)
library(expss)
library(survey)


# Read in data -------------------------------------------------------------------

df <- read_sav("data/dec/Amplify AAPI_M4 December 2023 Final Data.sav") |> clean_names()

# Write function for recoding likert scale ----------------------------------------


likert_fx <- function(new_col_name, org_col){
 df <- df |> mutate(
   {{new_col_name}} := case_when(
     .data[[org_col]] < 4 ~ 0,
     .data[[org_col]] == 4 ~ 1,
     .data[[org_col]] == 5 ~ 1,
     .data[[org_col]] > 76 ~ 0)
 )
 return(df)
}


# Coding cultural food affinity (cfa)  ----------------------------------------------------

# Responses of “strongly agree” or “somewhat agree” on rock1a and rock1e are scored "high"
# rock1a - At home, I tend to eat foods from my culture
# rock1e - Food from my culture are generally healthier than American food

# recoding likert scores
df <- likert_fx("q1a", "rock1a")
df <- likert_fx("q1e", "rock1e")

# summing across all cultural food affinity (cfa) questions 
df <- df |>
  rowwise() |>
  mutate(cfa_score = sum(c(q1a, q1e), na.rm = T))

# calculate cfa scores 
df <- df |> mutate(
  cfa = case_when(cfa_score > 0 ~ "high",
                  cfa_score == 0 ~ "low"),
  high_cfa = case_when(cfa == "high" ~ 1,
                       cfa == "low" ~ 0)
)

# Coding FIM values  ----------------------------------------------------

# Responses of “strongly agree” or “somewhat agree” on rock1b, rock1c, rock6 are scored "high"
# rock1b - I trust my doctor, or other health professionals, for information on healthy eating
# rock1c - When I am feeling ill, I will eat specific food ingredients to get healthy
# rock6 -  I believe food is healing/good for my body

# recoding likert scores
df <- likert_fx("q1b", "rock1b")
df <- likert_fx("q1c", "rock1c")
df <- likert_fx("q6", "rock6")

# summing across all FIM values 
df <- df |>
  rowwise() |>
  mutate(fim_vals_score = sum(c(q1b, q1c, q6), na.rm = T))

# calculate FIM values
df <- df |> mutate(
  fim_vals = case_when(fim_vals_score > 0 ~ "high",
                       fim_vals_score == 0 ~ "low"),
  high_fim_vals = case_when(fim_vals == "high" ~ 1,
                            fim_vals == "low" ~ 0)
)

# Coding perception for FIM  ----------------------------------------------------

# Responses of “strongly agree” or “somewhat agree” on rock7a, rock7b, rock7c, rock 7d, rock7e are scored "high"
# rock7a - Providing more nutrition counseling to patients
# rock7b - Teaching patients to cook
# rock7c -  Helping pay for healthier food in grocery stores, supermarkets, and/or farmers' markets for patients with appropriate medical conditions
# rock 7d - Having on-site food grocery or pantry pick-up locations for healthier food for patients with appropriate medical conditions
# rock 7e - Helping to pay for delivery of healthy groceries or meals to homes of patients with appropriate medical conditions

# recoding likert scores
df <- likert_fx("q7a", "rock7a")
df <- likert_fx("q7b", "rock7b")
df <- likert_fx("q7c", "rock7c")
df <- likert_fx("q7d", "rock7d")
df <- likert_fx("q7e", "rock7e")


# summing across all FIM perception questions 
df <- df |>
  rowwise() |>
  mutate(fim_q_score = sum(c(q7a, q7b, q7c, q7d, q7e), na.rm = T))

# calculate FIM values
df <- df |> mutate(
  fim = case_when(fim_q_score > 1 ~ "high",
                       fim_q_score < 2 ~ "low"),
  high_fim = case_when(fim == "high" ~ 1,
                        fim == "low" ~ 0)
)


# summing across all FIM values 
df <- df |>
  rowwise() |>
  mutate(fim_vals_score = sum(c(q1b, q1c, q6), na.rm = T))

# calculate FIM values
df <- df |> mutate(
  fim_vals = case_when(fim_vals_score > 0 ~ "high",
                       fim_vals_score == 0 ~ "low"),
  high_fim_vals = case_when(fim_vals == "high" ~ 1,
                            fim_vals == "low" ~ 0)
)


# Calculating household income brackets  -----------------------------

df <- df |>
  mutate(income_bracket = case_when(
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
    income == 18 ~ 200000
  ),
  hh_income = income_bracket/hhsize,
  hh_income_m = hh_income/12
  )