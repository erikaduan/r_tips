Using R to analyse NHMRC funding trends
================
Erika Duan
2019-01-13

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

The NHMRC releases funding outcomes every year and these can be accessed [here](https://nhmrc.gov.au/funding/data-research/outcomes-funding-rounds). We can use this data to analyse **interesting trends** like:

-   Differences in funding per state/ institution
-   Research topic diversity per state/institution
-   Most vs least well-funded research topics in terms of:
    -   Most vs least $ awarded per project for a topic or
    -   Number of projects funded per topic

Collating data from 2014-2018 can provide **addition data** on:

-   Changes in research topic diversity/popularity with time
-   Changes in research funding success (per state, per institution, per topic) over time

Analysing these trends can allow us to monitor whether **unforseen shifts** in research topic funding have occurred over time and whether the NHMRC has **missing research gaps**. The same data can also be used to **showcase strengths** in Australian research and even as a **surrogate indicator** for research optimism vs pessimism.

Data tidying
============

Datasets often require some **tidying** before data analysis and visualisation can be conducted. The NHMRC funding data is relatively clean, so data tidying is minimal.

Data download
-------------

To get started, we can **download the 2018 funding outcomes** directly from the [NHMRC website](https://nhmrc.gov.au/funding/data-research/outcomes-funding-rounds) using `download.file`.

The NHMRC dataset exists an excel spreadsheet, which we can read using the tidyverse package `readxl`.

``` r
# Load R packages for data exploration and visualisation

library("tidyverse") # loads R package for data analysis
library("readxl") # loads R package for importing excel spreadsheets
library("gghighlight") # handy R package for highlighting data of interest
library("cowplot") # handy R package for plotting graphs side by side
library("DT") # handy R package for displaying interactive tables
library("paletteer") # handy R package for colour selection when plotting graphs

temp <- tempfile() #downloads and stores the 2018 NHMRC dataset as a temporary file

download.file("https://nhmrc.gov.au/file/12086/download?token=EQHf-aA1", 
              destfile = temp,
              method = "curl")

nhmrc_2018 <- read_excel(temp) # reads the excel file as a tidy table (tibble)
```

Data exploration
----------------

We can first use `glimpse` or `str` to examine the data structure, and `dim` to examine the data dimensions.

``` r
glimpse(nhmrc_2018) # a tidy overview of data structure
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
    ## $ `..19`                <chr> ".", ".", ".", ".", ".", ".", ".", ".", ...

``` r
dim(nhmrc_2018) # 1045 rows and 19 columns of data
```

    ## [1] 1045   19

This helps us to identify several points:

-   Each application has a **unique ID** (important for tracking each application).
-   The column **Total** lists the funding in $AUS per application (very important continuous variable).
-   Columns **Res KW1 to Res KW5** can be combined into a single longer string (for identifying common research topics later on).
-   Columns **X\_1 and Plain Description** are not important for our analysis.

``` r
clean_2018 <- nhmrc_2018 %>%
  select(-`Plain Description`) %>% # removes unwanted columns
  unite("Keywords", c(`Res KW1`, `Res KW2`, `Res KW3`, `Res KW4`, `Res KW5`), 
        sep = " ",
        remove = T) # creates a single column for all keywords

glimpse(clean_2018) # to check that our changes are correct
```

    ## Observations: 1,045
    ## Variables: 14
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
    ## $ `..19`                <chr> ".", ".", ".", ".", ".", ".", ".", ".", ...

**Note:** We don't want to make changes directly onto the original data or remove too many columns during initial data tidying. Some parameters may be unexpectedly useful for downstream analyses.

And with that, it's time to start some **data exploration**!

Identifying data trends
=======================

There are no hard and fast rules for identifying data trends. **The type of data analysis depends on your research question.** In general, visualisation of data distributions via `ggplot2::geom_bar` barplots can be a helpful starting point.

Differences in grant types funded
---------------------------------

We might first examine what grants types were funded by the NHMRC in 2018 and their proportion. Next, we might want to know how NHMRC funding for key grant types is distributed across different states, or perhaps across different institutions per state of interest.

``` r
# Plots the distribution of all grants funded by type in 2018
ggplot(clean_2018, aes(x = `Grant Type`)) + 
  geom_bar() + # code below this line specifies graph formating changes only
  scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. of grants funded") +
  theme(axis.title.y = element_blank()) +
  coord_flip()
```

<img src="NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

To improve visualisation, we would rank grant types from most to least abundantly funded.
We can use the `forcats` package from `tidyverse`, which is designed for easy wrangling of **categorical datasets**.

``` r
clean_2018 %>%
  mutate(`Grant Type` = `Grant Type` %>% fct_infreq() %>% fct_rev()) %>% #reorders factors 
  ggplot(aes(x = `Grant Type`)) + 
  geom_bar() + 
  scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. of grants funded") +
  theme(axis.title.y = element_blank()) +
  coord_flip()
```

<img src="NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

**Data insights:**

-   The majority of grants funded are project grants, followed by research-supporting fellowships and scholarships.
-   The number of Career Development fellowships (supporting mid-career researchers) funded is lower than the number of other fellowships or post-graduate scholarships (excepting the relatively rare practitioner fellowships for clinicians), and is only ~50% of the number of Early Career fellowships funded.

This data would support the notion that **mid-career fellowships are more competitive**, and that **there may be a lower chance of receiving independent fellowship funding during this career stage**.

We can also view the actual numbers via a table count.

``` r
clean_2018 %>%
  mutate(`Grant Type` = `Grant Type` %>% fct_infreq()) %>% 
           count(`Grant Type`)
```

    ## # A tibble: 18 x 2
    ##    `Grant Type`                                                           n
    ##    <fct>                                                              <int>
    ##  1 Project Grants                                                       510
    ##  2 Early Career Fellowships                                             115
    ##  3 Research Fellowships                                                 101
    ##  4 Postgraduate Scholarships                                             78
    ##  5 Career Development Fellowships                                        55
    ##  6 Equipment Grant                                                       42
    ##  7 Independent Research Institutes Infrastructure Support Scheme (IR~    23
    ##  8 Partnerships                                                          23
    ##  9 Development Grants                                                    20
    ## 10 Targeted Calls for Research                                           17
    ## 11 Centres of Research Excellence                                        16
    ## 12 Practitioner Fellowships                                              14
    ## 13 Translating Research into Practice Fellowships                        13
    ## 14 International Collaboration - NHMRC/NAFOSTED Joint Call for Colla~     7
    ## 15 2018 Partnership Projects PRC1                                         5
    ## 16 Boosting Dementia Research Initiative                                  4
    ## 17 Boosting Dementia Research Grants -Priority Round 3                    1
    ## 18 Partnership Centre: Systems Perspective on Preventing Lifestyle-r~     1

Differences in funding per state/ institution
---------------------------------------------

We can view differences in funding across states through two different means:

-   Total number of grants/fellowships across each state
-   Total number of grants/fellowships awarded relative to **a normalisation factor** (population size or institute number etc.)

The latter approach is useful for comparing the research productivity of smaller states with larger states (i.e. after normalisation by size). To simply visualise the **total number of grants/ fellowships per state**, we can once again use `ggplot2::geom_bar` barplots.

``` r
grant_types <- factor(clean_2018$`Grant Type`)
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
Project <- clean_2018 %>% 
  filter(`Grant Type` == "Project Grants") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%  # orders by most to least funded state
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. Project grants funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip()

# Comparing ECR fellowships funded across states
ECR <- clean_2018 %>% 
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
CD <- clean_2018 %>% 
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
Research <- clean_2018 %>% 
  filter(`Grant Type` == "Research Fellowships") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. Research fellowships funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip()

counts_plots <- plot_grid(Project, ECR, CD, Research,
          labels = "AUTO")

counts_title <- ggdraw() + 
  draw_label("2018 NHMRC funding outcomes (total counts)")

plot_grid(counts_title, counts_plots,
          ncol = 1, rel_heights = c(0.1, 1)) # rel_heights values control title margins
```

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-7-1.png)

**Data insights:** \* The state with the highest number of project grants was VIC, with almost twice the number of grants compared to NSW. \* Career Development Fellowships are more disproportionately awarded to only VIC and NSW compared to other funding schemes. This may link to the decreased number of total CD fellowships funded (i.e. increased competition) and indicates that a mid-career pipeline leak may be more likely to exist, especially for non-VIC/NSW researchers.

### Data visualisation through geospatial data

An alternate way of visualising the same data is through **static geospatial data**. The `tmap` package requires shape objects (objects from the class Spatial or Raster; from the sp and the raster packages).

We can obtain a shapefile of the boundaries data of Australian States and Territories from the Australian Bureau of Statistics [here](http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1259.0.30.001July%202011?OpenDocument).

This shapefile can be read via R using the package `rgdal`.

``` r
library(tmap) # mapping onto static geographical maps
library(rgdal) # converting shapefiles into spatial dataframes
```

``` r
# To read the shapefile and convert to a usable spatial dataframe
shape <- readOGR(dsn = "C:/Users/user/Desktop/State_shapefiles", layer = "STE11aAust")
```

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "C:\Users\user\Desktop\State_shapefiles", layer: "STE11aAust"
    ## with 9 features
    ## It has 2 fields

``` r
# To view and extract the content of the attributes table
data.frame(shape)
```

    ##   STATE_CODE                   STATE_NAME
    ## 0          1              New South Wales
    ## 1          2                     Victoria
    ## 2          3                   Queensland
    ## 3          4              South Australia
    ## 4          5            Western Australia
    ## 5          6                     Tasmania
    ## 6          7           Northern Territory
    ## 7          8 Australian Capital Territory
    ## 8          9            Other Territories

``` r
shape.data <- data.frame(shape@data)

# Create consistent abbreviations for each state
abbrev <- c("NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT", "OT") %>%
  as.data.frame()

shape.data <- bind_cols(shape.data, abbrev) %>%
  rename("State" = ".")

# Use clean_2018 data and collect grant type information by state
shape_2018 <- clean_2018 %>%
    select(`Grant Type`, State) %>%
  filter(`Grant Type` %in% c("Project Grants", # filters for grant types of interest 
           "Early Career Fellowships",
           "Career Development Fellowships",
           "Research Fellowships")) %>%
  group_by(`Grant Type`, State) %>%
  summarise(Count = n()) %>%
  spread(`Grant Type`, Count,
         fill = 0) 

# Join with shape.data and add onto Large SPDF
shape.data <- left_join(shape.data, shape_2018,
                        by = "State") %>%
  mutate_all(funs(replace(., is.na(.), 0))) # replace NAs with 0 for consistency 
```

    ## Warning: Column `State` joining factor and character vector, coercing into
    ## character vector

    ## Warning in `[<-.factor`(`*tmp*`, list, value = 0): invalid factor level, NA
    ## generated

    ## Warning in `[<-.factor`(`*tmp*`, list, value = 0): invalid factor level, NA
    ## generated

``` r
shape@data <- shape.data

omit.OT <- subset(shape, State != "OT") # creates a subset without Other Territories labelled

# For Career Development fellowships
tm_shape(omit.OT) +
  tm_fill(col = "Career Development Fellowships",
          palette = "YlOrRd",
          title = "CD Fellowships") +
  tm_borders("grey", lwd = 0.1) +
  tm_text("State", size = 0.8, alpha = 0.6) + 
  tm_layout(legend.title.size = 0.8,
          legend.text.size = 0.6,
          legend.position = c("left","bottom"),
          legend.bg.color = "white",
          legend.bg.alpha = 0.5)
```

    ## Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-9-1.png)

We can then use functions like `tmap_arrange` to visualise spatial data for all key grant types as below.

``` r
CD.shape <- tm_shape(omit.OT) +
  tm_fill(col = "Career Development Fellowships",
          palette = "YlOrRd",
          title = "CD Fships") +
  tm_borders("grey", lwd = 0.1) +
  tm_text("State", size = 0.8, alpha = 0.6) + 
  tm_layout(legend.title.size = 0.8,
          legend.text.size = 0.6,
          legend.position = c("left","bottom"),
          legend.bg.color = "white",
          legend.bg.alpha = 0.5)

ECR.shape <- tm_shape(omit.OT) +
  tm_fill(col = "Early Career Fellowships",
          palette = "YlOrRd",
          title = "ECR Fships") +
  tm_borders("grey", lwd = 0.1) +
  tm_text("State", size = 0.8, alpha = 0.6) + 
  tm_layout(legend.title.size = 0.8,
          legend.text.size = 0.6,
          legend.position = c("left","bottom"),
          legend.bg.color = "white",
          legend.bg.alpha = 0.5)

Research.shape <- tm_shape(omit.OT) +
  tm_fill(col = "Research Fellowships",
          palette = "YlOrRd",
          title = "Research Fships") +
  tm_borders("grey", lwd = 0.1) +
  tm_text("State", size = 0.8, alpha = 0.6) + 
  tm_layout(legend.title.size = 0.8,
          legend.text.size = 0.6,
          legend.position = c("left","bottom"),
          legend.bg.color = "white",
          legend.bg.alpha = 0.5)

Project.shape <- tm_shape(omit.OT) +
  tm_fill(col = "Project Grants",
          palette = "YlOrRd",
          title = "Projects") +
  tm_borders("grey", lwd = 0.1) +
  tm_text("State", size = 0.8, alpha = 0.6) + 
  tm_layout(legend.title.size = 0.8,
          legend.text.size = 0.6,
          legend.position = c("left","bottom"),
          legend.bg.color = "white",
          legend.bg.alpha = 0.5)

tmap_arrange(Project.shape, ECR.shape, CD.shape, Research.shape, ncol = 2)
```

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-10-1.png)

### Data normalisation for inter-state comparisons

**Total counts can often obscure information, as certain biases are inherited.** For instance, it seems as WA, ACT, NT and TAS receive much less grant funding. This is not necessarily accurate, as their numbers of funding applications and applicants is likely much lower compared to VIC and NSW.

One way we can account for this bias is to **normalise** the total number of grants received by a factor like:

-   Total population size or
-   Total number of institutions per state (which acts as a surrogate for researcher population size)
-   Total number of unique applicants per state (ideal normalisation factor for grant funding success)

**To normalise by total population size**, we can use 2018 census data and obtain state population numbers [here](www.abs.gov.au/Population).

``` r
# Create a new dataset with population size
pop_2018 <- tibble(State = c("VIC", "NSW", "QLD", "ACT", "WA", "NT", "SA", "TAS"),
                      Pop.size = c(6459800, 7987300, 5012200, 420900, 2595900, 247300, 1736400, 528100))

# Normalisation factor = state population/ largest state population
pop_2018 <- mutate(pop_2018,
                   Pop.norm.factor = Pop.size/7987300)

# Subset only relevant datasets
pop_norm_factor <- clean_2018 %>%
  select(`APP ID`, `Grant Type`, State) %>%
  filter(`Grant Type` %in% c("Project Grants", # filters for grant types of interest 
           "Early Career Fellowships",
           "Career Development Fellowships",
           "Research Fellowships")) %>%
  group_by(`Grant Type`, State) %>%
  summarise(Count = n())

# Join the corresponding normalisation factor to each state
pop_norm_2018 <- left_join(pop_norm_factor, pop_2018,
                           by = "State") %>%
  mutate(Pop.normed.count = Count / Pop.norm.factor)
```

We can now plot graphs using normalised grant numbers. These normalised funding numbers represent the total number of grants that a state would actually have received:

-   If all populations were matched in size
-   Assuming a linear positive correlation between population size and grants funded

``` r
# Normalised project grants
Project.norm <- pop_norm_2018 %>% 
  filter(`Grant Type` == "Project Grants") %>%
  ggplot(aes(x = fct_reorder(State, Pop.normed.count), y = Pop.normed.count)) +
  geom_col() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. Project grants funded (assuming equal pop size)") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip() +
  gghighlight(!State %in% c("SA","NT","ACT"))

plot_grid(Project, Project.norm, ncol=1) 
```

<img src="NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-12-1.png" style="display: block; margin: auto;" />

**Data insights:**

-   For project grants, NT, ACT and SA perform relatively well for their relatively decreased population size.
-   Project grant success rates are potentially comparatively higher in QLD compared to NSW.

``` r
# Normalised EC Fellowships
ECR.norm <- pop_norm_2018 %>% 
  filter(`Grant Type` == "Early Career Fellowships") %>%
  ggplot(aes(x = fct_reorder(State, Pop.normed.count), y = Pop.normed.count)) +
  geom_col() +
    scale_x_discrete(position = "top",
                     drop = F) + 
  scale_y_continuous(position = "right", name = "No. funded if equal pop") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip() +
  gghighlight(!State %in% c("SA","TAS","ACT"))

# Redrawing CD Fellowships without gghighlight
CD <- clean_2018 %>% 
  filter(`Grant Type` == "Career Development Fellowships") %>%
  mutate(State = State %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = State)) +
  geom_bar() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. CD fellowships funded") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip()

# Normalised CD Fellowships
CD.norm <- pop_norm_2018 %>% 
  filter(`Grant Type` == "Career Development Fellowships") %>%
  ggplot(aes(x = fct_reorder(State, Pop.normed.count), y = Pop.normed.count)) +
  geom_col() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. funded if equal pop") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip() +
  gghighlight(!State %in% c("VIC","ACT"))

# Normalised Research Fellowships
Research.norm <- pop_norm_2018 %>% 
  filter(`Grant Type` == "Research Fellowships") %>%
  ggplot(aes(x = fct_reorder(State, Pop.normed.count), y = Pop.normed.count)) +
  geom_col() +
    scale_x_discrete(position = "top") + 
  scale_y_continuous(position = "right", name = "No. funded if equal pop") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12)) +
  coord_flip() +
  gghighlight(!State %in% c("SA","QLD", "NSW"))

total_ECR <- plot_grid(ECR, ECR.norm, ncol=1) 
total_CD <- plot_grid(CD, CD.norm, ncol=1) 
total_Research <- plot_grid(Research, Research.norm, ncol=1) 

plot_grid(total_ECR, total_CD, total_Research, ncol = 3)
```

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-13-1.png)

**Data insights:**

-   By normalising for state population size, it appears that funding success rates are more equivalent between some smaller states and VIC, with a conversely increased disparity between VIC and NSW.
-   We can clearly see that Victoria gets the lion's share of Research Fellowships.

Choosing a suitable normalisation factor is crucial. For instance, since the population size differs so much between the bigger and smaller states (by more than an order of magnitude), we may be over-correcting funding potential for the smaller states (by assuming that their success rates would have continued to linearly increase with population).

This gives rise to the question: what is the best normalisation factor to use?

### Choosing a suitable normalisation factor

**Population size** - grant success rates for smaller states may be over-modeled as the relationship between number of grant applications and number of grants funded per state is not necessarily linear, and the relationship between the number of grant applications and population size is not necessarily linear either.

**Number of institutes per state** - the assumption would be that smaller states have fewer individual institutions and this number may be a better surrogate for the number of researchers/ grant applicants per state. We can obtain this information from our current dataset.

There is, however, a possibility of underestimating institution numbers per state (especially for smaller states), as some very small institutions may not have received funding in 2018 and are hence omitted from this dataset.

**Number of unique grant applicants per state** - this is the best normalisation factor as it most accurately estimates the grant funding success rate per state. The data, however, cannot be easily obtained.

``` r
# Comparing normalisation factors - institutions per state
institutes <- clean_2018 %>% 
  select(State, `Admin Institution`) %>%
  group_by(State) %>%
  distinct(`Admin Institution`) %>%
  summarise(Institute.no = n()) %>%
  mutate(Institute.norm.factor = Institute.no/20)

norm_factor <- left_join(pop_2018, institutes,
                         by = "State") %>%
  select(State, Pop.norm.factor, Institute.norm.factor) 

norm_factor <- arrange(norm_factor, desc(Pop.norm.factor)) %>%
  mutate(Pop.norm.rank = 1:nrow(norm_factor)) %>% # rank pop norm factors
  arrange(desc(Institute.norm.factor)) %>%
  mutate(Institute.norm.rank = 1:nrow(norm_factor)) %>% # rank institute norm factors
  mutate(Pop.norm.factor = round(Pop.norm.factor, 2)) # rounds the norm factor to 2 decimal figures
  
# Drawing a table of normalisation factors and their rankings of each state

datatable(norm_factor,
          rownames = F,
          colnames = c("Population norm factor" = "Pop.norm.factor",
                       "Institute norm factor" = "Institute.norm.factor",
                       "Ranking by population" = "Pop.norm.rank",
                       "Ranking by institutions" = "Institute.norm.rank"),
          class = "hover",
          options = list(dom = "t", 
                         pageLength = 8)) %>%
  formatStyle("State", fontWeight = "bold")
```

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-14-1.png)

**Data insights:**

-   VIC is ranked higher than NSW by total institution number but not population size (which may better explain why VIC received the highest number of multiple grant types).
-   Normalising by state population versus total institution number is **surprisingly similar** for TAS, NT and SA.
-   ACT has a higher number of institutions relative to its population size, compared to the other smaller states.
-   QLD and WA have a lower number of institutions relative to their population size, compared to other states.

**Surprisingly, state rankings by either normalisation factors are relatively similar to each other**, indicating that there is likely a relationship between the two parameters (we can confirm this by calculating the correlation). Looking at this table, I would choose to normalise by total institution number when comparing state funding success, as this is a better estimation for total researcher numbers per state.

Funding and research topic coverage per state institution
=========================================================

Reasons that VIC received more funding in 2018 could include:

-   It contains more research institutions per state.
-   It contains more high-performance research institutions per state.
-   It contains more research institutions located within research hubs (requires advanced spatial data analysis).

To establish whether the first or second options are true, we can examine funding numbers across all VIC research institutions.

``` r
vic_2018 <- clean_2018 %>%
  filter(State == "VIC") %>%
  group_by(`Admin Institution`, `Grant Type`) %>%
  summarise(Count = n()) %>% 
  arrange(Count = desc(Count)) %>% as.data.frame()

# We would like to order the admin institutions by the total number of grants funded
vic.order <- clean_2018 %>%
  filter(State == "VIC") %>%
  group_by(`Admin Institution`) %>%
  summarise(Count = n()) %>%
  arrange(Count)

vic.order.levels <- vic.order$`Admin Institution`
vic_2018$`Admin Institution` <- factor(vic_2018$`Admin Institution`, levels = vic.order.levels)

# To visualise how grants types were distributed across different administrations in VIC

ggplot(vic_2018,
       aes(fill = `Grant Type`, y = Count, x = `Admin Institution`)) +
  geom_bar(stat = "identity", colour = "black") + 
  scale_y_continuous(limits = c(0, 180),
                     breaks = c(0, 30, 60, 90, 120, 150, 180)) +
  scale_fill_paletteer_d(ggsci, default_igv,
                         guide = guide_legend(nrow = 9)) +
  coord_flip() +
  theme(panel.grid.major.x = element_line(colour = "grey", linetype = 3),
        axis.title.y = element_blank(),
        legend.position = "bottom",
        legend.text = element_text(size=8),
        legend.title = element_blank())
```

![](NHMRC_analysis_2018_files/figure-markdown_github/unnamed-chunk-15-1.png)

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
-   **DataTable** - Yihui Xie, Joe Cheng and Xianying Tan (2018). DT: A Wrapper of the JavaScript Library 'DataTables'. R package version 0.5. <https://CRAN.R-project.org/package=DT>
-   **tmap** - Tennekes M (2018). "tmap: Thematic Maps in R." *Journal of Statistical Software*, *84*(6), 1-39. doi: 10.18637/jss.v084.i06 (URL: <http://doi.org/10.18637/jss.v084.i06>).
-   **Paletteer** - Emil Hvitfeldt (2018). paletteer: Comprehensive Collection of Color Palettes. R package version 0.1.0. <https://CRAN.R-project.org/package=paletteer>

**Resources:**

-   [How to arrange plots using cowplot](https://cran.r-project.org/web/packages/cowplot/vignettes/plot_grid.html)
-   [Guide to categorical data analysis using forcats](https://r4ds.had.co.nz/factors.html)
-   [R for Data Science](https://r4ds.had.co.nz)
-   [How to use geospatial data in R](https://blog.exploratory.io/making-maps-for-australia-states-and-local-government-areas-in-r-d78edb506f37)
