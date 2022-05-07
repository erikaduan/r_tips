Automate R Markdown report generation - Part 2
================
Erika Duan
2022-05-07

-   [Introduction](#introduction)
-   [Step 1: Create a consistent project
    structure](#step-1-create-a-consistent-project-structure)
-   [Step 2: Create data ingestion and data cleaning R
    script](#step-2-create-data-ingestion-and-data-cleaning-r-script)
-   [Step 3: Create an R Markdown template
    report](#step-3-create-an-r-markdown-template-report)
-   [Step 4: Create an R script for report
    automation](#step-4-create-an-r-script-for-report-automation)
-   [Step 5: (Optional) Create a CI/CD pipeline using GitHub
    Actions](#step-5-optional-create-a-cicd-pipeline-using-github-actions)
-   [Resources](#resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,
               janitor,
               rsdmx,
               clock,
               tidyverse)  
```

# Introduction

This tutorial follows from [an earlier
one](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-automating_rmd_reports/p-automating_rmd_reports_part_1.md)
describing the preliminary steps towards automated reporting in R.

Creating an automated reporting workflow requires the following setup:

1.  A consistent file structure to store code, data and analytical
    outputs.  
2.  A data ingestion and data cleaning script that can be automatically
    refreshed.  
3.  An R Markdown template report that uses yaml parameters instead of
    hard coded variables.  
4.  A report automation script for all parameters of interest.  
5.  (Optional) A CI/CD pipeline i.e. using GitHub Actions.

# Step 1: Create a consistent project structure

There is no best way to organise your project structure. I recommend
starting with a simple naming structure that everyone easily
understands. In this example, I have created a subdirectory named
[`./abs_labour_force_report/`](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-automating_rmd_reports/abs_labour_force_report)
which contains the folders `code` to store my R scripts and Rmd
documents, `data` to store my data, and `output` to store my analytical
outputs.

<img src="../../figures/p-automating_rmd_reports-yaml_params.png" width="55%" style="display: block; margin: auto;" />

**Note:** The `data` folder contains subfolders `raw_data` and
`clean_data` to maintain separation between the raw versus cleaned
dataset used for further analysis.

# Step 2: Create data ingestion and data cleaning R script

We need to create a single R script that:

1.  Downloads the raw dataset from its source location (i.e. from an URL
    or data API).  
2.  Saves the raw dataset.  
3.  Cleans the raw dataset and saves the clean dataset.

This setup allows us to automate future data extractions, assuming that
there are no changes to the data source (i.e. its URL or schema). We
would use the code below and save it as
`./abs_labour_force_report/code/01_extract_and_clean_data.R`.

``` r
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
```

# Step 3: Create an R Markdown template report

The R Markdown template report contains the R code and any additional
markdown or html code required for building the final report.

<img src="../../figures/p-automating_rmd_reports-yaml_params.png" width="55%" style="display: block; margin: auto;" />

The only difference between a standard R Markdown report and an R
Markdown template report is the absence of hard coded variables and
visible code chunks in the template report. The template report should
contain the minimal code required to generate your report outputs
(i.e. figures, tables and summary text).

An example of a chunk of code found inside my [R Markdown template
report](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-automating_rmd_reports/abs_labour_force_report/code/02_create_report_template.Rmd)
is shown below.

``` r
# Plot data --------------------------------------------------------------------
# Set echo=FALSE to hide the code chunk when knitting

# Fix y-axis between different reports 
y_max <- max(labour_force$change_obs_value) 
y_min <- min(labour_force$change_obs_value)   

labour_force %>% 
  filter(sex == params$sex, 
         measure == params$measure) %>%
  ggplot(aes(x = time_period, 
             y = change_obs_value)) +
  geom_line() + 
  scale_y_continuous(limits = c(y_min, y_max)) +
  geom_vline(xintercept = as.Date("2020-02-01"),
             colour = "firebrick",
             linetype = "dashed") +
  annotate("label",
           x = as.Date("2020-02-01"),
           y = y_max - 10,
           label = "COVID-19", color = "firebrick") +
  labs(title = paste("Labour force change for", params$sex, params$measure, "individuals"), 
       x = NULL,
       y = "Individuals (1000s)") +
  theme_bw() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(linetype = "dotted"),
        panel.grid.minor.y = element_line(linetype = "dotted"),
        plot.title = element_text(hjust = 0.5))
```

**Note:** Always use YAML parameters to store default values
i.e. `category: "all"` if this is what your report mainly reports on.
This allows you to preview your default report when testing your
template code using `knit`.

# Step 4: Create an R script for report automation

Finally, the R script for report automation is a for loop that contains:

1.  A data frame containing all parameters of interest, extracted from
    your clean dataset.  
2.  The function `render`, which uses your R Markdown template report
    and list of parameters, to generate a series of output files.

We would use the code below and save it as
`./abs_labour_force_report/code/03_automate_reports.R`.

``` r
# Load required packages -------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here, purrr)  

# Load clean data --------------------------------------------------------------  
labour_force <- read_csv(here("tutorials",
                              "p-automating_rmd_reports",
                              "abs_labour_force_report",
                              "data",
                              "clean_data",
                              "labour_force_clean.csv"))    

# Create for loop to automate report generation --------------------------------
# Create data frame of the dot product of all parameter values 
params_df <- expand.grid(unique(labour_force$sex), unique(labour_force$measure),
                         stringsAsFactors = FALSE)  

# Input template report and parameters to output all html reports
for (i in 1:nrow(params_df)) {
  rmarkdown::render(
    input = here("tutorials",
                 "p-automating_rmd_reports",
                 "abs_labour_force_report",
                 "code",
                 "02_create_report_template.Rmd"),
    params = list(sex = params_df[i, 1],
                  measure = params_df[i, 2]),
    output_file = here("tutorials",
                       "p-automating_rmd_reports",
                       "abs_labour_force_report",
                       "output",
                       glue::glue("{params_list[[i]][[1]]}_{params_list[[i]][[2]]}_report.html"))
  )
}
```

**Note:** Remember to save your output files as `.html` files if you
want to render html reports.

# Step 5: (Optional) Create a CI/CD pipeline using GitHub Actions

# Resources

-   A great [blog post](https://ptds.samorso.ch/tutorials/workflow/)
    containing useful advice for setting up a reproducible project
    workflow.  
-   A great [presentation](bit.ly/marvelRMD) and companion [blog
    post](https://themockup.blog/posts/2020-07-25-meta-rmarkdown/) by
    Thomas Mock on advanced R Markdown features.  
-   A great [blog
    post](https://sharla.party/post/usethis-for-reporting/) on how to
    turn your R data analysis into a reproducible R package by Sharla
    Gelfand.  
-   A great [blog
    post](https://emilyriederer.netlify.app/post/rmddd-tech-appendix/)
    by Emily Riederer on data analysis productionisation in R.
