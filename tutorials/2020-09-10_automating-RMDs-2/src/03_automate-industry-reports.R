#-----load required packages-----  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse)  

#-----load required data-----  
tidy_data <- read_csv(here("output", "tidy_ABS_labour_force_by_industry_table_4.csv"))    

#-----create for loop to automate reporting-----  
for (industry_i in unique(tidy_data$industry)) {
  rmarkdown::render(
    input = here("src", "02_industry-report.Rmd"),
    params = list(industry = industry_i), 
    output_file = here("analysis", glue::glue("{industry_i} report.html"))
  )
}