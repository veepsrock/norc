library(tidyverse)
library(haven)
library(janitor)


# Read in data
df <- read_sav("data/nov/[9800] Amplify AAPI M3 November 2023 - Final Data.sav") |> clean_names()
