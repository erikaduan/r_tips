Working with dummy variables and factors
================
Erika Duan
2020-04-26

  - [Introduction](#introduction)
  - [Creating a test dataset](#creating-a-test-dataset)
  - [Working with factors](#working-with-factors)
      - [Creating factors](#creating-factors)
  - [Modifying factor levels](#modifying-factor-levels)
  - [Using dummy variables](#using-dummy-variables)
  - [Creating dummy variables](#creating-dummy-variables)

``` r
#-----load required packages-----  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,
               tidyverse,
               fastDummies) # for creating dummy variables
```

# Introduction

I found myself wrangling factor levels for a good 30+ minutes earlier
this week. The need arose from different machine learning models
requiring different data input requirements.

Let’s say you have a binary classification problem and you want to test
a random forest model, a gradient boosted tree (XGBoost) model and a
support vector model (SVM) model.

**Requirements:**

  - The random forest model handles both numerical categorical and
    numeric variables. The response variable needs to be a factor.

  - The XGBoost model only handles numerical variables. The predictor
    variable needs to be converted into a numerical vector (i.e. `0` or
    `1`).

  - The linear SVM model requires scaled numerical variables. The
    predictor variable needs to be converted into a factor that is not
    represented as `0` or `1`.

Let’s explore a fun test dataset.

# Creating a test dataset

Cats are such idiosyncratic creatures. You can never tell if some cats
wants a pat or to bite you instead. So what if machine learning could
help us better understand cats (to pat or not to pat - that is the
question)?

**Note:** The code used to create this dataset can be accessed from the
`Rmd` file accompanying this tutorial.

``` r
#-----using kable to quickly visualise the test dataset-----  
cat_prediction %>%
  head(10) %>%
  knitr::kable()
```

| cat\_breed         | age | fav\_activity       | likes\_children | will\_bite |
| :----------------- | --: | :------------------ | :-------------- | :--------- |
| mixed              | 5.0 | napping             | no              | no         |
| bengal             | 7.2 | napping             | no              | no         |
| siamese            | 0.8 | sitting\_on\_humans | no              | no         |
| bengal             | 4.0 | napping             | no              | no         |
| british\_shorthair | 4.8 | hunting\_toys       | no              | yes        |
| bengal             | 5.8 | sitting\_on\_humans | no              | yes        |
| aristocat          | 5.8 | sitting\_on\_humans | no              | no         |
| bengal             | 7.0 | napping             | no              | yes        |
| siamese            | 5.6 | napping             | no              | no         |
| ragdoll            | 2.3 | hunting\_toys       | no              | no         |

# Working with factors

## Creating factors

There are two ways to handle factors:

  - Using base `R` to create factors and modify factor levels.  
  - Using [`forcats`](https://r4ds.had.co.nz/factors.html) from the
    `tidyverse` library to simplify complex factor wrangling.

Using `factor` without specifying factor levels automatically converts
character vectors into a numerical index of character vectors.
Specifying factor levels also allows you to specify the order of levels.

**Note:** Factor levels need to match `unique(vector_values)` to prevent
the generation of `NA` values.

``` r
#-----converting the response variable into a factor using base R-----  
cat_prediction_factor <- factor(cat_prediction$will_bite)

# str(cat_prediction$will_bite)
#> Factor w/ 2 levels "no","yes": 1 1 2 1 2 2 1 2 2 1 ...  

cat_prediction_factor <- factor(cat_prediction$will_bite,
                                   levels = c("no", "yes")) 

# make sure levels == unique(cat_prediction$will_bite)
# otherwise your response variable will be converted into NAs

cat_prediction_char <- as.character(cat_prediction_factor)  

# str(cat_prediction_char)
#> chr [1:500] "no" "no" "yes" "no" "yes" "yes" "no" "yes" "yes" "no" ...
```

Applying `as.character` back onto a factor returns the original
character vector, rather than the numerical index.

# Modifying factor levels

In base R, modifying factor levels directly modifies the factor itself.
I personally think that the safest way is to modify factor levels is by
specifying replacement and original level names using `list`. Note that
this approach requires all levels to be specified inside the list, or
`NA` values will be generated.

``` r
#-----converting factor levels using base R-----
levels(cat_prediction_factor) <- list(no_biting = "no",
                                      yes_ouch = "yes")

# str(cat_prediction_factor)
#> Factor w/ 2 levels "no_biting","yes_ouch": 1 1 2 1 2 2 1 2 2 1 ...

cat_prediction_char <- as.character(cat_prediction_factor)

# str(cat_prediction_char)
#>  chr [1:500] "no_biting" "no_biting" "yes_ouch" "no_biting" "yes_ouch" ...

#----the dangers of modifying levels without referencing names----- 
cat_prediction_factor <- factor(cat_prediction$will_bite,
                                   levels = c("no", "yes")) 
 
# str(cat_prediction_factor)
#> Factor w/ 2 levels "no","yes": 1 1 2 1 2 2 1 2 2 1 ...

levels(cat_prediction_factor) <- c("yes", "no") # accidentally inverting factor level order
 
# str(cat_prediction_factor)
#> Factor w/ 2 levels "yes","no": 1 1 2 1 2 2 1 2 2 1 ...
```

You can also modify factor levels using
[`fct_recode`](https://r4ds.had.co.nz/factors.html#modifying-factor-levels)
from `forcats`. The chief advantages of `fct_recode` are that:

  - It does not modify levels that are not referenced (instead of
    converting them to `NA`).  
  - It will warn you if you accidentally refer to a level that does not
    exist.

<!-- end list -->

``` r
#-----converting factor levels using forcats-----   
cat_prediction <- cat_prediction %>%
  mutate(will_bite_factor = factor(will_bite),
         will_bite_factor = fct_recode(will_bite,
                                       "no_biting" = "no",
                                       "yes_ouch" = "yes")) # new level name = old level name
```

# Using dummy variables

# Creating dummy variables

According to
[Wikipedia](https://en.wikipedia.org/wiki/Dummy_variable_\(statistics\)),
a dummy variable is one that takes only the value 0 or 1 to indicate the
absence or presence of some categorical effect that may be expected to
shift the outcome.

<https://r4ds.had.co.nz/factors.html>  
<http://www.cookbook-r.com/Manipulating_data/Renaming_levels_of_a_factor/>
