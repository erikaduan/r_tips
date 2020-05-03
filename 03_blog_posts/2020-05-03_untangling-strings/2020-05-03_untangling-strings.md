Untangling strings (\#@%\*\!\!)
================
Erika Duan
2020-05-03

  - [Introduction](#introduction)
  - [Creating a test dataset](#creating-a-test-dataset)
  - [Improve readability of comment
    fields](#improve-readability-of-comment-fields)
  - [Other resources](#other-resources)

# Introduction

Comment fields sit somewhere in between tidy tabular data entries and
large text files (i.e. documents) in terms of wrangling effort. They
still require human naunce to decode and more problematically, the
quality and completeness of comment entries varies depending on
individual engagement with reporting requirements.

This can make it hard to gauge whether wrangling comment fields is a
fruitful endeavour (especially when you have ten other data sources that
need examining). Luckily, some knowledge of string manipulations and
regular expressions can help simplify this process.

# Creating a test dataset

Let’s imagine that my local chocolate company, [Haighs
Chocolates](https://www.haighschocolates.com.au), wants to understand
what food critics and Haighs Chocolates fans think about their newest
product. They send out a bag of free samples with a link to an online
survey that asks individuals to rate the chocolates (from a scale of 1
to 10) and provide additional comments.

**Note:** The code used to create this dataset can be accessed from the
`Rmd` file accompanying this tutorial.

``` r
#-----quickly visualise the test dataset-----  
survey %>%
  head(10) # fields containing html flags are not properly rendered by kable 
```

    ## # A tibble: 10 x 3
    ##    respondee rating comment_field                                          
    ##    <chr>     <chr>  <chr>                                                  
    ##  1 expert_1  8      "<textarea name=\"comment\" form=\"1\"> Grade A beans.~
    ##  2 expert_2  7      "<textarea name=\"comment\" form=\"1\"> Grade A beans ~
    ##  3 expert_3  8      "<textarea name=\"comment\" form=\"1\"> Grade A beans.~
    ##  4 expert_4  10     "<textarea name=\"comment\" form=\"1\"> Grade A cocoa ~
    ##  5 expert_5  7      "<textarea name=\"comment\" form=\"1\"> Grade A beans,~
    ##  6 fan_1     9      "<textarea name=\"comment\" form=\"1\"> Delicious and ~
    ##  7 fan_2     10     "<textarea name=\"comment\" form=\"1\"> Smooth dark ch~
    ##  8 fan_3     8      "<textarea name=\"comment\" form=\"1\"> Tastes great. ~
    ##  9 fan_4     10     "<textarea name=\"comment\" form=\"1\"> This will be o~
    ## 10 fan_5     9      "<textarea name=\"comment\" form=\"1\"> Haighs has a h~

# Improve readability of comment fields

``` r
#-----readability with regex and comments-----  
```

# Other resources

  - <https://cran.r-project.org/web/packages/stringr/vignettes/regular-expressions.html>  
  - <https://r4ds.had.co.nz/strings.html>
