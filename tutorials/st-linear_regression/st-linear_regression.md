Build a linear regression model
================
Erika Duan
2024-06-11

-   [Why linear regression?](#why-linear-regression)
-   [Build a linear regression model](#build-a-linear-regression-model)
-   [The mathmathical intuition](#the-mathmathical-intuition)
-   [Interpret a linear regression
    model](#interpret-a-linear-regression-model)
-   [Linear regression with
    `tidymodels`](#linear-regression-with-tidymodels)
-   [Linear regression with `mlr3`](#linear-regression-with-mlr3)
-   [Other resources](#other-resources)

``` r
# Load required R packages -----------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,
               tidymodels,
               broom) 
```

# Why linear regression?

Linear regression is usually the first statistical model that people
learn about. Although it has a reputation for being a basic or
underperforming modelling approach, linear regression is still used for
different purposes.

As listed in [Regression and Other
Stories](https://avehtari.github.io/ROS-Examples/) by Gelman et al,
linear regression can be used to:

-   Predict or forecast outcomes without aiming to infer causality.  
-   Provide an explainable framework for describing associations between
    variables of interest and an outcome.  
-   Adjust outcomes from a sample to infer something about a population
    of interest.  
-   Estimate treatment effects by comparing outcomes between a treatment
    and control group in a randomised controlled trial.

Linear regression models can be misused when purposes deviate from the
ones described above. For example, some people mistakenly think that the
associations described by a linear regression model are causal rather
than just predictive.

Think about the association between the temperature and how quickly an
icecream melts. How quickly an icecream melts is positively associated
with the temperature, but an icecream melting quickly **does not cause**
the temperature to increase. Correlation is not causation (but we can
sometimes use correlations to help us design better experiments to study
causation).

# Build a linear regression model

Let’s first build a linear regression model to see what the model
produces. We will then cover the mathematical intuition, assumptions and
interpretation of linear regression models.

We will provide ourselves with a safety check though, by secreting
knowing the exact associations between our variables of interest and the
outcome (this will never happen in real life).

``` mermaid
```

# The mathmathical intuition

# Interpret a linear regression model

# Linear regression with `tidymodels`

# Linear regression with `mlr3`

# Other resources

-   <https://andrewproctor.github.io/rcourse/module5.html#regression_basics>  
-   <https://andrewproctor.github.io/rcourse/assets/module5.pdf>  
-   <https://www.andrew.cmu.edu/user/achoulde/94842/lectures/lecture09/lecture09-94842.html>  
-   <https://www.andrew.cmu.edu/user/achoulde/94842/lectures/lecture11/lecture11-94842-2020.html>
