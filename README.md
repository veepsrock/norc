# NORC Food and Nutrition Security Survey Analysis

## Overview
RF conducted two nationwide surveys on the Asian American Native Hawaiian Pacific Isander (AANHPI) population. The nationwide study was conducted by The AP-NORC Center for Public Affairs Research and RF using the Amplify AAPI Monthly survey drawing from NORC’s Amplify AAPI® Panel designed to be representative of the U.S. Asian American, Native Hawaiian, and Pacific Islander household population. Online and telephone interviews were offered in English, the Chinese dialects of Mandarin and Cantonese, Vietnamese, and Korean with 1,115 Asian American, Native Hawaiian, and Pacific Islanders aged 18 and older living in the United States. The margin of sampling error is +/- 4.4 percentage points. 

### November Survey
- **Conducted**: November 6, 2023 – November 15, 2023
- **Themes**: Food security, nutrition security, and access to SNAP benefits

### December Survey
- **Conducted**: December 4, 2023 – December 11, 2023
- **Themes**: Cultural relationship to food, and awareness of Food is Medicine Program

## Description of the data
Data for both surveys can be found in the [data](/data) folder
|Survey month|Themes|Sample size|
|:---|:---|:---|
|November|Food security, nutrition security, SNAP access|1115|
|December|Cultural relationship to food, FIM awareness and perceptions|1091|

## Description of the data files
Data for both surveys can be found in the [data](/data) folder
|Description|November File Name|December File Name|
|:---|:---|:---|
|Cross tabs|[9800] Amplify AAPI M3 November 2023 - Banner 1_ Rockefeller - 20240109.xlsx|Amplify AAPI_M4 December 2023 Banner.xlsx|
|Raw data|[9800] Amplify AAPI M3 November 2023 - Final Data - 20240109.sav|Amplify AAPI_M4 December 2023 Final Data.sav|
|Code book|[9800] Amplify AAPI M3 November 2023 - Codebook.xlsx|Amplify AAPI_M4 December 2023 Codebook.xlsx|

## Data processing files
Use the following files for data processing. Read in the code by using the line `source(["file_name"])` in a new file.
|Description|File|
|:---|:---|
|Calculating food and nutrition security|[001_data_processing.R](001_data_processing.R)|
|Recoding values for demographic labels (for example "18-29" instead of 1 for age4)|[002_recode.R](002_recode.R)|

## Codebook for food and nutrition security 
Here are the variables for food and nutrition security. Food security is calculated based on the FDA 6-item survey standards. Nutrition security is calculated based on the Tufts University nutrition security screener question. These values can be used after running the [001_data_processing.R](001_data_processing.R) code.

|Variable|Values|Description|
|:---|:---|:---|
|fs|"low" or "high"|Food security status|
|ns|"low" or "high"|Nutrition security status|
|low_fs|0 or 1|Experiencing low food security (1 = yes)|
|low_ns|0 or 1|Experiencing low nutrition security (1 = yes)|


### Food security status is assigned as follows:

- Raw score 0-1—High or marginal food security (raw score 1 may be considered marginal food security, but a large proportion of households that would be measured as having marginal food security using the household or adult scale will have raw score zero on the six-item scale)

- Raw score 2-4—Low food security

- Raw score 5-6—Very low food security

For some reporting purposes, the food security status of households with raw score 0-1 is described as food secure and the two categories “low food security” and “very low food security” in combination are referred to as food insecure.


### Nutrition security status is assigned as follows:

- While the optimal scoring of the NSS requires more research, one possibility is to define low nutrition security as responses of “somewhat hard", "hard", or "very hard" to the question "Thinking about the last 12 months, how hard was it for you or your household to regularly get and eat healthy foods?"

## Codebook for SNAP variables 
Here are the variables for SNAP. Eligibility for SNAP is calculated by [USDA monthly household income thresholds.](https://www.fns.usda.gov/snap/recipient/eligibility) Food security is calculated based on the FDA 6-item survey standards. Nutrition security is calculated based on the Tufts University nutrition security screener question. These values can be used after running the [001_data_processing.R](001_data_processing.R) code.

|Variable|Values|Description|Calculated in this file|
|:---|:---|:---|:---|
|snap_l (Nov survey)|"curretly enrolled", "enrolled in past", "not enrolled", "I don't know", "Skipped"|Recode of original q9 on November survey|[001_data_processing.R](001_data_processing.R)|
|snap_enrol (Nov survey)|0 or 1|Currently or previously have been enrolled in SNAP (1 = yes)|[001_data_processing.R](001_data_processing.R)|
|snap_elig (Nov and Dec surveys)|0 or 1|Eligible for SNAP based on household income requirements (1 = yes)|[002_recode.R](002_recode.R)|
