# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,
               janitor,
               rsdmx,
               clock,
               tidyverse)  

# Connect to Labour Force API --------------------------------------------------
data_url <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M2+M1.2+1+3.1599.20+30.AUS.M?startPeriod=2019-01&dimensionAtObservation=AllDimensions"  

# Obtain data as tibble data frame ---------------------------------------------
labour_force <- readSDMX(data_url) %>%
  as_tibble() 

# Save raw data ----------------------------------------------------------------
write_csv(labour_force, here("tutorials",
                             "p-automating_rmd_reports",
                             "abs_labour_force_report",
                             "data",
                             "raw_data",
                             "labour_force_raw.csv"))

# Clean data to produce YAML parameter friendly dataset ------------------------  
labour_force <- labour_force %>%
  clean_names() %>%
  filter (tsest == 20) %>% # Extract seasonally adjusted values  
  select(time_period,
         measure,
         sex,
         obs_value) 

# Rename measure and sex as strings   
labour_force <- labour_force %>% 
  mutate(measure = case_when(measure == "M1" ~ "full-time",
                             measure == "M2" ~ "part-time"),
         sex = case_when(sex == "1" ~ "male",
                         sex == "2" ~ "female",
                         sex == "3" ~ "all"))

# Convert time_period into a Date format and create a change variable 
labour_force <- labour_force %>% 
  group_by(measure, sex) %>% # Analyse for all subcategories of measure and sex  
  mutate(time_period = as.Date(paste0(time_period, "-01"), format = "%Y-%m-%d"),
         last_obs_value = lag(obs_value),
         change_obs_value = case_when(
           is.na(last_obs_value) ~ 0,
           TRUE ~ obs_value - last_obs_value)) %>%
  ungroup()

# Save clean data --------------------------------------------------------------
write_csv(labour_force, here("tutorials",
                             "p-automating_rmd_reports",
                             "abs_labour_force_report",
                             "data",
                             "clean_data",
                             "labour_force_clean.csv"))