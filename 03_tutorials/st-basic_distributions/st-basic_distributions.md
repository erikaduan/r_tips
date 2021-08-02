Fundamental statistical distributions
================
Erika Duan
2021-08-02

-   [Normal distribution](#normal-distribution)
    -   [Standard normal distribution](#standard-normal-distribution)
    -   [Multi-variate normal
        distribution](#multi-variate-normal-distribution)
-   [Chi-squared distribution](#chi-squared-distribution)
-   [T distribution](#t-distribution)
-   [F distribution](#f-distribution)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse,
               patchwork)   
```

# Normal distribution

The normal distribution, or Gaussian distribution, is frequently
observed in nature and is characterised by the following properties.

-   It is a symmetrical continuous distribution where
    ![-\\infty &lt; x &lt; \\infty](https://latex.codecogs.com/png.latex?-%5Cinfty%20%3C%20x%20%3C%20%5Cinfty "-\infty < x < \infty").  
-   Its mean, median and mode are identical due to its symmetrical
    distribution.  
-   Its probability density function contains two parameters; the mean
    i.e. ![\\mu](https://latex.codecogs.com/png.latex?%5Cmu "\mu") and
    the standard deviation
    i.e. ![\\sigma](https://latex.codecogs.com/png.latex?%5Csigma "\sigma")
    where
    ![-\\infty &lt; \\mu &lt; \\infty](https://latex.codecogs.com/png.latex?-%5Cinfty%20%3C%20%5Cmu%20%3C%20%5Cinfty "-\infty < \mu < \infty")
    and
    ![\\sigma &gt; 0](https://latex.codecogs.com/png.latex?%5Csigma%20%3E%200 "\sigma > 0").  
-   Its probability density function is described by the equation
    below:  
    ![f(x) = \\frac{1}{\\sqrt{2 \\pi \\sigma^2}} \\times e^{\\frac{-(x - \\mu) ^2}{2\\sigma2}}](https://latex.codecogs.com/png.latex?f%28x%29%20%3D%20%5Cfrac%7B1%7D%7B%5Csqrt%7B2%20%5Cpi%20%5Csigma%5E2%7D%7D%20%5Ctimes%20e%5E%7B%5Cfrac%7B-%28x%20-%20%5Cmu%29%20%5E2%7D%7B2%5Csigma2%7D%7D "f(x) = \frac{1}{\sqrt{2 \pi \sigma^2}} \times e^{\frac{-(x - \mu) ^2}{2\sigma2}}").

``` r
# Calculate expectation of normal distribution ---------------------------------
# Store x * f(x) where f(x) is a normal distribution with mean 140 and sd 16      
funs_x_fx <- function(x) x * (1/ (sqrt(2 * pi * 16 ^ 2)) * exp(-((x - 140) ^ 2) / (2 * 16 ^ 2)))

expectation_n1 <- integrate(funs_x_fx, lower = 92, upper = 188)
expectation_n1  
#> 139.622 with absolute error < 0.00013  
```

## Standard normal distribution

## Multi-variate normal distribution

# Chi-squared distribution

# T distribution

# F distribution

# Other resources

-   University of Sydney Mathematics Learning Centre
    [chapter](https://www.sydney.edu.au/content/dam/students/documents/mathematics-learning-centre/normal-distribution.pdf)
    on the normal distribution.  
-   A jbstatistics [YouTube
    video](https://www.youtube.com/watch?v=iYiOVISWXS4) on the normal
    distribution.
