library(tidyverse)
library(haven)
library(janitor)
library(expss)


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

# Calculate food security status
df <- df |> mutate(
  fs = case_when(score <2 ~ "high",
                 score > 1 ~ "low")
)

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
                         
                         )
)

# Get demographic breakdown -----------------------------------------------------------

# Age breakdown
age <- df |> group_by(fs, age4) |> 
  summarise(count = n())  |>
  group_by(age4)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) 
  pivot_wider(names_from = age4, values_from = proportional_count, values_fill = 0)
age

# Get demographic breakdown
# df |> group_by(fs, age4) |> 
#   summarise(count = n())  |>
#   pivot_wider(names_from = age4, values_from = count, values_fill = 0)

# Asian origin breakdown
ao <- df |> group_by(fs, asianorigin) |> 
  summarise(count = n())|> 
  group_by(asianorigin)|>
  mutate(proportional_count = count / sum(count)) |>
  select(-count) 

ggplot(ao, aes(x=asianorigin, y = proportional_count, fill = fs)) + 
  geom_bar(stat="identity", show.legend=F) + coord_flip()+
  facet_wrap(~fs, scales = "free_y")

# vietnamese
viet <- df |> filter(asianorigin == "Vietnamese")

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

lapply(unique(df$asianorigin), demo_fx)
