Build a linear regression model
================
Erika Duan
2024-06-30

-   [Why linear regression?](#why-linear-regression)
-   [Build a linear regression model](#build-a-linear-regression-model)
-   [The mathemathical intuition](#the-mathemathical-intuition)
-   [Evaluate a linear regression
    model](#evaluate-a-linear-regression-model)
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
learn about. Although it has a reputation for being a basic modelling
approach, linear regression is still used for different purposes.

As listed in [Regression and Other
Stories](https://avehtari.github.io/ROS-Examples/) by Gelman et al,
linear regression can be used to:

-   Predict or forecast outcomes without aiming to infer causality.  
-   Generate a linear explanation of the associations between variables
    of interest (also known as features) and an outcome.  
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

Let’s first build a linear regression model and see what results it
produces. We will then learn about the mathematical properties,
interpretation and assumptions of our model.

We will provide ourselves with a safety check, by secretly knowing the
precise relationship between our independent variables and the outcome
of interest. This will never happen in real life.

Imagine that the amount of money a pet influencer earns per month is
influenced by the following variables:

-   Whether the pet is a cat or a dog or another animal species  
-   The number of photos their owner posts every month  
-   The number of videos their owner posts every month

To simplify things, We state that there are no confounds between these
variables i.e. each variable is independent of one another.

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

# Simulate whether pet is dog, cat or other using a multinomial distribution  
species <- rmultinom(N, 
                     size = 1,
                     prob = c(0.6, 0.3, 0.1))

# Convert species into dummy variables     
is_dog <- species[1, 1:N]
is_cat <- species[2, 1:N]

# Simulate number of photos per month using a poisson distribution 
photos <- rpois(N, lambda = 6)

# Simulate number of videos per month using a poisson distribution
videos <- rpois(N, lambda = 2)

# Simulate monthly income using a normal distribution 
income <- rnorm(N,
                mean = (is_dog * 60 + is_cat * 10 + photos * 6 + videos * 18) + 50,
                sd = 5)

# Ensure that income is a non-negative integer
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
standard formula `lm(Y ~ X1 + X2 + ... + Xn)` and view the results using
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
    ## -12.9609  -3.0948   0.1918   3.3231  12.1918 
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)   51.5191     1.1122  46.323   <2e-16 ***
    ## train$is_dog  58.9384     0.9578  61.532   <2e-16 ***
    ## train$is_cat   8.9727     1.0042   8.935   <2e-16 ***
    ## train$photos   5.9010     0.1050  56.180   <2e-16 ***
    ## train$videos  17.9448     0.1734 103.467   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 4.849 on 370 degrees of freedom
    ## Multiple R-squared:  0.9859, Adjusted R-squared:  0.9858 
    ## F-statistic:  6487 on 4 and 370 DF,  p-value: < 2.2e-16

This looks very complicated! Let us interpret the key results from
`summary(mlr_model)` by learning about the mathematical structure of a
linear regression model.

# The mathemathical intuition

The simplest linear regression model is a line of best fit through the
2-dimensional Cartesian plane. To construct this model, we need to
estimate the two properties (or parameters) of an unknown straight line:

-   The y-intercept, which we refer to as
    ![\\beta_0](https://latex.codecogs.com/png.latex?%5Cbeta_0 "\beta_0").  
-   The slope, which we refer to as
    ![\\beta_1](https://latex.codecogs.com/png.latex?%5Cbeta_1 "\beta_1")

We assume that there is a **true model** that precisely predicts our
outcome of interest
![Y_i](https://latex.codecogs.com/png.latex?Y_i "Y_i") based on our
independent variable of interest
![X_i](https://latex.codecogs.com/png.latex?X_i "X_i"). The true model
has the form
![Y_i = \\beta_0 + \\beta_1X_1 + \\epsilon_i](https://latex.codecogs.com/png.latex?Y_i%20%3D%20%5Cbeta_0%20%2B%20%5Cbeta_1X_1%20%2B%20%5Cepsilon_i "Y_i = \beta_0 + \beta_1X_1 + \epsilon_i"),
where
![\\epsilon_i](https://latex.codecogs.com/png.latex?%5Cepsilon_i "\epsilon_i")
represents the error due to natural variation, because objects do not
behave like perfect clones of each other in the real world.

Because there is always error due to natural variation, we view each
observation of ![Y_i](https://latex.codecogs.com/png.latex?Y_i "Y_i") as
being drawn from a normal distribution of possible values. By making
some assumptions about
![\\epsilon_i](https://latex.codecogs.com/png.latex?%5Cepsilon_i "\epsilon_i"),
we can claim that the mean of the probability distribution of
![Y_i](https://latex.codecogs.com/png.latex?Y_i "Y_i") is
![E(Y_i) = \\beta_0 + \\beta_1X_1](https://latex.codecogs.com/png.latex?E%28Y_i%29%20%3D%20%5Cbeta_0%20%2B%20%5Cbeta_1X_1 "E(Y_i) = \beta_0 + \beta_1X_1").
This is the unknown straight line that we want to estimate.

<img src="../../figures/st-linear_regression-simple_model_structure.gif" width="80%" style="display: block; margin: auto;" />

We want to use our training data set to find the best estimates of
![\\beta_0](https://latex.codecogs.com/png.latex?%5Cbeta_0 "\beta_0")
and
![\\beta_1](https://latex.codecogs.com/png.latex?%5Cbeta_1 "\beta_1").
This means finding the line that travels closest through all the
training data set observations. This line is our **best estimated
model**, which has the form
![\\hat Y_i = b_0 + b_1X_i](https://latex.codecogs.com/png.latex?%5Chat%20Y_i%20%3D%20b_0%20%2B%20b_1X_i "\hat Y_i = b_0 + b_1X_i").
It has a y-intercept of
![b_0](https://latex.codecogs.com/png.latex?b_0 "b_0") and slope of
![b_1](https://latex.codecogs.com/png.latex?b_1 "b_1").

The simple linear regression model coefficients
![b_0](https://latex.codecogs.com/png.latex?b_0 "b_0") and
![b_1](https://latex.codecogs.com/png.latex?b_1 "b_1") are therefore our
best estimates of
![\\beta_0](https://latex.codecogs.com/png.latex?%5Cbeta_0 "\beta_0")
and
![\\beta_1](https://latex.codecogs.com/png.latex?%5Cbeta_1 "\beta_1").

In this tutorial, we hypothesised that our multiple regression model had
the form `lm(income ~ is_dog + is_cat + photos + videos)`. We think that
the mean monthly pet influencer income is the sum of:

-   A baseline income value
    (![\\beta_0](https://latex.codecogs.com/png.latex?%5Cbeta_0 "\beta_0"))  
-   An additional amount of money if the pet is a dog
    (![\\beta_1](https://latex.codecogs.com/png.latex?%5Cbeta_1 "\beta_1"))  
-   An additional amount of money if the pet is a cat
    (![\\beta_2](https://latex.codecogs.com/png.latex?%5Cbeta_2 "\beta_2"))  
-   An additional amount of money for each photo posted per month
    (![\\beta_3](https://latex.codecogs.com/png.latex?%5Cbeta_3 "\beta_3"))  
-   An additional amount of money for each video posted per month
    (![\\beta_4](https://latex.codecogs.com/png.latex?%5Cbeta_4 "\beta_4"))

In mathematical terms, we think our true unknown model has the structure
below.

<img src="../../figures/st-linear_regression-tutorial_model_structure.svg" width="80%" style="display: block; margin: auto;" />

Knowing this, let us examine the coefficients of our multiple linear
regression model. We can extract them from our model by using the
`tidy()` function from the
[`broom`](https://cran.r-project.org/web/packages/broom/vignettes/broom.html)
package.

``` r
# Extract model coefficients in 
mlr_model |> tidy()
```

    ## # A tibble: 5 x 5
    ##   term         estimate std.error statistic   p.value
    ##   <chr>           <dbl>     <dbl>     <dbl>     <dbl>
    ## 1 (Intercept)     51.5      1.11      46.3  4.41e-156
    ## 2 train$is_dog    58.9      0.958     61.5  1.98e-196
    ## 3 train$is_cat     8.97     1.00       8.94 1.95e- 17
    ## 4 train$photos     5.90     0.105     56.2  3.22e-183
    ## 5 train$videos    17.9      0.173    103.   3.43e-275

The model coefficients tell us that the following associations exist:

-   XX
-   XX
-   XX

# Evaluate a linear regression model

# Linear regression with `tidymodels`

# Linear regression with `mlr3`

# Other resources

-   <https://andrewproctor.github.io/rcourse/module5.html#regression_basics>  
-   <https://andrewproctor.github.io/rcourse/assets/module5.pdf>  
-   <https://www.andrew.cmu.edu/user/achoulde/94842/lectures/lecture09/lecture09-94842.html>  
-   <https://www.andrew.cmu.edu/user/achoulde/94842/lectures/lecture11/lecture11-94842-2020.html>
