#-----load required packages-----  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse,
               readxl) # read excel spreadsheets    

#-----download ABS data-----  
data_url <- "https://beta.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia-detailed/jul-2020/6291004.xls"

download.file(data_url, destfile = here("data", "ABS_labour_force_by_industry_table_4.xls"), mode = "wb")   

#-----clean ABS data-----  
data_path <- here::here("data", "ABS_labour_force_by_industry_table_4.xls")

raw_table_4 <- data_path %>%
  excel_sheets() %>%
  set_names() %>% # extract all sheet names  
  str_subset(., "Data.+") %>% # subset relevant sheet names    
  map_dfc(~ read_excel(path = data_path,
                       sheet = .x, 
                       col_names = T)) 

raw_table_4 <- raw_table_4 %>%
  slice(10: nrow(raw_table_4)) %>%
  rename(date = ...1) %>%
  mutate(date = as.Date(as.numeric(date), origin = "1899-12-30")) %>%
  arrange(date)

remove_cols <- str_subset(colnames(raw_table_4), "^Employed total") # remove summary columns   

raw_table_4  <- raw_table_4  %>%
  select(-all_of(remove_cols))  

selected_cols <- colnames(raw_table_4)[c(1, # select date column
                                         seq(3, # select first seasonally adjusted column
                                             ncol(raw_table_4),
                                             by = 3))] # select consecutive seasonally adjusted columns    

raw_table_4 <- raw_table_4 %>%
  select(all_of(selected_cols))  

colnames(raw_table_4) <- str_remove_all(colnames(raw_table_4), "\\s;.+") # clean column names  

raw_table_4 <- raw_table_4 %>% # pivot longer to add industry type as a column  
  pivot_longer(cols = -date,
               names_to = "industry",
               values_to = "count") # units in 1000s  

raw_table_4 <- raw_table_4 %>%
  mutate(count = as.numeric(count),
         count = round(count, digits = 3)) # round counts to nearest person  

#-----save clean ABD data as output-----  
write_csv(raw_table_4, here("output", "tidy_ABS_labour_force_by_industry_table_4.csv"))  