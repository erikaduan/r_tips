Using R to analyse NHMRC funding trends
================
Erika Duan
2019-01-03

-   [Introduction](#introduction)
-   [Data tidying](#data-tidying)
    -   [Data download](#data-download)
    -   [Data exploration](#data-exploration)
-   [Identifying data trends](#identifying-data-trends)
    -   [Differences in grant types funded](#differences-in-grant-types-funded)
    -   [Differences in funding per state/ institution](#differences-in-funding-per-state-institution)
-   [Funding and research topic coverage per state institution](#funding-and-research-topic-coverage-per-state-institution)
-   [References](#references)

Introduction
============

The NHMRC releases funding outcomes every year and these can be accessed [here](https://nhmrc.gov.au/funding/data-research/outcomes-funding-rounds). We can use this data to search for **interesting trends** like:

-   Differences in funding per state/ institution
-   Research topic diversity per state/institution
-   Most vs least well-funded research topics in terms of:
    -   Most vs least $ per project for a topic or
    -   Number of total projects per topic

Collating data from 2014-2017 can provide **addition data** on:

-   Changes in research topic popularity with time
-   Changes in research funding allocation (per state, per institution, per topic) over time

Analysing these trends allow us to monitor whether **interesting or unforseen shifts** in research topic funding have occurred over time and whether the NHMRC has **missing research gaps**. The same data can also be used to showcase strengths in Australian research and even as a surrogate indicator for future research optimism vs pessimism.

Data tidying
============

Datasets often require some **tidying** before data analysis and visualisation can be conducted. The NHMRC funding data is relatively clean, so data tidying is minimal.

Data download
-------------

To get started, we can download the 2018 funding outcomes data directly from the [NHMRC website](https://nhmrc.gov.au/funding/data-research/outcomes-funding-rounds) using `download.file`.

On the NHMRC website, we can see that the original file is an excel spreadsheet, which we can read using the tidyverse package `readxl`.

``` r
library("tidyverse") #loads R package for data analysis
```

    ## -- Attaching packages ----------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 3.1.0     v purrr   0.2.5
    ## v tibble  1.4.2     v dplyr   0.7.8
    ## v tidyr   0.8.2     v stringr 1.3.1
    ## v readr   1.2.1     v forcats 0.3.0

    ## -- Conflicts -------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library("readxl") #loads R package for importing excel spreadsheets
library("gghighlight") #handy package for highlighting data of interest
```

    ## Warning: package 'gghighlight' was built under R version 3.5.2

``` r
library("cowplot") # for plotting graphs side by side
```

    ## 
    ## Attaching package: 'cowplot'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     ggsave

``` r
temp <- tempfile() #downloads and stores the dataset as a temporary file

download.file("https://nhmrc.gov.au/file/12086/download?token=1q3_D-vV", 
              destfile = temp,
              method = "curl")

nhmrc_2017 <- read_excel(temp) #reads the excel file as a tidy table (tibble)
```

Data exploration
----------------

**Simple data exploration** includes using `glimpse` or `str` to examine the data structure, and `dim` to examine the data dimensions.

``` r
glimpse(nhmrc_2017) # a tidy overview of data structure
```

    ## Observations: 1,045
    ## Variables: 19
    ## $ `APP ID`              <dbl> 1150337, 1150361, 1151782, 1151848, 1151...
    ## $ `Date Announced`      <dttm> 2018-04-23, 2018-04-23, 2018-04-23, 201...
    ## $ `CIA Name`            <chr> "A/Pr Dina LoGiudice", "Prof Robert Sans...
    ## $ `Grant Type`          <chr> "Targeted Calls for Research", "Targeted...
    ## $ `Sub Type`            <chr> "Dementia in Indigenous Australians", "D...
    ## $ `Grant Title`         <chr> "Let's CHAT (Community Health Approaches...
    ## $ `Admin Institution`   <chr> "University of Melbourne", "University o...
    ## $ State                 <chr> "VIC", "NSW", "WA", "VIC", "NSW", "VIC",...
    ## $ Sector                <chr> "University", "University", "University"...
    ## $ Total                 <dbl> 2661502.0, 3046293.9, 2543423.3, 2811179...
    ## $ `Broad Research Area` <chr> "Clinical Medicine and Science", "Public...
    ## $ `Field of Research`   <chr> "Geriatrics and Gerontology", "Aborigina...
    ## $ `Res KW1`             <chr> "indigenous Australians", "dementia", "d...
    ## $ `Res KW2`             <chr> "dementia", "Aboriginal", "indigenous Au...
    ## $ `Res KW3`             <chr> "cognitive impairment", "indigenous Aust...
    ## $ `Res KW4`             <chr> "geriatrics", "randomised controlled tri...
    ## $ `Res KW5`             <chr> "health care delivery", "community inter...
    ## $ `Plain Description`   <chr> "The Let's CHAT (Community Health Approa...
    ## $ X__1                  <chr> ".", ".", ".", ".", ".", ".", ".", ".", ...

``` r
dim(nhmrc_2017) # 1045 rows and 19 columns of data
```

    ## [1] 1045   19

This allows us to identify several points:

-   Each application has a **unique ID** (which is great - each entry has a unique ID).
-   The column **Total** lists the funding in $AUS per application (an important continuous variable).
-   Columns **Res KW1 to Res KW5** can be combined into a single longer string (for identifying common research topics later on).
-   Columns **Plain Description** and \*\*X\_\_1\*\* are not important for our analysis.

``` r
clean_2017 <- nhmrc_2017 %>%
  select(-`Plain Description`, -X__1) %>% # removes unwanted columns
  unite("Keywords", c(`Res KW1`, `Res KW2`, `Res KW3`, `Res KW4`, `Res KW5`), 
        sep = " ",
        remove = T) # creates a single column for all keywords

glimpse(clean_2017) # to check that our changes are correct
```

    ## Observations: 1,045
    ## Variables: 13
    ## $ `APP ID`              <dbl> 1150337, 1150361, 1151782, 1151848, 1151...
    ## $ `Date Announced`      <dttm> 2018-04-23, 2018-04-23, 2018-04-23, 201...
    ## $ `CIA Name`            <chr> "A/Pr Dina LoGiudice", "Prof Robert Sans...
    ## $ `Grant Type`          <chr> "Targeted Calls for Research", "Targeted...
    ## $ `Sub Type`            <chr> "Dementia in Indigenous Australians", "D...
    ## $ `Grant Title`         <chr> "Let's CHAT (Community Health Approaches...
    ## $ `Admin Institution`   <chr> "University of Melbourne", "University o...
    ## $ State                 <chr> "VIC", "NSW", "WA", "VIC", "NSW", "VIC",...
    ## $ Sector                <chr> "University", "University", "University"...
    ## $ Total                 <dbl> 2661502.0, 3046293.9, 2543423.3, 2811179...
    ## $ `Broad Research Area` <chr> "Clinical Medicine and Science", "Public...
    ## $ `Field of Research`   <chr> "Geriatrics and Gerontology", "Aborigina...
    ## $ Keywords              <chr> "indigenous Australians dementia cogniti...

Note that we don't want to remove too many rows of data during initial data tidying (i.e. only the redundant ones), as some may be unexpectedly useful for downstream analyses.

And with that, it's time to start some **data exploration**!

Identifying data trends
=======================

There are no hard and fast rules for identifying data trends. The type of data analysis you want to do depends on your research question. In general, quick visualisation of data distributions via `ggplot2::geom_bar` barplots can be very helpful.

Differences in grant types funded
---------------------------------

Working via a top-down approach (i.e. starting with the biggest picture and then narrowing down to specific details of interest), we first might want to know what types of grants were funded by the NHMRC in 2018 and their numbers.

After that, we might want to know how NHMRC funding for key grant types is distributed across different states, or perhaps across different institutions per state of interest.

``` r
ggplot(clean_2017, aes(x = `Grant Type`)) + 
  geom_bar() + # code below this line specifies graph formating changes only
  scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. of grants funded") +
  theme(axis.title.y = element_blank()) +
  coord_flip()
```

<img src="NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

For easier visualisation, we might want to automatically rank grant types from least to most abundant.
To do this, we can make use of the `forcats` package from `tidyverse`, which is designed for easy wrangling of categorical datasets.

``` r
clean_2017 %>%
  mutate(`Grant Type` = `Grant Type` %>% fct_infreq() %>% fct_rev()) %>% #reorders factors
  ggplot(aes(x = `Grant Type`)) + 
  geom_bar() + 
  scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. of grants funded") +
  theme(axis.title.y = element_blank()) +
  coord_flip()
```

<img src="NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

**Insight:** The majority of grants funded are project grants, followed by fellowships and scholarships. Interestingly, the number of career development fellowships (supporting mid-career researchers) funded is lower than the number of other fellowships or post-graduate scholarships (excepting practitioner fellowships for clinicians), and is only ~50% of the number of early career research fellowships.

This data would support the notion that mid-career fellowships are more competitive, and that there may be a higher chance of not receiving independent fellowship funding during this career stage.

We can also view the actual numbers here.

``` r
clean_2017 %>%
  mutate(`Grant Type` = `Grant Type` %>% fct_infreq()) %>% 
           count(`Grant Type`)
```

    ## # A tibble: 18 x 2
    ##    `Grant Type`                                                          n
    ##    <fct>                                                             <int>
    ##  1 Project Grants                                                      510
    ##  2 Early Career Fellowships                                            115
    ##  3 Research Fellowships                                                101
    ##  4 Postgraduate Scholarships                                            78
    ##  5 Career Development Fellowships                                       55
    ##  6 Equipment Grant                                                      42
    ##  7 Independent Research Institutes Infrastructure Support Scheme (I~    23
    ##  8 Partnerships                                                         23
    ##  9 Development Grants                                                   20
    ## 10 Targeted Calls for Research                                          17
    ## 11 Centres of Research Excellence                                       16
    ## 12 Practitioner Fellowships                                             14
    ## 13 Translating Research into Practice Fellowships                       13
    ## 14 International Collaboration - NHMRC/NAFOSTED Joint Call for Coll~     7
    ## 15 2018 Partnership Projects PRC1                                        5
    ## 16 Boosting Dementia Research Initiative                                 4
    ## 17 Boosting Dementia Research Grants -Priority Round 3                   1
    ## 18 Partnership Centre: Systems Perspective on Preventing Lifestyle-~     1

Differences in funding per state/ institution
---------------------------------------------

We can view **differences in funding across states** through two different lens:

-   Total number of grants/fellowships across each state
-   Total number of grants/fellowships awarded relative to a normalisation factor (population size or institute number etc.)

The latter is more useful for comparing the research productivity of smaller states with larger states (i.e. after normalisation to the population per state), with the assumption that there is a proportional increase in grant/fellowship applications in states with a larger population size. The real relationship is likely to be much more complicated, with perhaps an additional funding success penalty per small state (due to the lack of larger research hubs in smaller states, less competitive researcher recruitment packages and etc).

To visualise the total number of grants/ fellowships per state, we can once again use `ggplot2::geom_bar` barplots.

``` r
grant_types <- factor(clean_2017$`Grant Type`)
levels(grant_types) # lists the types of grants available
```

    ##  [1] "2018 Partnership Projects PRC1"                                                                 
    ##  [2] "Boosting Dementia Research Grants -Priority Round 3"                                            
    ##  [3] "Boosting Dementia Research Initiative"                                                          
    ##  [4] "Career Development Fellowships"                                                                 
    ##  [5] "Centres of Research Excellence"                                                                 
    ##  [6] "Development Grants"                                                                             
    ##  [7] "Early Career Fellowships"                                                                       
    ##  [8] "Equipment Grant"                                                                                
    ##  [9] "Independent Research Institutes Infrastructure Support Scheme (IRIISS)"                         
    ## [10] "International Collaboration - NHMRC/NAFOSTED Joint Call for Collaborative Research Projects"    
    ## [11] "Partnership Centre: Systems Perspective on Preventing Lifestyle-related Chronic Health Problems"
    ## [12] "Partnerships"                                                                                   
    ## [13] "Postgraduate Scholarships"                                                                      
    ## [14] "Practitioner Fellowships"                                                                       
    ## [15] "Project Grants"                                                                                 
    ## [16] "Research Fellowships"                                                                           
    ## [17] "Targeted Calls for Research"                                                                    
    ## [18] "Translating Research into Practice Fellowships"

``` r
# Comparing project grants funded across states
project <- clean_2017 %>% 
  filter(`Grant Type` == "Project Grants") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. Project grants funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip()

# Comparing ECR fellowships funded across states
ECR <- clean_2017 %>% 
  filter(`Grant Type` == "Early Career Fellowships") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. ECR fellowships funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip()

# Comparing CD fellowships funded across states
CD <- clean_2017 %>% 
  filter(`Grant Type` == "Career Development Fellowships") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. CD fellowships funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip() +
  gghighlight(!State == "QLD", use_group_by = F)
```

    ## label_key: State

``` r
# Comparing Research fellowships funded across states
Research <- clean_2017 %>% 
  filter(`Grant Type` == "Research Fellowships") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. Research fellowships funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip()

plot_grid(project, ECR, CD, Research,
          labels = "AUTO",
          label_y = 1)
```

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-7-1.png)

**Insight:** We can immediately see that the state with the highest number of project grants was VIC, with almost twice the number of grants compared to NSW. As VIC and NSW both have large populations, this suggests that Victorian researchers may have had a greater funding success rate.

Another important insight is that Career Development Fellowships are more disproportionately awarded to only Victoria and NSW compared to other funding schemes. This potentially may be related to the decreased number of total CD fellowships funded (i.e. increased competition) and indicates that a mid-career pipeline leak may be more likely to exist, especially for non-VIC/NSW researchers.

An alternate way of visualising this data is through **static geospatial data**.

``` r
library(tmap)
```

    ## Warning: package 'tmap' was built under R version 3.5.2

``` r
# mapping onto static geographical maps
```

**Total counts can often obscure information, as certain biases are inherited.** For instance, it may seem as if relatively minimal grant success rates occur in WA, ACT, NT and Tasmania and all researchers should pack up and go home. This, however, is not necessarily an accurate interpretation, as the total number of funding applications and applicants is most likely much higher in VIC and NSW.

One way we can account for this potential bias is to normalise the total number of grants received by a factor like the:

-   Total population size or
-   Total number of institutions per state (which acts as a surrogate for researcher population size)

``` r
# Normalising by total institutions per state
```

Funding and research topic coverage per state institution
=========================================================

``` r
# Identifying top 5 topic trends during 2018
# Plotting funding per institute and colour the fill by research topic. 
```

References
==========

This post was written based on the following resources and R packages:

**R packages:**

-   **Tidyverse** - Hadley Wickham (2017). tidyverse: Easily Install and Load the 'Tidyverse'. R package version 1.2.1. <https://CRAN.R-project.org/package=tidyverse>
    -   read\_excel
    -   ggplot2
    -   forcats
    -   dplyr
-   **gghighlight** - Hiroaki Yutani (2018). gghighlight: Highlight Lines and Points in 'ggplot2'. R package version 0.1.0. <https://CRAN.R-project.org/package=gghighlight>
-   **Cowplot** - Claus O. Wilke (2018). cowplot: Streamlined Plot Theme and Plot Annotations for 'ggplot2'. R package version 0.9.3. <https://CRAN.R-project.org/package=cowplot>

**Resources:**

-   [How to arrange plots using cowplot](https://cran.r-project.org/web/packages/cowplot/vignettes/plot_grid.html)
-   [Guide to categorical data analysis using forcats](https://r4ds.had.co.nz/factors.html)
-   [R for Data Science](https://r4ds.had.co.nz)
