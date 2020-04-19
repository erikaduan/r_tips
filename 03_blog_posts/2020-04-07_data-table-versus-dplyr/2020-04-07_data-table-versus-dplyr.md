You can use data.table or tidyverse\!
================
Erika Duan
2020-04-19

  - [Introduction](#introduction)
  - [Creating a test dataset](#creating-a-test-dataset)
  - [Basic `data.table` operations](#basic-data.table-operations)
      - [Filtering data](#filtering-data)
      - [Sorting data](#sorting-data)
      - [Selecting columns](#selecting-columns)
      - [Creating and transforming
        columns](#creating-and-transforming-columns)
      - [Transforming multiple columns](#transforming-multiple-columns)
      - [Pipes versus chains](#pipes-versus-chains)
  - [Group by operations](#group-by-operations)
      - [Using group by with `.N`](#using-group-by-with-.n)
      - [Grouping by multiple
        variables](#grouping-by-multiple-variables)
      - [Using group by with row-wise
        operations](#using-group-by-with-row-wise-operations)
      - [Using group by to extract the first or last
        row](#using-group-by-to-extract-the-first-or-last-row)
      - [Using group by with `lead` or `lag`
        operations](#using-group-by-with-lead-or-lag-operations)
      - [Group by using a numeric instead of character variable
        type](#group-by-using-a-numeric-instead-of-character-variable-type)
  - [The magic behind the code](#the-magic-behind-the-code)
  - [Other resources](#other-resources)

``` r
#-----load required packages-----  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,
               ids,
               tidyverse,
               data.table,
               compare, # compare between data frames
               microbenchmark)
```

# Introduction

One of the great benefits of following Rstats conversations on Twitter
is its access to user insights. I became curious about `data.table`
after reading conversations about its superior performance yet decreased
visibility compared to `tidyverse`.

The comments from `data.table` users described how I was using R quite
accurately. I was someone who:

  - Did not come from a computer programming background.
  - Only started using R in 2017, when excellent packages in the
    `tidyverse` family were highly visible.

<img src="../../02_figures/2020-04-07_twitter-post-data-table.jpg" width="60%" style="display: block; margin: auto;" />

Fast forward a few years and the [data processing
efficiency](https://h2oai.github.io/db-benchmark/) of `data.table` has
become extremely handy:

  - When I have very large datasets (datasets over 1 million rows)
    **and**  
  - I constantly need to use `group by` operations to extract new data
    features.

Let me show you what I mean.

# Creating a test dataset

Imagine you have a dataset describing how students are engaging with
online courses:

  - Each student has a unique ID.  
  - There are 5 different online platforms (labelled platforms A, B, C
    and D).
  - Students have the option of taking different courses within the same
    platform or by switching to a different platform.  
  - Start dates are recorded when the student first signs up to a
    platform and when the student first starts a course within a
    platform.  
  - End dates are also recorded when the student finishes with an
    individual course and individual provider.

**Note:** The code used to create the test dataset can be accessed from
the `Rmd` file accompanying this tutorial.

``` r
#-----using kable to quickly visualise the test dataset-----  
student_courses %>%
  head(10) %>%
  knitr::kable()
```

| student\_id | online\_platform | online\_course       | platform\_start\_date | platform\_end\_date |
| :---------- | :--------------- | :------------------- | :-------------------- | :------------------ |
| 00005ccd    | B                | website\_design      | 2017-11-12            | 2018-01-15          |
| 00005ccd    | D                | data\_mining         | 2018-11-17            | 2019-05-10          |
| 00005ccd    | E                | Python\_intermediate | 2018-04-25            | 2018-06-30          |
| 00005ccd    | C                | accounting           | 2018-04-18            | 2018-09-29          |
| 00005ccd    | E                | bread\_baking        | 2019-04-28            | 2019-05-29          |
| 00005ccd    | D                | poetry\_writing      | 2019-05-14            | 2019-06-04          |
| 00005ccd    | A                | website\_design      | 2017-10-08            | 2018-03-20          |
| 00005ccd    | A                | Python\_advanced     | 2017-10-08            | 2018-03-20          |
| 00005ccd    | A                | poetry\_writing      | 2017-10-08            | 2018-03-20          |
| 00005ccd    | C                | metal\_welding       | 2017-05-17            | 2017-08-16          |

# Basic `data.table` operations

A data frame can be converted into a `data.table` using the `setDT`
function. This function is handy as it assigns both `data.table` and
`data.frame` classes to the original object.

``` r
#-----converting a data frame into a data table-----  
# class(student_courses)
#> [1] "tbl_df"     "tbl"        "data.frame"

setDT(student_courses)  

# class(student_courses)
#> [1] "data.table" "data.frame"  
```

The general form of a `data.table` query is structured in the form
`DT[i, j, by]` where:

  - Data subsetting (i.e. filtering rows) is performed using `i`.  
  - Data column selection or creation is performed using `j`.  
  - Grouping data by a variable is performed using `by`.

## Filtering data

The syntax for filtering data is very similar between `tidyverse` and
`data.table`. In the absence of `group by` operations, the data
processing speed is also similar when using large datasets.

**Note:** Both `tidyverse` and `data.table` provide the `between`
function for filtering from the left and the right of a numerical vector
of values.

``` r
#-----filtering data using tidyverse-----
t_platform_A_C_D <- student_courses %>%
  filter(online_platform %in% c("A", "C", "D"))

#-----filtering data using data.table-----
dt_platform_A_C_D <- student_courses[online_platform %in% c("A", "C", "D")]  

#-----filtering between dates using tidyverse-----
t_platform_between_2018_2019 <- student_courses %>%
  filter(between(platform_start_date, "2018-01-01", "2019-01-01"))

#-----filtering between dates using data.table-----
dt_platform_between_2018_2019 <- student_courses[platform_start_date %between% c("2018-01-01", "2019-01-01")]

# date objects are stored as integers in R and can be manipulated like numeric vectors  
```

When we use `microbenchmark` to compare execution times (using the
argument `times = 10`), `tidyverse` and `data.table` are comparable with
each other. Filtering between a range of numerical vectors is slightly
faster in `data.table`.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-8-1.png" width="70%" style="display: block; margin: auto;" />

## Sorting data

Like subsetting and filtering, data sorting is also performed inside `i`
of `DT[i, j, by]`.

``` r
#-----sorting data using tidyverse-----  
t_sorted <- student_courses %>%
  arrange(student_id,
          online_platform,
          online_course,
          desc(platform_start_date))  

# sort student_id, online_platform and online_courses alphabetically (ascending)
# then sort platform_start_date by most recent date (descending) 

#-----sorting data using data.table-----
dt_sorted <- student_courses[order(student_id,
                                   online_platform,
                                   online_course,
                                   -platform_start_date)]  
```

Here, the takeaway message is that sorting data by multiple variables
(i.e. columns) is computationally expensive, with `data.table`
outperforming `tidyverse`. A handy way to avoid redundant sorting
operations is to sort your dataset once early in your data cleaning
workflow, after you have loaded your raw data, renamed your columns and
performed some basic cleaning.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />

## Selecting columns

In `data.table`, column selection is performed inside `j` of `DT[i, j,
by]` and returns either a vector or another `data.table`. A `data.table`
is only returned if the variable selection is wrapped inside a list.

In `tidyverse`, performing data frame operations will always return
another data frame, unless you explicitly use `pull` to extract a column
as a vector.

``` r
#-----selecting a column using tidyverse-----    
t_student_ids <- student_courses %>%
  select(student_id) # produces a data frame by default 

v_student_ids <- student_courses %>%
  pull(student_id) # pulls out a vector

t_student_course_info <- student_courses %>%
  select(student_id,
         online_platform,
         online_course)

# class(t_student_ids)
#> [1] "data.table" "data.frame" 

# class(v_student_ids)
#> [1] "character"

# class(t_student_course_info)
#> [1] "data.table" "data.frame"

#-----selecting a column using data.table-----  
v_student_ids <- student_courses[,
                                 student_id] # produces a vector

dt_student_ids <- student_courses[,
                                  .(student_id)] # .() wraps the output as a list  

dt_student_course_info <- student_courses[,
                                          .(student_id,
                                            online_platform,
                                            online_course)]

# class(v_student_ids)
#> [1] "character"

# class(dt_student_ids)
#> [1] "data.table" "data.frame"

# class(dt_student_course_info)
#> [1] "data.table" "data.frame"
```

We can see that `tidyverse` outperforms `data.table` when we need to
subset columns inside a data frame.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />

## Creating and transforming columns

A feature of `data.table` is that only the operations performed inside
`j` of `DT[i, j, by]` are stored in the new `data.table`. This contrasts
with the `mutate` function from `tidyverse`, which always creates a new
column or transforms an existing column inside the original data frame.

In `data.table`, the use case `:=` also exists. This can only be used on
a single operation per `data.table` but it retains all other columns
from the original `data.table`.

**Note:** Although `data.table` allows columns to be modified by
reference (without re-assigning the result back to a variable),
re-assigning results is always recommended for maintaining code
readability.

``` r
#----creating a function to convert days into weeks-----
convert_days_to_weeks <- function(day){
  if (is.character(day)) {
    stop("Please input a number i.e. number of days.")  
  }
  if (is.numeric(day)) {
    return(day/7)
  }
  day <- as.numeric(day)
  day/7
}

#-----creating new platform_length columns using tidyverse-----
t_platform_length <- student_courses %>%
  mutate(platform_length_days = platform_end_date - platform_start_date,
         platform_length_weeks = convert_days_to_weeks(platform_length_days))    

# colnames(t_platform_length) 
#> [1] "df_index"              "student_id"            "online_platform"       "online_course"        
#> [5] "platform_start_date"   "platform_end_date"     "platform_length_days"  "platform_length_weeks"

#-----creating new platform_length columns using data.table-----  
# note the difference between using = and := 

dt_platform_length <- student_courses[,
                                      .(platform_length_days = platform_end_date - platform_start_date)]

# colnames(dt_platform_length)
#> [1] "platform_length_days"  

dt_platform_length <- student_courses[,
                                      platform_length_days := platform_end_date - platform_start_date
                                      ][, 
                                        platform_length_weeks := convert_days_to_weeks(platform_length_days)]

# colnames(dt_platform_length)
#> [1] "df_index"              "student_id"            "online_platform"       "online_course"        
#> [5] "platform_start_date"   "platform_end_date"     "platform_length_days"  "platform_length_weeks"  

# keeping operations inside {} allows suppression of intermediate outputs 

dt_platform_length_weeks <- student_courses[,
                                            {platform_length_days = platform_end_date - platform_start_date
                                            platform_length_weeks = convert_days_to_weeks(platform_length_days)
                                            .(platform_length_weeks = platform_length_weeks)}]  

# colnames(dt_platform_length_weeks)  
#> [1] "platform_length_weeks"
```

Performance is similar for `tidyverse` and `data.table` when creating
new columns. Somewhat surprising, creating a `data.table` which only
returns the variable(s) of interest i.e. `dt_platform_length_weeks` does
not improve computational efficiency compared with `mutate`, which
returns all variables in the data frame.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />

## Transforming multiple columns

But what happens when we need to perform the same operation on multiple
columns? In `tidyverse`, we can use `mutate_if`, `mutate_at` or
`mutate_all` to select our columns of interest and apply a function
across all selected columns. In `data.table`, this operation is
facilitated by the symbols `.SD` and `.SDcols`. The symbol `.SD` stands
for subset of data and represents a `data.table` which contains a
defined set of columns or grouped columns.

**Note:** The syntax of `mutate` has recently been
[updated](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/)
so that the function `across` substitutes the need for separate
`mutate_if`, `mutate_at` and `mutate_all` functions.

``` r
#-----transforming multiple columns using tidyverse-----  
t_all_upper <- student_courses %>%
  mutate_at(c("student_id", "online_course"), # variables of interest
            ~ toupper(.)) # function of interest

#-----transforming multiple columns using data.table-----    
dt_all_upper <- student_courses[,
                                lapply(.SD, toupper), # function of interest  
                                .SDcols = c("student_id", "online_course")] # variables of interest  

# note that dt_all_upper only contains the transformed columns     
```

## Pipes versus chains

No data frame operation is an island. The `tidyverse` packages allow
piping of functions via `%>%` to increase code readability. In
`data.table`, the equivalent concept is called chaining via `[]` to link
a series of operations together.

``` r
#-----piping with tidyverse data frames-----  
with_pipes <- student_courses %>%
  filter(online_platform == "B") %>%
  mutate(status = "special_cohort") %>%  
  arrange(student_id,
          desc(platform_start_date),
          desc(platform_end_date)) %>%
  select(student_id, online_platform, online_course, status)

#-----chaining with data.table----- 
with_chaining <- student_courses[online_platform == "B"
                                 ][, status := "special_cohort"
                                   ][order(student_id, -platform_start_date, -platform_end_date)
                                     ][, .(student_id, online_platform, online_course, status)]  

# compare(with_chaining, with_pipes, ignoreAttrs = T)
#> TRUE
#>   dropped attributes

# note that chaining allows a filtered data frame to first be subsetted and then transformed  
# without chaining, the transformation is applied where relevant across the whole data table     

no_chaining <- student_courses[online_platform == "B", status := "special_cohort"
                               ][order(student_id, -platform_start_date, -platform_end_date)
                                 ][, .(student_id, online_platform, online_course, status)]    

head(with_chaining)
```

    ##    student_id online_platform       online_course         status
    ## 1:   00005ccd               B      website_design special_cohort
    ## 2:   0000a626               B      website_design special_cohort
    ## 3:   0000a626               B      website_design special_cohort
    ## 4:   0001c631               B Python_intermediate special_cohort
    ## 5:   00023a86               B          R_beginner special_cohort
    ## 6:   00023a86               B           UX_design special_cohort

``` r
head(no_chaining)
```

    ##    student_id online_platform       online_course         status
    ## 1:   00005ccd               D      poetry_writing           <NA>
    ## 2:   00005ccd               E        bread_baking           <NA>
    ## 3:   00005ccd               D         data_mining           <NA>
    ## 4:   00005ccd               E Python_intermediate           <NA>
    ## 5:   00005ccd               C          accounting           <NA>
    ## 6:   00005ccd               B      website_design special_cohort

# Group by operations

## Using group by with `.N`

Group by operations are important when you have multiple rows of data
for each unit of interest, and you need to summarise those rows into a
single property. A grouping is specified using the `group_by` function
in `tidyverse` and inside `by` of `DT[i, j, by]`.

For instance, let’s say that I am interested in the total number of
online courses taken per student.

``` r
#-----using group_by, summarise and n() from tidyverse-----  
t_courses_per_student <- student_courses %>%
  group_by(student_id) %>%
  summarise(total_online_courses = n()) %>%
  ungroup # always ungroup after using group_by      

#-----using by and .N from data.table-----  
dt_courses_per_student <- student_courses[,
                                          .(total_online_courses = .N),
                                          by = student_id]
```

This is different to finding the total number of **unique** online
courses taken per student (as it is possible for a student to have taken
the same online course through a different platform, or repeated the
same course through the same platform at a later date).

``` r
#-----using group_by, summarise and n_distinct() from tidyverse-----  
t_unique_courses_per_student <- student_courses %>%
  group_by(student_id) %>%
  summarise(total_online_courses = n_distinct(online_course)) %>%
  ungroup      

# summary(df_unique_courses_per_student$total_online_courses == df_courses_per_student$total_online_courses)
#>     Mode   FALSE    TRUE 
#>  logical   44500   35347 

#-----using by and length(unique(.x)) from data.table-----  
dt_unique_courses_per_student <- student_courses[,
                                                 .(total_online_courses = length(unique(online_course))),
                                                 by = student_id]

# avoid using uniqueN as it is much slower than length(unique(.x))  
```

We can see that `data.table` performs faster than `tidyverse` once we
need to group by variables. An exception to this trend is when we
specifically use `length(unique(.x))` inside a grouped `data.table`.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-19-1.png" width="70%" style="display: block; margin: auto;" />

## Grouping by multiple variables

Does the difference in performance between `data.table` and `tidyverse`
widen further when we need to group by multiple variables of interest?

Let’s say that I am now interested in the total number of online courses
taken per student per unique online platform.

**Note:** Unlike `tidyverse`, `data.table` intentionally retains the
original order of the groups that it encounters. Using `keyby` instead
of `by` allows sorting by the grouped variables without significantly
decreasing `data.table` performance.

``` r
#-----grouping by two variables using tidyverse-----  
t_courses_per_student_per_platform <- student_courses %>%
  group_by(student_id, online_platform) %>%
  summarise(total_online_courses = n()) %>%
  ungroup      

head(t_courses_per_student_per_platform)
```

    ## # A tibble: 6 x 3
    ##   student_id online_platform total_online_courses
    ##   <chr>      <chr>                          <int>
    ## 1 00005ccd   A                                  3
    ## 2 00005ccd   B                                  1
    ## 3 00005ccd   C                                  2
    ## 4 00005ccd   D                                  2
    ## 5 00005ccd   E                                  2
    ## 6 0000a626   A                                  1

``` r
#-----grouping by two variables using data.table-----   
dt_courses_per_student_per_platform <- student_courses[,
                                                       .(total_online_courses = .N),
                                                       by = .(student_id,
                                                              online_platform)]  

head(dt_courses_per_student_per_platform)
```

    ##    student_id online_platform total_online_courses
    ## 1:   00005ccd               B                    1
    ## 2:   00005ccd               D                    2
    ## 3:   00005ccd               E                    2
    ## 4:   00005ccd               C                    2
    ## 5:   00005ccd               A                    3
    ## 6:   0000a626               D                    2

``` r
# using keyby instead of by allows sorting by the variables in our grouping 

dt_courses_per_student_per_platform <- student_courses[,
                                                       .(total_online_courses = .N),
                                                       keyby = .(student_id,
                                                                 online_platform)] 

head(dt_courses_per_student_per_platform)
```

    ##    student_id online_platform total_online_courses
    ## 1:   00005ccd               A                    3
    ## 2:   00005ccd               B                    1
    ## 3:   00005ccd               C                    2
    ## 4:   00005ccd               D                    2
    ## 5:   00005ccd               E                    2
    ## 6:   0000a626               A                    1

We can see that the addition of a second variable grouping does not
greatly decrease `data.table` performance in contrast to `tidyverse`.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />

## Using group by with row-wise operations

Let’s say that I am now interested in understanding the minimum, maximum
and mean length of time (in weeks) that a student spends on each online
platform.

``` r
#----group by and row-wise operations using tidyverse-----
t_time_per_student_per_platform <- student_courses %>%
  group_by(student_id, online_platform) %>%
  summarise(min_weeks = min(platform_length_weeks),
            mean_weeks = mean(platform_length_weeks),
            max_weeks = max(platform_length_weeks)) %>%
  ungroup()

#----group by and row-wise operations using data.table-----  
dt_time_per_student_per_platform <- student_courses[,
                                                    .(min_weeks = min(platform_length_weeks),
                                                      mean_weeks = mean(platform_length_weeks),
                                                      max_weeks = max(platform_length_weeks)),
                                                    keyby = .(student_id, online_platform)]
```

Once again, `data.table` runs much faster than `tidyverse` when we need
to perform row-wise operations on groups of variables.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-23-1.png" width="70%" style="display: block; margin: auto;" />

## Using group by to extract the first or last row

Let’s say that I am now interested in extracting information about the
first and last online course per platform that each student has enrolled
in. To do this, I might want to group by `student_id` and
`online_platform`, and then separately extract the first and last row of
data per student.

``` r
#-----group by and extracting row-wise data using tidyverse-----
t_first_course_per_platform <- student_courses %>%
  arrange(platform_start_date) %>%  
  group_by(student_id, online_platform) %>%
  filter(row_number() == 1L) %>%
  ungroup()

t_last_course_per_platform <- student_courses %>%
  arrange(platform_start_date) %>%  
  group_by(student_id, online_platform) %>%
  filter(row_number() == n()) %>%
  ungroup()

#-----group by and extracting row-wise data using data.table-----  
dt_first_course_per_platform <- student_courses[order(platform_start_date)
                                                ][,
                                                  .SD[1L],
                                                  by = .(student_id, online_platform)] 

dt_last_course_per_platform <- student_courses[order(platform_start_date)
                                               ][,
                                                 .SD[.N],
                                                 by = .(student_id, online_platform)]
```

Interestingly, performing row extraction is significantly faster in
`data.table` compared to `tidyverse`, except when an arbitary row number
(i.e. the last row in a group) is called. In the latter scenario,
`data.table` appears to perform much worse than `tidyverse`.

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" />

## Using group by with `lead` or `lag` operations

A problem exists, however, in the previous code as it groups together
and summarises information about the same online platform regardless of
event sequence. This does not actually reflect what is happening inside
the data.

``` r
#-----examining the dataset using student_id == "00028486"-----
student_courses %>%
  filter(student_id == "00028486") %>%
  arrange(platform_start_date) %>%
  select(student_id,
         online_platform,
         online_course,
         platform_start_date)
```

    ##   student_id online_platform    online_course platform_start_date
    ## 1   00028486               E machine_learning          2016-03-21
    ## 2   00028486               A   website_design          2016-07-13
    ## 3   00028486               D      data_mining          2018-02-26
    ## 4   00028486               D machine_learning          2019-08-10
    ## 5   00028486               D       R_beginner          2019-08-10
    ## 6   00028486               D   website_design          2019-08-10
    ## 7   00028486               A       R_advanced          2019-11-26

If we closely examine the data, it is quite common for students to sign
up to one online platform, then switch to another platform, before
switching back to the first platform later on. If many scenarios, we
would want to view this switch as a new subset of data about a separate
online platform (for example, if we are interested in understanding
whether the first course a student takes influences their likelihood of
staying longer with the same online provider).

How might we code each subsequent platform switch as a separate online
platform experience? By making use of `lag` (i.e. previous) and `lead`
(i.e. next) operations.

``` r
#-----using lead, case_when and fill with tidyverse to create seq_online_platform-----  
t_sep_online_platforms <- student_courses %>%
  group_by(student_id) %>% 
  arrange(student_id, platform_start_date) %>% 
  mutate(lag_online_platform = lag(online_platform, 1L),
         seq_online_platform = case_when(is.na(lag_online_platform) ~ row_number(),
                                         online_platform != lag_online_platform ~ row_number())) %>%
  fill(seq_online_platform, .direction = "down") %>%
  ungroup()

# lag_online_platform produces an NA in the first row of each subset as we have grouped by student_id

# create a new column where the NA from lag_online_platform corresponds to its row number
# ammend that column so a row number is also created where online_platform != lag_online_platform  
# remaining NAs reflect situations where online_platform == lag_online_platform 
# fill all remaining NAs (NAs are below the value to be filled)   

#-----group by seq_online_platform and extract the first online course using tidyverse-----
t_first_course_per_platform_seq <- t_sep_online_platforms %>%
  group_by(student_id, seq_online_platform) %>%
  filter(row_number() == 1L) %>%
  ungroup()

#-----correct way of extracting the first course per platform-----
t_first_course_per_platform_seq %>%
  filter(student_id == "00028486") %>%
  select(student_id,
         online_platform,
         online_course,
         platform_start_date)
```

    ## # A tibble: 4 x 4
    ##   student_id online_platform online_course    platform_start_date
    ##   <chr>      <chr>           <chr>            <date>             
    ## 1 00028486   E               machine_learning 2016-03-21         
    ## 2 00028486   A               website_design   2016-07-13         
    ## 3 00028486   D               data_mining      2018-02-26         
    ## 4 00028486   A               R_advanced       2019-11-26

``` r
#-----previously incorrect way of extracting the first course per platform-----
t_first_course_per_platform  %>%
  filter(student_id == "00028486") %>% 
    select(student_id,
         online_platform,
         online_course,
         platform_start_date)
```

    ## # A tibble: 3 x 4
    ##   student_id online_platform online_course    platform_start_date
    ##   <chr>      <chr>           <chr>            <date>             
    ## 1 00028486   E               machine_learning 2016-03-21         
    ## 2 00028486   A               website_design   2016-07-13         
    ## 3 00028486   D               data_mining      2018-02-26

Performing all these steps in `data.table` will be possible once
`fcase`, its equivalent of `case_when`, is released in [data.table
v1.12.9](https://stackoverflow.com/questions/53031140/data-table-alternative-for-dplyr-case-when).

``` r
#-----using lead and fill with data.table to create seq_online_platform in data.table-----  
dt_sep_online_platforms <- student_courses[order(student_id, platform_start_date)
                                           ][,
                                             lag_online_platform := shift(online_platform, 1L, type = "lag"),
                                             by = student_id] 

# convert back to tidyverse mutate syntax until fcase is released for data.table

dt_sep_online_platforms <- dt_sep_online_platforms %>%
  mutate(lag_online_platform = lag(online_platform, 1L),
         seq_online_platform = case_when(is.na(lag_online_platform) ~ row_number(),
                                         online_platform != lag_online_platform ~ row_number()))

# conversation into data.table class required

setDT(dt_sep_online_platforms)

setnafill(dt_sep_online_platforms, # data.table syntax for fill
          type = "locf", # last observation carried forward
          cols = "seq_online_platform")

#-----group by and extracting row-wise data using data.table-----  
dt_first_course_per_platform_seq <- dt_sep_online_platforms[,
                                                            .SD[1L],
                                                            by = .(student_id, seq_online_platform)] 

# compare(dt_first_course_per_platform$online_course, t_first_course_per_platform_seq$online_course)
#> TRUE
```

We can also check how long it takes to run each segment of the code
written above. Once again, `data.table` operations are faster than
`tidyverse` operations when we need to group by variables. It will be
interesting to see whether `fcase` can perform significantly faster than
`case_when` in the future.

    ## # A tibble: 4 x 3
    ##   Tasks                                      Tidyverse      `Data table`   
    ##   <chr>                                      <drtn>         <drtn>         
    ## 1 Sort by student ID & platform start date    3.233297 secs 0.845043898 se~
    ## 2 Create new lag values grouped by student ~  4.638682 secs 2.660112143 se~
    ## 3 Perform case_when grouped by student ID    21.866270 secs          NA se~
    ## 4 Fill NAs grouped by student ID              2.968479 secs 0.005473137 se~

## Group by using a numeric instead of character variable type

There is an additional trick to improving the speed of group by
operations regardless of using `tidyverse` or `data.table`. It is always
much faster to perform operations on `numeric` compared to `character`
vector types.

If there is a character variable type that you need to group by
repeatedly, it is more efficient to create an equivalent numeric
variable type and group by that instead.

``` r
#-----converting character ids into numeric ids using tidyverse-----
student_courses <- student_courses %>%
  mutate(student_id_num = factor(student_id, levels = unique(student_id)),
         student_id_num = as.numeric(student_id_num))

# note that mutating a data table converts it into a tibble  

#-----using group_by, summarise and n() on a character id from tidyverse-----  
t_courses_per_student <- student_courses %>%
  group_by(student_id) %>%
  summarise(total_online_courses = n()) %>%
  ungroup      

#-----using group_by, summarise and n() on a numeric id from tidyverse-----  
t_courses_per_student_num <- student_courses %>%
  group_by(student_id_num) %>%
  summarise(total_online_courses = n()) %>%
  ungroup    

#-----using group_by, summarise and n() on a character id from data.table-----  
setDT(student_courses) # convert back to data.table format 

dt_courses_per_student <- student_courses[,
                                          .(total_online_courses = .N),
                                          by = student_id] 

#-----using group_by, summarise and n() on a character id from data.table-----  
dt_courses_per_student <- student_courses[,
                                          .(total_online_courses = .N),
                                          by = student_id_num]  
```

You can see that grouping by a numeric variable type using `tidyverse`
outperforms grouping by a character variable type using `data.table`\!
Of course, the fastest operation is to group by a numerical variable
type using `data.table.`

<img src="2020-04-07_data-table-versus-dplyr_files/figure-gfm/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

# The magic behind the code

So why are `data.table` operations more efficient than `tidyverse` when
variable groupings are involved? We can find an explanation
[here](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-keys-fast-subset.html).

It turns out that `data.table` operations make use of automatic indexing
and binary search based subsetting. In contrast, `tidyverse` operations
rely on vector scans, which process information row by row to create
logical vectors (containing either `TRUE` or `FALSE` as its output) of
size `nrow(dataset)`. Intermediate outputs are stored as separate
logical vectors. The last step involves returning all the rows where the
expression evaluates to `TRUE`.

In contrast, an index is automatically generated on a key during the
first `data.table` operation. Subsequent operations are performed on
subsets of matching row indices, which negates the need to iteratively
generate and then compare between multiple `nrow(dataset)` length
vectors.

# Other resources

  - The definitive [stack overflow
    discussion](https://stackoverflow.com/questions/21435339/data-table-vs-dplyr-can-one-do-something-well-the-other-cant-or-does-poorly/27840349#27840349)
    about the best use cases for data.table versus dplyr (from
    tidyverse).

  - A great side by side comparison of data.table versus dplyr
    operations by
    [Atrebas](https://atrebas.github.io/post/2019-03-03-datatable-dplyr/).

  - A list of advanced `data.table` operations and tricks by [Andrew
    Brooks](http://brooksandrew.github.io/simpleblog/articles/advanced-data-table/).

  - Datacamp’s \`data.table
    [cheatsheet](https://s3.amazonaws.com/assets.datacamp.com/blog_assets/datatable_Cheat_Sheet_R.pdf).

  - An explanation of how `data.table` modifies by reference by [Tyson
    Barrett](https://tysonbarrett.com//jekyll/update/2019/07/12/datatable/).

  - A section explaining `data.table` efficiency in [Efficient R
    programming by Colin Gillespie and Robin
    Lovelace](https://csgillespie.github.io/efficientR/data-processing-with-data-table.html).

  - A more detailed explanation of the usage of binary search based
    subset in `data.table` by [Arun
    Srinivasan](https://gist.github.com/arunsrinivasan/dacb9d1cac301de8d9ff).
