Introduction to Chi-squared and F distributions
================
Erika Duan
2021-09-19

-   [Chi-squared distribution](#chi-squared-distribution)
-   [F distribution](#f-distribution)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse,
               patchwork,
               mnormt)   
```

# Chi-squared distribution

The Chi-squared distribution describes the distribution of
![Z^2](https://latex.codecogs.com/png.latex?Z%5E2 "Z^2") values, where
![Z](https://latex.codecogs.com/png.latex?Z "Z") represents a value from
the standard normal distribution.

``` r
# Calculate density for values in a standard normal distribution ---------------
Z <- seq(-3, 3, length.out = 1000)
density <- dnorm(Z, mean = 0, sd = 1)

Z_dist <- tibble(values = Z,
                 density)

# Plot standard normal distribution --------------------------------------------
Z_dist %>%
  ggplot(aes(x = values, y = density)) +
  geom_line() +
  labs(x = "Z value",
       y = "Probability density") + 
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "black"),
        plot.title = element_text(hjust = 0.5))  
```

<img src="st-chi_squared_and_F_distributions_files/figure-gfm/plot Z dist-1.png" width="50%" style="display: block; margin: auto;" />

# F distribution

# Other resources

-   A jbstatistics [YouTube
    video](https://www.youtube.com/watch?v=hcDb12fsbBU) on the
    Chi-squared distribution.  
-   A zedstatistics [YouTube
    video](https://www.youtube.com/watch?v=80ffqpZdKiA) on the
    Chi-squared distribution.
