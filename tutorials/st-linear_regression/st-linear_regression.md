Build a linear regression model
================
Erika Duan
2024-06-17

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

Linear regression models can be easily misused when purposes deviate
from the ones described above. For example, people can mistake the
associations produced by a linear regression model as being causal
rather than just predictive.

Think about the association between the temperature and how quickly an
icecream melts. How quickly an icecream melts is positively associated
with the temperature, but an icecream melting quickly **does not cause**
the temperature to increase. Correlation is not causation (but we can
sometimes use correlations to help us design better experiments to study
causation).

# Build a linear regression model

Let’s first build a linear regression model and see what the model
produces. We will then learn about the mathematical properties,
assumptions and interpretation of our model.

We will provide ourselves with a safety check, by secreting knowing the
precise associations between our variables and the outcome of interest
(this will never happen in real life).

Imagine that the amount of money a pet influencer earns (per month) is
influenced by the following variables:

-   Whether the pet is a cat or a dog or another animal species  
-   The number of photos their owner posts every month  
-   The number of videos their owner posts every month

To simplify things, We will pretend that there are no confounds between
these three variables i.e. each factor is independent of one another.

``` mermaid
flowchart LR  
  A(Animal species) --> B(monthly income) 
  C(Photos per month) --> B
  D(Videos per month) --> B

  style B fill:#Fff9e3,stroke:#333
```

We can simulate some income data to use for linear regression modelling.

``` r
# Simulate pet influencer income dataset ---------------------------------------
set.seed(111)
N <- 500  

# Simulate whether pet is dog, cat or other species   
species <- rmultinom(N, 
                     size = 1,
                     prob = c(0.6, 0.3, 0.1))

# Convert species into dummy variables     
is_dog <- species[1, 1:N]
is_cat <- species[2, 1:N]

# Simulate number of photos per month 
photos <- rpois(N, lambda = 6)

# Simulate number of videos per month
videos <- rpois(N, lambda = 2)

# Simulate monthly income  
income <- rnorm(N,
                mean = (is_dog * 2.5 + is_cat * 0.8 + photos * 0.1 + videos * 1.8) + 165,
                sd = 1)

income <- ifelse(income > 0, round(income, digits = 0), 0)

# Create dataset
data <- data.frame(
  is_dog,
  is_cat,
  photos,
  videos, 
  income
)
```

We will then split the simulated data into training and test data
subsets with a 75% versus 25% split.

``` r
# Split data into training and test data sets using base R ---------------------
set.seed(111)

# Calculate 75% of the whole data set
train_size <- floor(0.75 * nrow(data))

# Randomly sample train_size number of rows and extract the row index
train_index <- sample(seq_len(nrow(data)), size = train_size) 

train <- data[train_index, ] # Subset by train_index row index
test <- data[-train_index, ] # Subset the remaining rows
```

We will then perform multiple linear regression modelling using the
function `lm(Y ~ X1 + X2 + ... + Xn)` and view the results using
`summary()`.

``` r
# Perform multiple linear regression -------------------------------------------
mlr_model <- lm(
  train$income ~ 
    train$is_dog +
    train$is_cat +
    train$photos + 
    train$videos
)

summary(mlr_model)
```

    ## 
    ## Call:
    ## lm(formula = train$income ~ train$is_dog + train$is_cat + train$photos + 
    ##     train$videos)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -2.34946 -0.71070  0.02311  0.64107  2.59326 
    ## 
    ## Coefficients:
    ##               Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  165.16507    0.22206 743.784  < 2e-16 ***
    ## train$is_dog   2.40772    0.19125  12.590  < 2e-16 ***
    ## train$is_cat   0.67765    0.20050   3.380 0.000803 ***
    ## train$photos   0.08597    0.02097   4.099  5.1e-05 ***
    ## train$videos   1.78655    0.03463  51.592  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.9682 on 370 degrees of freedom
    ## Multiple R-squared:  0.8945, Adjusted R-squared:  0.8933 
    ## F-statistic: 784.1 on 4 and 370 DF,  p-value: < 2.2e-16

Goodness, this all looks very complicated. Let us now examine the
important results from `summary(mlr_model)` by learning about the
mathematical properties of a linear regression model.

# The mathmathical intuition

# Interpret a linear regression model

# Linear regression with `tidymodels`

# Linear regression with `mlr3`

# Other resources

-   <https://andrewproctor.github.io/rcourse/module5.html#regression_basics>  
-   <https://andrewproctor.github.io/rcourse/assets/module5.pdf>  
-   <https://www.andrew.cmu.edu/user/achoulde/94842/lectures/lecture09/lecture09-94842.html>  
-   <https://www.andrew.cmu.edu/user/achoulde/94842/lectures/lecture11/lecture11-94842-2020.html>
