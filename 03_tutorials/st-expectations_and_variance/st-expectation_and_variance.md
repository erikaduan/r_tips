Introduction to expectation and variance
================
Erika Duan
2021-07-29

-   [Introduction to expectation](#introduction-to-expectation)
    -   [Discrete probability
        distributions](#discrete-probability-distributions)
    -   [Continuous probability
        distributions](#continuous-probability-distributions)
-   [Introduction to variance](#introduction-to-variance)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse)   
```

# Introduction to expectation

The expectation of variable X, or E(X) is the long term average of the
random variable.  
When we have a list of numbers, for example a sample of plant heights,
it is easy to calculate the **expectation** or the average using the
following equation below:  
![\\mu = \\frac{x\_1 + x\_2 + \\: ... \\: + x\_n}{n} \\; or \\; \\frac{1}{n} \\displaystyle \\sum\_{i=1}^{n}x\_i](https://latex.codecogs.com/png.latex?%5Cmu%20%3D%20%5Cfrac%7Bx_1%20%2B%20x_2%20%2B%20%5C%3A%20...%20%5C%3A%20%2B%20x_n%7D%7Bn%7D%20%5C%3B%20or%20%5C%3B%20%5Cfrac%7B1%7D%7Bn%7D%20%5Cdisplaystyle%20%5Csum_%7Bi%3D1%7D%5E%7Bn%7Dx_i "\mu = \frac{x_1 + x_2 + \: ... \: + x_n}{n} \; or \; \frac{1}{n} \displaystyle \sum_{i=1}^{n}x_i")

However, in statistics, we are interested in modelling the probability
distribution of a function (which is usually not a simple list of
numbers).

<img src="../../02_figures/st-expectation_and_variance-probability_distributions.jpg" width="90%" style="display: block; margin: auto;" />

## Discrete probability distributions

The expectation of a discrete probability distribution is described
below:  
![\\displaystyle \\sum\_{i=1}^n x\_i \\times p(x\_i)](https://latex.codecogs.com/png.latex?%5Cdisplaystyle%20%5Csum_%7Bi%3D1%7D%5En%20x_i%20%5Ctimes%20p%28x_i%29 "\displaystyle \sum_{i=1}^n x_i \times p(x_i)").

Imagine if a person in the community has a probability of testing
positive for COVID-19 of 0.15.

-   What is the probability that 0 people test positive for COVID-19 out
    of a random sample of 10 people?  
-   What is the probability that 1 person tests positive for COVID-19
    out of a random sample of 10 people?  
-   What is the probability at least 2 people will test positive for
    COVID-19 out of a random sample of 10 people?

``` r
# Calculate P(X = 0) when n = 10 -----------------------------------------------
dbinom(x = 0, size = 10, prob = 0.15)
#> [1] 0.1968744
 
# Calculate P(X = 1) when n = 10 -----------------------------------------------
dbinom(x = 1, size = 10, prob = 0.15)
#> [1] 0.3474254

# Calculate P(X <= 2) when n = 10 ----------------------------------------------
dbinom(x = 0:2, size = 10, prob = 0.15) %>%
  reduce(sum)
#> [1] 0.8201965  

pbinom(q = 2, size = 10, prob = 0.15, lower.tail = T)
#> [1] 0.8201965    
```

-   What is the probability distribution for the number of people
    testing positive for COVID-19 out of a random sample of 10 people?  
-   What is the average number of people that will test positive for
    COVID-19 out of a random sample of 10 people?

``` r
# Calculate binomial probability distribution ---------------------------------- 
x <- c(0:10)
p_x <- dbinom(x = 0:10, size = 10, prob = 0.15)

# Calculate expectation of binomial probability distribution -------------------
expectation <- sum(x * p_x)
expectation
#> [1] 1.5  
```

``` r
# Plot binomial probability distribution ---------------------------------------
binom_dist <- tibble(prob = dbinom(x = 0:10, size = 10, prob = 0.1),
                     x = c(0:10))    

binom_dist %>%
  ggplot(aes(x = x, y = prob)) + 
  geom_segment(aes(x = x, xend = x, y = 0, yend = prob)) +
  geom_point(size = 3, shape = 21, fill = "linen") +
  geom_vline(xintercept = expectation, colour = "firebrick", linetype = "dotted") + 
  scale_x_continuous(breaks = seq(0, 10, 1)) +
  labs(x = "X",
       y = "Probability",
       title = "Probability mass function") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5)) +
  annotate("text", x = 1.85, y = 0.6, label = "E(X)")
```

![](st-expectation_and_variance_files/figure-gfm/plot%20binom%20dist-1.png)<!-- -->

## Continuous probability distributions

The expectation of a continuous probability distribution is described
below:  
![\\int\_{-\\infty}^{\\infty} x \\times f(x) \\:dx](https://latex.codecogs.com/png.latex?%5Cint_%7B-%5Cinfty%7D%5E%7B%5Cinfty%7D%20x%20%5Ctimes%20f%28x%29%20%5C%3Adx "\int_{-\infty}^{\infty} x \times f(x) \:dx")

The function
![f(x)](https://latex.codecogs.com/png.latex?f%28x%29 "f(x)") represents
the height of the curve at point
![x](https://latex.codecogs.com/png.latex?x "x") and the area under the
curve of ![f(x)](https://latex.codecogs.com/png.latex?f%28x%29 "f(x)")
represents the probability of
![x](https://latex.codecogs.com/png.latex?x "x") falling within a value
range.

The expectation of
![f(x)](https://latex.codecogs.com/png.latex?f%28x%29 "f(x)"), or a
probability density function, is therefore the area under the curve of
![x \\times f(x)](https://latex.codecogs.com/png.latex?x%20%5Ctimes%20f%28x%29 "x \times f(x)")
or
![\\int\_{-\\infty}^{\\infty} x \\times f(x) \\:dx](https://latex.codecogs.com/png.latex?%5Cint_%7B-%5Cinfty%7D%5E%7B%5Cinfty%7D%20x%20%5Ctimes%20f%28x%29%20%5C%3Adx "\int_{-\infty}^{\infty} x \times f(x) \:dx").

Imagine that the height of tomato plants in a field is normally
distributed. It is known that the average tomato plant height is 140 cm,
with a standard deviation of 16 cm.

-   What is the probability distribution for tomato height if the height
    of 100 plants was randomly measured?

``` r
# Sample values from a normal distribution -------------------------------------  
set.seed(111)
norm_dist <- tibble(x = seq(92, 188, length = 100),
                    p_density = dnorm(x, mean = 140, sd = 16))  

# Calculate expectation of normal distribution ---------------------------------
# Store x * f(x) where f(x) is a normal distribution with mean 140 and sd 16      
funs_normal <- function(x) x * (1/ (sqrt(2 * pi * 16 ^ 2)) * exp(-((x - 140) ^ 2) / (2 * 16 ^ 2)))

expectation <- integrate(funs_normal, lower = 92, upper = 188)
expectation  
#> 139.622 with absolute error < 0.00013  
```

``` r
# Plot probability density function of normal distribution ---------------------  
norm_dist %>%
  ggplot(aes(x = x, y = p_density)) + 
  geom_line() + 
  geom_vline(xintercept = expectation[[1]], colour = "firebrick", linetype = "dotted") + 
  scale_x_continuous(breaks = seq(90, 190, 10)) +
  labs(x = "X",
       y = "Probability density",
       title = "Probability density function") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5)) +
  annotate("text", x = 145, y = 0.026, label = "E(X)")
```

![](st-expectation_and_variance_files/figure-gfm/plot%20normal%20dist-1.png)<!-- -->

# Introduction to variance

The variance of variable X is a description of how far away individual
values of x are from the mean. It can be defined in two ways below:  
![A](https://latex.codecogs.com/png.latex?A "A")  
![B](https://latex.codecogs.com/png.latex?B "B")

# Other resources

-   Statistics textbook
    [chapter](https://www.stat.auckland.ac.nz/~fewster/325/notes/ch3.pdf)
    on expectation and variance from the University of Auckland.  
-   StatQuest YouTube videos on how to find the expectation for a
    [discrete](https://www.youtube.com/watch?v=KLs_7b7SKi4) versus
    [continuous](https://www.youtube.com/watch?v=OSPr6G6Ka-U)
    distribution.  
-   StatQuest YouTube videos on how to find the
    [covariance](https://www.youtube.com/watch?v=qtaqvPAeEJY) versus
    [Pearson’s correlation](https://www.youtube.com/watch?v=xZ_z8KWkhXE)
    for two variables.  
-   A jbstatistics [YouTube
    video](https://www.youtube.com/watch?v=oHcrna8Fk18) on discrete
    probability distributions.
