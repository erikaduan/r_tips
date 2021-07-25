How to integrate SQL queries into an R project
================
Erika Duan
2021-07-25

-   [Introduction](#introduction)
-   [Set up BigQuery data warehouse](#set-up-bigquery-data-warehouse)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse)   
```

# Introduction

I am occasionally asked whether it is more worthwhile to invest in
learning R or Python. To be versatile as a data scientist, it is
actually more important to become proficient in SQL (and either R or
Python). This contrasts with reality where data scientists exiting from
more theoretical programs lack exposure to SQL, which really requires a
data warehouse to practice queries on.

Enter the [DBT jaffle shop
project](https://github.com/dbt-labs/jaffle_shop), which allows you to
easily set up a mock data warehouse in [Google
BigQuery](https://cloud.google.com/bigquery).

# Set up BigQuery data warehouse

A guide to setting up a jaffle shop data warehouse in Google BigQuery
exists [here](https://docs.getdbt.com/tutorial/setting-up).

The steps are to:

1.  Sign up for a [Google Platform
    Account](https://console.cloud.google.com/) using a new or existing
    Google account. Note that you should get 10 GB storage and up to 1
    TB queries/month free of charge, before you are billed for
    additional compute costs.

2.  

# Other resources

-   An RStudio
    [guide](https://db.rstudio.com/getting-started/connect-to-database/)
    on connecting to an existing database using the `odbc` and `DBI`
    packages.  
-   The [GitHub repository](https://github.com/dbt-labs/jaffle_shop) for
    the data build tool (DBT) jaffle shop project.  
-   The jaffle shop DBT Google BigQuery project [set-up
    tutorial](https://docs.getdbt.com/tutorial/setting-up).
