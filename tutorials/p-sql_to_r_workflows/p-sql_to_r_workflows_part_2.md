How to integrate SQL and R - Part 2
================
Erika Duan
2022-01-26

-   [Introduction](#introduction)
-   [SQL syntax quirks](#sql-syntax-quirks)
-   [Production friendly workflows](#production-friendly-workflows)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse,
               odbc,
               DBI,
               Rcpp)   
```

# Introduction

The second part of my tutorial series about SQL to R workflows is mainly
focused on breaking down differences between SQL and R syntax. It also
contains a rehash of Emily Riederer’s excellent [blog
post](https://emilyriederer.netlify.app/post/sql-r-flow/) on flexible
project workflows for integrating SQL with R data analysis.

# SQL syntax quirks

<img src="../../figures/p-sql_to_r_workflows-execution_order.svg" width="80%" style="display: block; margin: auto;" />

# Production friendly workflows

# Other resources

-   Emily Riederer’s excellent [blog
    post](https://emilyriederer.netlify.app/post/sql-r-flow/) containing
    ideas for creating flexible SQL &lt;&gt; R project workflows.  
-   Julia Evan’s entertaining [programming
    zine](https://wizardzines.com/zines/sql/) explaining all things SQL.
    (Paywalled resource)
