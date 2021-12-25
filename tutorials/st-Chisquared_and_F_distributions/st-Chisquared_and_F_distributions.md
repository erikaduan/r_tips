Introduction to Chi-squared and F distributions
================
Erika Duan
2021-12-25

-   [Chi-squared distribution](#chi-squared-distribution)
    -   [1 degree of freedom](#1-degree-of-freedom)
    -   [2 or more degrees of freedom](#2-or-more-degrees-of-freedom)
-   [F distribution](#f-distribution)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse,
               patchwork)   
```

# Chi-squared distribution

The Chi-squared distribution, with degrees of freedom
![k](https://latex.codecogs.com/png.latex?k "k"), describes the
distribution of
![\\displaystyle \\sum\_{1=1}^{k} Z\_k^2](https://latex.codecogs.com/png.latex?%5Cdisplaystyle%20%5Csum_%7B1%3D1%7D%5E%7Bk%7D%20Z_k%5E2 "\displaystyle \sum_{1=1}^{k} Z_k^2")
values, where ![Z\_k](https://latex.codecogs.com/png.latex?Z_k "Z_k")
represents any value from a standard normal distribution.

The probability density function of a Chi-squared distribution is
described by the equation below:  
![f(x) = \\frac{x^{k/2 - 1}e^{-x/2}}{2^{k/2}\\Gamma(k/2)}](https://latex.codecogs.com/png.latex?f%28x%29%20%3D%20%5Cfrac%7Bx%5E%7Bk%2F2%20-%201%7De%5E%7B-x%2F2%7D%7D%7B2%5E%7Bk%2F2%7D%5CGamma%28k%2F2%29%7D "f(x) = \frac{x^{k/2 - 1}e^{-x/2}}{2^{k/2}\Gamma(k/2)}")
for
![x \\geq 0](https://latex.codecogs.com/png.latex?x%20%5Cgeq%200 "x \geq 0").

## 1 degree of freedom

The Chi-squared distribution with 1 degree of freedom is simply the
distribution of ![Z^2](https://latex.codecogs.com/png.latex?Z%5E2 "Z^2")
values.

``` r
# Calculate density for values in a standard normal distribution ---------------
Z <- seq(-3, 3, length.out = 1000)
Z_density <- dnorm(Z, mean = 0, sd = 1)

Z_dist <- tibble(values = Z,
                 density = Z_density)

# Plot standard normal distribution --------------------------------------------
Z_dist %>%
  ggplot(aes(x = values, y = density)) +
  geom_line() +
  labs(x = "Z",
       y = "Probability density",
       title = "Standard normal distribution") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))   
```

<img src="st-chisquared_and_f_distributions_files/figure-gfm/plot Z dist-1.png" width="50%" style="display: block; margin: auto;" />

``` r
# Calculate and plot frequency of Z^2 values -----------------------------------
Z_squared <- Z^2

freq_plot <- Z_squared %>%
  as_tibble() %>%
  ggplot(aes(x = value)) +
  geom_histogram(binwidth = 0.1, fill = "white", colour = "black") +
  labs(x = "Z squared",
       y = "Frequency",
       title = "Frequency of Z squared values") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5)) 

# Calculate and plot Chi-squared distribution with df = 1 ----------------------
Chisq <- seq(0, 9, length.out = 1000)

Chisq_density <- dchisq(Chisq, df = 1) 

Chisq_dist <- tibble(values = Chisq,
                     density = Chisq_density)  

density_plot <- Chisq_dist %>%
  ggplot(aes(x = values, y = density)) +
  geom_line() +
  scale_y_continuous(limits = c(0, 1.5)) + 
  labs(x = "Z squared",
       y = "Probability density",
       title = "Chi-squared distribution with df = 1") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))  

(freq_plot + density_plot)
```

<img src="st-chisquared_and_f_distributions_files/figure-gfm/plot Chisq dist-1.png" style="display: block; margin: auto;" />

**Note:** The shape of this distribution can be explained by the
observation that the majority of Z values are distributed around 0 and
produce a smaller value when they are squared
e.g. ![0.1^2 = 0.01](https://latex.codecogs.com/png.latex?0.1%5E2%20%3D%200.01 "0.1^2 = 0.01").

## 2 or more degrees of freedom

# F distribution

# Other resources

-   A jbstatistics [YouTube
    video](https://www.youtube.com/watch?v=hcDb12fsbBU) on the
    Chi-squared distribution.  
-   A zedstatistics [YouTube
    video](https://www.youtube.com/watch?v=80ffqpZdKiA) on the
    Chi-squared distribution.  
-   The Free University of Berlin [statistics
    tutorial](https://www.geo.fu-berlin.de/en/v/soga/Basics-of-statistics/Continous-Random-Variables/Chi-Square-Distribution/Chi-Square-Distribution-in-R/index.html)
    on how to calculate and plot the Chi-squared distribution.
