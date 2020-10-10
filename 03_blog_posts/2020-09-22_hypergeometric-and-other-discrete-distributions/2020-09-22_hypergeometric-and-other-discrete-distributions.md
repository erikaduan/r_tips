Introduction to hypergeometric, geometric, negative binomial and
multinomial distributions
================
Erika Duan
2020-10-11

  - [Introduction](#introduction)
  - [Hypergeometric distribution](#hypergeometric-distribution)
  - [Approximating the hypergeometric distribution with the binomial
    distribution](#approximating-the-hypergeometric-distribution-with-the-binomial-distribution)
  - [Geometric distribution](#geometric-distribution)
  - [Negative binomial distribution](#negative-binomial-distribution)
  - [Multinomial distribution](#multinomial-distribution)
  - [Resources](#resources)

``` r
#-----load required packages-----  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse,
               patchwork) 
```

# Introduction

This tutorial extends our exploration of discrete probability
distributions, which began with [an introduction to bernoulli trials and
the binomial
distribution](https://github.com/erikaduan/R-tips/blob/master/03_blog_posts/2020-09-12_binomial_distribution/2020-09-12_binomial-distribution.md#drawing-control-limits-for-binomial-proportions-funnel-plots).

As revision, we may recall that the binomial distribution has the
following properties:

  - It allows us to calculate the probability of
    ![k](https://latex.codecogs.com/png.latex?k "k") number of successes
    occurring out of ![n](https://latex.codecogs.com/png.latex?n "n")
    bernoulli trials, where the outcome of each trial is independent of
    each other and has the same probability of occuring.  
  - Its probability mass function is calculated from a) the total number
    of all possible combinations of
    ![k](https://latex.codecogs.com/png.latex?k "k") trial successes and
    b) the probability of one single arrangement of
    ![k](https://latex.codecogs.com/png.latex?k "k") successes and
    ![n-k](https://latex.codecogs.com/png.latex?n-k "n-k") failures.  
      
    ![P(X=x) = \\frac{n\!}{x\!(n-x)\!} \\times
    p^{x}(1-p)^{n-x}](https://latex.codecogs.com/png.latex?P%28X%3Dx%29%20%3D%20%5Cfrac%7Bn%21%7D%7Bx%21%28n-x%29%21%7D%20%5Ctimes%20p%5E%7Bx%7D%281-p%29%5E%7Bn-x%7D
    "P(X=x) = \\frac{n!}{x!(n-x)!} \\times p^{x}(1-p)^{n-x}")  
      
  - Its mean is ![E(X) = n\\times
    p](https://latex.codecogs.com/png.latex?E%28X%29%20%3D%20n%5Ctimes%20p
    "E(X) = n\\times p") and its variance is ![Var(X) = n \\times
    p(1-p)](https://latex.codecogs.com/png.latex?Var%28X%29%20%3D%20n%20%5Ctimes%20p%281-p%29
    "Var(X) = n \\times p(1-p)").

<!-- end list -->

``` r
#-----calculate probability mass function of binomial distribution-----  
# what is the probability mass function of a fair dice landing on 1(s) if I throw the dice 15 times   

# k = 0, 1, 2, ... 15
# n = 15
# p = 1/6  

k <- seq(0, 15, 1) 

binom_dist <- set_names(k) %>%
  map_df(~ dbinom(.x, 15, 1/6)) %>%
  pivot_longer(cols = everything(),
               names_to = "k",
               values_to = "prob") 

mean_binom <- 15 * (1/6)

#-----visualise probability mass function of binomial distribution-----  
binom_dist %>%
  mutate(k = as.numeric(k)) %>% 
  ggplot(aes(x = k, y = prob)) +
  geom_segment(aes(x = k, xend = k, y = 0, yend = prob)) +
  geom_point(size = 3, shape = 21, fill = "steelblue") +
  geom_vline(xintercept = mean_binom, linetype = "dashed", colour = "steelblue") + 
  scale_x_continuous(breaks = c(seq(0, 15, 1))) + 
  labs(x = "X",
       y = "Probability",
       title = "Binomial distribution of 15 fair dice throws landing on 1(s)") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))   
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-2-1.png" width="60%" />

# Hypergeometric distribution

The hypergeometric distribution is used in scenarios where sampling
without replacement occurs (i.e. the outcome obtained is dependent on
the prior samples that were selected). We cannot use the binomial
distribution here as the outcome of each trial is not independent of
each other.

Instead, we use the combinations formula to aid us in calculating the
hypergeometric distribution.

To extend the combinations formula, we consider the following five
parameters:

  - ![P(X = x)](https://latex.codecogs.com/png.latex?P%28X%20%3D%20x%29
    "P(X = x)") is the probability of obtaining
    ![x](https://latex.codecogs.com/png.latex?x "x") successes from a
    sample of ![n](https://latex.codecogs.com/png.latex?n "n").  
  - ![N](https://latex.codecogs.com/png.latex?N "N") is the size of the
    population.  
  - ![n](https://latex.codecogs.com/png.latex?n "n") is the size of the
    sample.  
  - ![k](https://latex.codecogs.com/png.latex?k "k") is the number of
    successes in the population
    ![N](https://latex.codecogs.com/png.latex?N "N").  
  - ![x](https://latex.codecogs.com/png.latex?x "x") is the number of
    successes in the sample ![n](https://latex.codecogs.com/png.latex?n
    "n").

**Note:** Once a sample (i.e. event success) is taken out of the
population without replacement, the probability of observing an event
success changes. This is most impacted when
![N](https://latex.codecogs.com/png.latex?N "N") is a small number.

<img src="../../02_figures/2020-09-22_hypergeometric-distribution.jpg" width="80%" style="display: block; margin: auto;" />

The mean of the hypergeometric distribution can be derived as ![E(X) =
n\\times
\\frac{k}{N}](https://latex.codecogs.com/png.latex?E%28X%29%20%3D%20n%5Ctimes%20%5Cfrac%7Bk%7D%7BN%7D
"E(X) = n\\times \\frac{k}{N}").  
The variance of the hypergeometric distribution is defined as ![Var(X) =
n\\times \\frac{k}{N}\\times \\frac{N-n}{N}\\times
\\frac{N-k}{N-1}](https://latex.codecogs.com/png.latex?Var%28X%29%20%3D%20n%5Ctimes%20%5Cfrac%7Bk%7D%7BN%7D%5Ctimes%20%5Cfrac%7BN-n%7D%7BN%7D%5Ctimes%20%5Cfrac%7BN-k%7D%7BN-1%7D
"Var(X) = n\\times \\frac{k}{N}\\times \\frac{N-n}{N}\\times \\frac{N-k}{N-1}").

``` r
#-----calculate probability of hypergeometric distribution-----    
# out of a school of 300 students, 165 students are female and 135 are male
# probability of a group of 30 students having 15 female and 15 male students

dhyper(15, # number of female students in randomly selected group
       165, # number of female students in school
       135, # number of male students in school 
       30)  
#> [1] 0.128921    
```

``` r
#-----calculate probability mass function of hypergeometric distribution-----  
max(0, 30 - (300 - 165)) # calculate minimum value for x  
#> [1] 0

min(165, 30) # calculate maximum value for x  
#> [1] 30   

hypergeom_dist <- set_names(seq(0, 30, 1)) %>%
  map_df(~ dhyper(.x, 165, 135, 30)) %>%
  pivot_longer(cols = everything(),
               names_to = "X",
               values_to = "prob") 

mean_hypergeom <- 30 * (165/300)  

#-----visualise hypergeometric distribution-----
hypergeom_dist %>%
  mutate(X = as.numeric(X)) %>% 
  ggplot(aes(x = X, y = prob)) +  
  geom_segment(aes(x = X, xend = X, y = 0, yend = prob)) +
  geom_point(size = 3, shape = 21, fill = "cadetblue") +
  geom_vline(xintercept = mean_hypergeom, linetype = "dashed", colour = "cadetblue") + 
  scale_x_continuous(breaks = c(seq(0, 30, 1))) + 
  labs(y = "Probability",
       title = "Hypergeometric distribution of female student numbers in a group of 30") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))     
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-5-1.png" width="80%" />

**Note**: The advantage of the hypergeometric distribution is that it
can be used to calculate the probability mass function for events with
more than two outcomes.

``` r
#-----calculate probability of multivariate hypergeometric distribution-----   
# suppose a data science consultancy employs 55 males, 17 females and 2 non-binary persons 
# what is the probability that a team of 6 employees contains 3 males, 2 females and 1 non-binary person  

N <- 55 + 17 + 2
n <- 6

choose_teams <- choose(N, n)
choose_males <- choose(55, 3)
choose_females <- choose(17, 2) 
choose_binary <- choose(2, 1)

(choose_males * choose_females * choose_binary)/choose_teams
#> [1] 0.03852032
```

# Approximating the hypergeometric distribution with the binomial distribution

The binomial distribution can sometimes be used to approximate the
hypergeometric distribution. This occurs when we are sampling no more
than 5% of a large population (so the probability of a successful event
occuring does not significantly change as we sample without
replacement).

We can explore this further using a simulation using the scenario above,
but where:

1.  The sample size is 5% of the population (n = 30 and N = 600).
2.  The sample size is 10% of the population (n = 30 and N = 300).  
3.  The sample size is 25% of the population (n = 30 and N = 120).

<!-- end list -->

``` r
#-----calculate hypergeometric vs binomial distribution-----
hypergeom_600 <- dhyper(0:30, 330, 270, 30)
hypergeom_300 <- dhyper(0:30, 165, 135, 30)
hypergeom_120 <- dhyper(0:30, 66, 54, 30)  
binom_30 <- dbinom(0:30, 30, 0.55) # p = 165/300   

hypergeom_all <- tibble(X = 0:30,
                        N_600 = hypergeom_600,
                        N_300 = hypergeom_300,
                        N_120 = hypergeom_120,
                        binom = binom_30) %>%
  pivot_longer(cols = -contains("X"), 
               names_to = "N_size", values_to = "prob") %>%
  mutate(type = case_when(str_detect(N_size, "N_") ~ "hypergeometric",
                          str_detect(N_size, "binom")  ~ "binomial"),
         N_size = case_when(N_size == "N_600" ~ "600 (5%)",
                            N_size == "N_300" ~ "300 (10%)",
                            N_size == "N_120" ~ "120 (25%)"))

#-----visualise hypergeometric distribution overlaid on binomial approximation-----     
ggplot(hypergeom_all) +  
  geom_col(aes(x = X, y = prob),
           hypergeom_all %>% filter(type == "binomial"),
           fill = "gainsboro",
           colour = "black",  
           width = 0.5) +
  geom_line(aes(x = X, y = prob, colour = N_size),
            hypergeom_all %>% filter(type == "hypergeometric"),
            size = 0.5) + 
  scale_color_brewer(palette = "Dark2") + 
  scale_x_continuous(breaks = c(seq(0, 30, 1))) + 
  labs(y = "Probability",
       colour = "N",
       title = "Binomial approximation of hypergeometric distribution when n ~ 5% of N") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5)) 
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-7-1.png" width="80%" />

# Geometric distribution

The [geometric
distribution](https://en.wikipedia.org/wiki/Geometric_distribution)
describes the probability mass function of the number of bernoulli
trials required before we encounter the first successful trial outcome.
It is useful for modelling events of high importance (i.e. the
probability of a random citizen being able to provide CPR).

The probability mass function of a geometric distribution can be
described as the probability of encountering
![x-1](https://latex.codecogs.com/png.latex?x-1 "x-1") trial failures
before encountering the first trial success (i.e. we define
![X](https://latex.codecogs.com/png.latex?X "X") as the number of trials
required to obtain the first successful event).  
  
![P(X=x) = (1-p)^{x-1}\\times p \\; for \\; x = 1, 2, ...,
x](https://latex.codecogs.com/png.latex?P%28X%3Dx%29%20%3D%20%281-p%29%5E%7Bx-1%7D%5Ctimes%20p%20%5C%3B%20for%20%5C%3B%20x%20%3D%201%2C%202%2C%20...%2C%20x
"P(X=x) = (1-p)^{x-1}\\times p \\; for \\; x = 1, 2, ..., x")  

The mean of the geometric distribution can be derived as ![E(X) =
\\sum\_{i=0}^{1} x \\times p(x) =
\\frac{1}{p}](https://latex.codecogs.com/png.latex?E%28X%29%20%3D%20%5Csum_%7Bi%3D0%7D%5E%7B1%7D%20x%20%5Ctimes%20p%28x%29%20%3D%20%5Cfrac%7B1%7D%7Bp%7D
"E(X) = \\sum_{i=0}^{1} x \\times p(x) = \\frac{1}{p}").

The variance of the geometric distribution is defined as ![Var(X) =
\\frac{1-p}{p^2}](https://latex.codecogs.com/png.latex?Var%28X%29%20%3D%20%5Cfrac%7B1-p%7D%7Bp%5E2%7D
"Var(X) = \\frac{1-p}{p^2}").

**Note:** The function `dgeom(x, prob)` defines
![x](https://latex.codecogs.com/png.latex?x "x") as the number of trial
failures that occur before the first success is observed.

``` r
#-----calculate probability of geometric distribution-----    
# example 1  
# what is the probability that the 6th person in a population knows CPR i.e. P(x = 6)       

p <- 0.3 # success = person who knows CPR (0.3)
x <- 6 # number of trials taken to encounter person who knows CPR  

dgeom(x - 1, p) 
#> [1] 0.050421  

# example 2  
# what is the probability the 1st to 4th person is the 1st person who knows CPR i.e. P(x <= 4)  

dgeom(c(seq(0, 3, 1)), p) %>%
  sum(.)
#> [1] 0.7599   

1 - ((1 - p)^4)  
#> [1] 0.7599   
```

**Note:** The probability of a success first occuring before or during
the ![x^{th}](https://latex.codecogs.com/png.latex?x%5E%7Bth%7D
"x^{th}") trial is the complement of the probability of a success first
occuring after more than ![x](https://latex.codecogs.com/png.latex?x
"x") trials. The latter event is also defined as the probability of
![x^{th}](https://latex.codecogs.com/png.latex?x%5E%7Bth%7D "x^{th}")
failures occuring. The cummulative probability distribution for the
geometric distribution is thus defined below.  
  
![P(X\\leq x) = 1 - P(X \> x) = 1 -
(1-p)^{x}](https://latex.codecogs.com/png.latex?P%28X%5Cleq%20x%29%20%3D%201%20-%20P%28X%20%3E%20x%29%20%3D%201%20-%20%281-p%29%5E%7Bx%7D
"P(X\\leq x) = 1 - P(X \> x) = 1 - (1-p)^{x}")  

``` r
#-----calculate probability mass function of geometric distribution-----
# what is the probability mass function of obtaining the first 1 (success) from a fair dice  
# assuming a maximum of 15 throws 
# calculate P(x = X) where X represents the number of trials needed to observe the first success  

p <- 1/6
x <- seq(0, 14, 1) 

geom_dist <- set_names(x, seq(1, 15, 1)) %>%
  map_df(~ dgeom(.x, 1/6)) %>%
  pivot_longer(cols = everything(),
               names_to = "X",
               values_to = "prob") 

mean_geom <- 1 / (1/6)  

#-----visualise probability mass function of geometric distribution-----  
geom_dist %>%
  mutate(X = as.numeric(X)) %>% 
  ggplot(aes(x = X, y = prob)) +  
  geom_segment(aes(x = X, xend = X, y = 0, yend = prob)) +
  geom_point(size = 3, shape = 21, fill = "cornflowerblue") +
  geom_vline(xintercept = mean_geom, linetype = "dashed", colour = "cornflowerblue") + 
  scale_x_continuous(breaks = c(seq(0, 15, 1))) + 
  labs(y = "Probability",
       title = "Geometric distribution of number of fair dice throws required to land on 1") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))   
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-9-1.png" width="60%" />

**Note:** The minimum value of the geometric distribution is 1 (i.e. the
first trial obtains a successful outcome) and there is no upper bound.
The mode of the geometric distribution is always 1, with probabilities
decreasing with larger values of
![x](https://latex.codecogs.com/png.latex?x "x") (i.e. right skewness).

# Negative binomial distribution

Extending the concept of the geometric distribution, the negative
binomial distribution describes the probability mass function of the
number of benoulli trials required to obtain the
![r^{th}](https://latex.codecogs.com/png.latex?r%5E%7Bth%7D "r^{th}")
success (i.e. for a single distribution, the variable
![r](https://latex.codecogs.com/png.latex?r "r") is fixed amd P(X)
represents the number of bernoulli trials required to obtain the
![r^{th}](https://latex.codecogs.com/png.latex?r%5E%7Bth%7D "r^{th}")
success.

This means that the negative binomial distribution must obtain the
following conditions:

  - The ![x-1](https://latex.codecogs.com/png.latex?x-1 "x-1") trial
    must contain ![r-1](https://latex.codecogs.com/png.latex?r-1 "r-1")
    successes i.e. ![\\frac{(x-1)\!}{(r-1)\!((x-1)-(r-1))\!} \\times
    p^{(r-1)}(1-p)^{(x-1)-(r-1)}](https://latex.codecogs.com/png.latex?%5Cfrac%7B%28x-1%29%21%7D%7B%28r-1%29%21%28%28x-1%29-%28r-1%29%29%21%7D%20%5Ctimes%20p%5E%7B%28r-1%29%7D%281-p%29%5E%7B%28x-1%29-%28r-1%29%7D
    "\\frac{(x-1)!}{(r-1)!((x-1)-(r-1))!} \\times p^{(r-1)}(1-p)^{(x-1)-(r-1)}")  
  - The ![x^{th}](https://latex.codecogs.com/png.latex?x%5E%7Bth%7D
    "x^{th}") trial must also be a success and has a probability of
    ![p](https://latex.codecogs.com/png.latex?p "p").  
  - To calculate the probability mass function of the
    ![x^{the}](https://latex.codecogs.com/png.latex?x%5E%7Bthe%7D
    "x^{the}") trial, we simply multiple the two equations above (as
    events occur independently of each other).

The probability mass function can be written below, as the probability
that the ![x^{th}](https://latex.codecogs.com/png.latex?x%5E%7Bth%7D
"x^{th}") bernoulli trial contains the
![r{^th}](https://latex.codecogs.com/png.latex?r%7B%5Eth%7D "r{^th}")
success.  
  
![P(X=x) = \\frac{(x-1)\!}{(r-1)\!((x-1)-(r-1))\!} \\times
p^{(r-1)}(1-p)^{(x-1)-(r-1)} \\times
p](https://latex.codecogs.com/png.latex?P%28X%3Dx%29%20%3D%20%5Cfrac%7B%28x-1%29%21%7D%7B%28r-1%29%21%28%28x-1%29-%28r-1%29%29%21%7D%20%5Ctimes%20p%5E%7B%28r-1%29%7D%281-p%29%5E%7B%28x-1%29-%28r-1%29%7D%20%5Ctimes%20p
"P(X=x) = \\frac{(x-1)!}{(r-1)!((x-1)-(r-1))!} \\times p^{(r-1)}(1-p)^{(x-1)-(r-1)} \\times p")  
  
![P(X=x) = \\frac{(x-1)\!}{(r-1)\!(x-r)\!} \\times
p^{r}(1-p)^{(x-r)}\\;for\\;x=r,
r+1,...](https://latex.codecogs.com/png.latex?P%28X%3Dx%29%20%3D%20%5Cfrac%7B%28x-1%29%21%7D%7B%28r-1%29%21%28x-r%29%21%7D%20%5Ctimes%20p%5E%7Br%7D%281-p%29%5E%7B%28x-r%29%7D%5C%3Bfor%5C%3Bx%3Dr%2C%20r%2B1%2C...
"P(X=x) = \\frac{(x-1)!}{(r-1)!(x-r)!} \\times p^{r}(1-p)^{(x-r)}\\;for\\;x=r, r+1,...")  

The mean is ![E(X) =
\\frac{r}{p}](https://latex.codecogs.com/png.latex?E%28X%29%20%3D%20%5Cfrac%7Br%7D%7Bp%7D
"E(X) = \\frac{r}{p}").  
The variance is ![Var(X) =
\\frac{r(1-p)}{p^2}](https://latex.codecogs.com/png.latex?Var%28X%29%20%3D%20%5Cfrac%7Br%281-p%29%7D%7Bp%5E2%7D
"Var(X) = \\frac{r(1-p)}{p^2}").

**NOte:** The function `dnbinom(x, size, prob)` defines
![x](https://latex.codecogs.com/png.latex?x "x") as the number of
failures prior to the
![r^{th}](https://latex.codecogs.com/png.latex?r%5E%7Bth%7D "r^{th}")
success.

``` r
#-----calculate probability of negative binomial distribution-----    
# in a local region, the probability of getting influenza in winter is 0.08 
# what is the probability that a hospital identifies 5 influenza cases if it randomly samples 50 people   
# assume 100% detection rate of influenza  

r <- 5
p <- 0.08
x <- 50 - r # number of failures before the rth success

dnbinom(x, r, p) 
#> [1] 0.01629236  

#-----create a function with calculates the probability of a negative binomial distribution-----  
calc_neg_binomial <- function(n_trials, r, prob) {
  if(!is.numeric(n_trials) | n_trials < r) {
    stop("Error: n_trials must be a number which is equal to or bigger than r.")
  } 
  
  if(!is.numeric(prob) | prob > 1) {
    stop("Error: prob must be a number which is between 0 and 1.")
  }
  
  if(!is.numeric(r)) {
    stop("Error: r must be a number.")
  }
  
  n_minus_1 <- n_trials - 1
  r_minus_1 <- r - 1
  n_minus_r <- n_trials - r
  
  combinations <- choose(n_minus_1, r_minus_1) 
  combinations * (prob^r) * ((1 - prob)^(n_minus_r))
}

calc_neg_binomial(50, 5, 0.08) 
#> [1] 0.01629236 
```

``` r
#-----calculate probability mass function of negative binomial distribution-----    
neg_binom_dist <- set_names(seq(5, 200, 1)) %>%
  map_df(~ calc_neg_binomial(.x, 5, 0.08)) %>%
  pivot_longer(cols = everything(),
               names_to = "X",
               values_to = "prob") 

mean_trials <- 5 / 0.08  

#-----visualise negative binomial distribution-----
neg_binom_dist %>%
  mutate(X = as.numeric(X)) %>% 
  ggplot(aes(x = X, y = prob)) +  
  geom_segment(aes(x = X, xend = X, y = 0, yend = prob)) +
  geom_point(size = 3, shape = 21, fill = "cadetblue") +
  geom_vline(xintercept = mean_trials, linetype = "dashed", colour = "cadetblue") + 
  scale_x_continuous(breaks = c(seq(0, 200, 10))) + 
  labs(y = "Probability",
       title = "Negative binomial distribution of number of trials to obtain 5 successes") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))     
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-11-1.png" width="80%" />

**Note:** [As per
Wikipedia](https://en.wikipedia.org/wiki/Negative_binomial_distribution),
a property of the negative binomial distribution is that it decreases in
right skewness as ![r](https://latex.codecogs.com/png.latex?r "r")
increases.

``` r
#-----visualise change in negative binomial distribution with increasing r-----   
neg_binom_dist_1 <- set_names(seq(1, 200, 1)) %>%
  map_df(~ calc_neg_binomial(.x, 1, 0.08)) %>%
  pivot_longer(cols = everything(),
               names_to = "X",
               values_to = "prob") %>%
  mutate(r_value = 1)

neg_binom_dist_2 <- set_names(seq(2, 200, 1)) %>%
  map_df(~ calc_neg_binomial(.x, 2, 0.08)) %>%
  pivot_longer(cols = everything(),
               names_to = "X",
               values_to = "prob") %>%
  mutate(r_value = 2)

neg_binom_dist_6 <- set_names(seq(6, 200, 1)) %>%
  map_df(~ calc_neg_binomial(.x, 6, 0.08)) %>%
  pivot_longer(cols = everything(),
               names_to = "X",
               values_to = "prob") %>%
  mutate(r_value = 6)

# create a function to plot negative binomial distributions  

plot_neg_binom <- function(df, r) {
  mean_trials <- r/0.08 
  
  df %>%
    mutate(X = as.numeric(X)) %>% 
    ggplot(aes(x = X, y = prob)) +  
    geom_segment(aes(x = X, xend = X, y = 0, yend = prob)) +
    geom_point(size = 3, shape = 21, fill = "cadetblue") +
    geom_vline(xintercept = mean_trials, linetype = "dashed", colour = "cadetblue") + 
    scale_x_continuous(breaks = c(seq(0, 200, 10))) + 
    labs(y = "Probability",
         title = paste0("Negative binomial distribution of number of trials to obtain ", r, " success(es)")) +  
    theme_minimal() +
    theme(panel.grid = element_blank(),
          panel.border = element_rect(fill = NA, colour = "black"),
          plot.title = element_text(hjust = 0.5))
}    

plot_1 <- plot_neg_binom(neg_binom_dist_1, 1)
plot_2 <- plot_neg_binom(neg_binom_dist_2, 2)
plot_6 <- plot_neg_binom(neg_binom_dist_6, 6)

plot_1 / plot_2 / plot_6 
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-12-1.png" width="80%" />

# Multinomial distribution

The [multinomial
distribution](https://en.wikipedia.org/wiki/Multinomial_distribution)
expands upon the concept of the binomial distribution and models the
probability of counts for each side of a
![k](https://latex.codecogs.com/png.latex?k "k") sided dice (which does
not have to be fair) rolled ![n](https://latex.codecogs.com/png.latex?n
"n") times.

The assumptions of the multinomial distribution are:

  - Trials are independent of each other (observing the outcome from one
    trial does not affect the likelihood of observing an outcome in
    another trial).
  - The number of outcomes possible in a single trial is greater than
    2.  
  - Individual outcomes are mutually exclusive (only one outcome type
    can be observed per trial).  
  - In any single trial, these
    ![k](https://latex.codecogs.com/png.latex?k "k") outcomes occur with
    the probability ![p\_1,
    p\_2,...,p\_k](https://latex.codecogs.com/png.latex?p_1%2C%20p_2%2C...%2Cp_k
    "p_1, p_2,...,p_k") where ![\\displaystyle\\sum\_{i=1}^{k}p\_i
    = 1](https://latex.codecogs.com/png.latex?%5Cdisplaystyle%5Csum_%7Bi%3D1%7D%5E%7Bk%7Dp_i%20%3D%201
    "\\displaystyle\\sum_{i=1}^{k}p_i = 1").

If we let ![X\_i](https://latex.codecogs.com/png.latex?X_i "X_i")
represent the number of occurrences of outcome
![i](https://latex.codecogs.com/png.latex?i "i"), then the probability
mass function of the multinomial distribution can be described below.

<img src="../../02_figures/2020-09-22_multinomial-distribution.jpg" width="80%" style="display: block; margin: auto;" />

  - The expectation of ![E(X\_i) = n\\times
    p\_i](https://latex.codecogs.com/png.latex?E%28X_i%29%20%3D%20n%5Ctimes%20p_i
    "E(X_i) = n\\times p_i").  
  - The variance of is ![Var(X\_i) = n \\times
    p\_i(1-p\_i)](https://latex.codecogs.com/png.latex?Var%28X_i%29%20%3D%20n%20%5Ctimes%20p_i%281-p_i%29
    "Var(X_i) = n \\times p_i(1-p_i)").

<!-- end list -->

``` r
#-----calculate probability of multinomial distribution-----  
# 4 blood types with probabilities pO = 0.45, pA = 0.2, pB = 0.25, pAB = 0.1 
# probability of 10 randomly sampled people where 4 have O, 2 have A, 3 have B and 1 has AB blood type   

dmultinom(x = c(4, 2, 3, 1), prob = c(0.45, 0.2, 0.25, 0.1))  
#> [1] 0.03229242  
```

**Note:** The function `rmultinom` can be used to simulate a matrix of
sample distributions drawn from a multinomial probability.

``` r
#-----simulate a matrix of sample distributions using rmultinom-----  
simulation <- rmultinom(n = 6, # number of experiments
                        size = 10, # number of people samples per experiment
                        prob = c(0.45, 0.2, 0.25, 0.1))  

# transpose matrix so rows reflect a single experiment and columns reflect frequency of each variable observed

simulation %>%
  t() %>%
  as_tibble(.name_repair = "unique") %>%
  rename("Type O" = "...1",
         "Type A" = "...2",
         "Type B" = "...3",
         "Type AB" = "...4") %>%
  knitr::kable()
```

| Type O | Type A | Type B | Type AB |
| -----: | -----: | -----: | ------: |
|      4 |      3 |      3 |       0 |
|      3 |      1 |      3 |       3 |
|      8 |      1 |      1 |       0 |
|      8 |      1 |      1 |       0 |
|      4 |      3 |      3 |       0 |
|      3 |      2 |      3 |       2 |

We can also simulate the multinomial distribution with the example of a
fair dice throw, with sides ![k
= 6](https://latex.codecogs.com/png.latex?k%20%3D%206 "k = 6") and an
equal probability of landing on each number i.e. ![p =
\\frac{1}{6}](https://latex.codecogs.com/png.latex?p%20%3D%20%5Cfrac%7B1%7D%7B6%7D
"p = \\frac{1}{6}").

**Note:** Observe how the frequency of ![X\_1, ...,
X\_k](https://latex.codecogs.com/png.latex?X_1%2C%20...%2C%20X_k
"X_1, ..., X_k") approaches
![\\frac{1}{6}](https://latex.codecogs.com/png.latex?%5Cfrac%7B1%7D%7B6%7D
"\\frac{1}{6}") as the number of dice throws significantly increase.

``` r
#-----create a function to simulate a dice throw-----  
throw_dice <- function() {
  sample(1:6, size = 1, replace = T) 
}

set.seed(111)
throw_dice()
#> [1] 6  
```

``` r
#-----simulate 4 scenarios where dice is thrown 100 times-----      
plot_throws <- function(n_throws, seed) {
  set.seed(seed)
  
  times_100 <- replicate(n_throws, throw_dice()) %>%
    tibble(result = .)  
  
  times_100 <- count(times_100, result) %>%
    mutate(frequency = n / sum(n))  
  
  plot <- times_100 %>%
    ggplot(aes(x = result, y = frequency)) +
    geom_col(fill = "steelblue", colour = "black") + 
    scale_x_continuous(breaks = 1:6) +
    labs(x = "Dice side", y = "Frequency",
         title = paste0("Simulation of ", n_throws, " throws")) +
    theme_bw() +
    theme(panel.grid = element_blank(),
          plot.title = element_text(hjust = 0.5)) 
  
  print(plot)
}

walk2(list(100), list(111, 222, 333, 444), ~ plot_throws(.x, .y))
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-17-1.png" width="40%" /><img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-17-2.png" width="40%" /><img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-17-3.png" width="40%" /><img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-17-4.png" width="40%" />

``` r
#-----simulate 4 scenarios where dice is thrown 10000 times-----   
walk2(list(10000), list(111, 222, 333, 444), ~ plot_throws(.x, .y))
```

<img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-18-1.png" width="40%" /><img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-18-2.png" width="40%" /><img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-18-3.png" width="40%" /><img src="2020-09-22_hypergeometric-and-other-discrete-distributions_files/figure-gfm/unnamed-chunk-18-4.png" width="40%" />

# Resources

  - [Youtube video
    series](https://www.jbstatistics.com/discrete-probability-distributions/)
    explaining discrete probability distributions.  
  - Mathmatical proofs
    [here](https://www.statlect.com/probability-distributions/geometric-distribution)
    and
    [here](https://www.math.utah.edu/~davar/math5010/summer2010/L12.pdf)
    for the derivation of the geometric distribution’s mean and
    variance.  
  - [Blog post](https://rpubs.com/mpfoley73/458721) demonstrating how to
    calculate the geometric distribution in R.  
  - [Blog
    post](http://rstudio-pubs-static.s3.amazonaws.com/458415_99ff3bf974464136a9d925cc9d84a95d.html)
    demonstrating how to calculate the hypergeometric distribution in
    R.  
  - [Mathematical
    proof](http://www.math.ntu.edu.tw/~hchen/teaching/StatInference/notes/lecture16.pdf)
    for deriving the mean and variance of the negative binomial
    distribution.  
  - [Blog post](https://rpubs.com/mpfoley73/458738) demonstrating how to
    calculate the negative binomial distribution in R.  
  - [Blog post](https://rpubs.com/JanpuHou/296336) demonstrating how to
    calculate the multinomial distribution in R.
