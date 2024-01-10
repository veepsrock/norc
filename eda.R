library(tidyverse)
library(haven)
library(janitor)
library(expss)
library(survey)


# Read in data -------------------------------------------------------------------

df <- read_sav("data/nov/[9800] Amplify AAPI M3 November 2023 - Final Data - 20240109.sav") |> clean_names()


# Recode demographic values -------------------------------------------------------------------
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

#q7_labels <- c("Very hard", "Hard", "Somewhat hard", "Not very hard", "Not hard at all", "Don't know", "SKIPPED ON WEB", "Refused")
#df$q7 <- q7_labels[df$q7]


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

df |> count(ns)

# Create survey object ----------------------------------------------------
svy <- svydesign(ids=~1, weights = ~weight, data = df)


ao_svy <- svyby(~fs, by = ~asianorigin, design = svy, FUN = svytotal) |> as_tibble()

ao_svy

svyby(~fs, by = ~asianorigin, denominator = ~asianorigin, design = svy, FUN = svyratio) 

df |> group_by(fs, asianorigin) |> 
  summarise(count = n())|> 
  group_by(asianorigin)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count)
# Get demographic breakdown -----------------------------------------------------------

# Age breakdown
age <- df |> group_by(fs, age4) |> 
  summarise(count = n())  |>
  group_by(age4)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) 
  pivot_wider(names_from = age4, values_from = proportional_count, values_fill = 0)
age


# Asian origin breakdown
ao <- df |> group_by(fs, asianorigin) |> 
  summarise(count = n())|> 
  group_by(asianorigin)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) 

ggplot(ao, aes(x=asianorigin, y = proportional_count, fill = fs)) + 
  geom_bar(stat="identity", show.legend=F) + coord_flip()+
  facet_wrap(~fs, scales = "free_y")


# Country of origin breakdown
df |> group_by(fs, coo) |> 
  summarise(count = n())|> 
  group_by(coo)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) |>
  pivot_wider(names_from = coo, values_from = proportional_count, values_fill = 0)
age

# Demo and age breakdown
demo_fx <- function(demo) {
  df <- df |> filter(asianorigin == demo) |> group_by(fs, age4) |> 
  summarise(count = n())  |>
  group_by(age4)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) |>
  pivot_wider(names_from = age4, values_from = proportional_count, values_fill = 0)
  
  kable(df, caption = demo)
}

demo_fx("NHPI")
lapply(demo_fx(unique(df$asianorigin)))

unique(df$coo)



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
