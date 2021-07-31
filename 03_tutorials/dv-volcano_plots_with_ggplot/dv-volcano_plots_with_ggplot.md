How to draw a volcano plot using ggplot2
================
Erika Duan
2021-07-31

-   [Introduction](#introduction)
-   [Import a test dataset](#import-a-test-dataset)
-   [Draw a basic volcano plot](#draw-a-basic-volcano-plot)
-   [Add horizontal and vertical
    lines](#add-horizontal-and-vertical-lines)
-   [Modify the x-axis and y-axis](#modify-the-x-axis-and-y-axis)
-   [Add point colour, size and
    transparency](#add-point-colour-size-and-transparency)
-   [Layer a new subplot](#layer-a-new-subplot)
-   [Label points of interest](#label-points-of-interest)
-   [Modify legend label positions](#modify-legend-label-positions)
-   [Modify plot labels and theme](#modify-plot-labels-and-theme)
-   [Annotate text](#annotate-text)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               tidyverse, 
               janitor, # Cleaning column names  
               scales, # Transform axis scales   
               ggrepel) # Optimise plot label separation  
```

# Introduction

In 2018, whilst still an R newbie, I participated in the [RLadies
Melbourne community lightning
talks](https://github.com/R-LadiesMelbourne/2018-10-16_How-R-You) and
talked about how to visualise volcano plots in R. [Volcano
plots](https://en.wikipedia.org/wiki/Volcano_plot_(statistics)) are an
obscure concept outside of bioinformatics, but their construction can be
used to demonstrate the elegance and versatility of `ggplot2`.

In the last two years, a number of handy new functions have been added
to `dplyr` and `ggplot2`, which this post has been updated to reflect.
The original coding logic should still be attributed to [Chuanxin
Liu](https://github.com/codetrainee), my former PhD student. I also
recommend the excellent [RStudio Cloud ggplot2
tutorials](https://rstudio.cloud/learn/primers/3), which have taught me
some new tricks.

Let’s get started then.

# Import a test dataset

The data used in this tutorial originates from [Fu et al. Nat Cell Biol.
2015](https://pubmed.ncbi.nlm.nih.gov/25730472/) and can be accessed
[here](https://zenodo.org/record/2529117#.X-_obzTis2w). In this
tutorial, a copy of the dataset has been stored in
`../../raw_data/dv_luminal-pregnant-versus-lactate-cells.txt`.

The data contains five columns of interest:

-   **Entrez ID** - stores the unique gene ID.  
-   **Gene symbol** - stores the gene symbol associated with an unique
    Entrez ID.  
-   **Gene name** - stores the gene name associated with an unique
    Entrez ID.  
-   **log2(Fold change)** - stores the log2-transformed change in gene
    expression level betyouen two types of tissue samples.  
-   **Adjusted p-value** - stores the p-value adjusted with a false
    discovery rate (FDR) correction for multiple testing.

Each row displays values for a unique gene, which fulfills tidy data
requirements for creating data visualisations.

``` r
# Load dataset -----------------------------------------------------------------
samples <- read_delim(here("raw_data", "dv_luminal-pregnant-versus-lactate-cells.txt"),
                      delim = "\t") # Columns are separated by a tab 

# Clean column names -----------------------------------------------------------
# Convert columns names to snake case by default using clean_names()  
samples <- clean_names(samples) 

# Manually edit column names using rename()  
samples <- samples %>%
  rename(entrez_id = entrezid,
         gene_name = genename) 

# Visualise the dataset as a table ---------------------------------------------  
samples %>%
  head(6) %>%
  knitr::kable()
```

| entrez\_id | symbol  | gene\_name                                                                      |   log\_fc | ave\_expr |         t | p\_value | adj\_p\_val |
|-----------:|:--------|:--------------------------------------------------------------------------------|----------:|----------:|----------:|---------:|------------:|
|      12992 | Csn1s2b | casein alpha s2-like B                                                          | -8.603611 | 3.5629500 | -43.79650 |        0 |           0 |
|      13358 | Slc25a1 | solute carrier family 25 (mitochondrial carrier, citrate transporter), member 1 | -4.124175 | 5.7796989 | -29.90785 |        0 |           0 |
|      11941 | Atp2b2  | ATPase, Ca++ transporting, plasma membrane 2                                    | -7.386986 | 1.2821431 | -27.81950 |        0 |           0 |
|      20531 | Slc34a2 | solute carrier family 34 (sodium phosphate), member 2                           | -4.177812 | 4.2786290 | -27.07272 |        0 |           0 |
|     100705 | Acacb   | acetyl-Coenzyme A carboxylase beta                                              | -4.314320 | 4.4409137 | -25.22357 |        0 |           0 |
|      13645 | Egf     | epidermal growth factor                                                         | -5.362664 | 0.7359047 | -24.59930 |        0 |           0 |

# Draw a basic volcano plot

A volcano plot depicts:

-   Along its x-axis: `log_fc` i.e. the log2-transformed fold change.  
-   Along its y-axis: `-log10(adj_p_val)` i.e. the -log10-transformed
    adjusted p-value.

**Note:** The transformation `-log10(adj_p_val)` allows points on the
plot to project upwards as the fold change increases or decreases in
magnitude. The adjusted p-value decreases non-linearly as the fold
change increases or decreases in magnitude. Visualising decreasing
`adj_p_val` values in a positive direction along the y-axis is more
intuitive as you are most interested in identifying genes which have a
large fold-change and small adjusted p-value.

You can apply transformations directly inside `ggplot(data, aes(x, y))`.

``` r
# Create a simple volcano plot -------------------------------------------------
vol_plot <- samples %>%
  ggplot(aes(x = log_fc,
             y = -log10(adj_p_val))) + 
  geom_point() 

vol_plot # Visualise a simple volcano plot
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/create%20simple%20vol_plot-1.png)<!-- -->

Alternatively, you can visualise the original values along a transformed
axis using `scale_x_continuous(trans = "...")` or `coord_trans(x, y)` to
transform the axis itself. A guide to creating your own transformation
functions can be found on Stack Overflow
[here](https://stackoverflow.com/questions/49248937/in-rs-scales-package-why-does-trans-new-use-the-inverse-argument).

``` r
# Advanced method to transform the y-axis instead of y values ------------------
neg_log10_trans <- trans_new(name = "neg log10", 
                             transform = function(x) -log10(x),
                             inverse = function(x) 10 ^ (-1 * x),
                             breaks = breaks_log(n = 6, base = 10))

# Check auto-generated breaks()
breaks_log(n = 6, base = 10)(samples$adj_p_val)

samples %>%
  ggplot(aes(x = log_fc,
             y = adj_p_val)) + 
  geom_point() + 
  scale_y_continuous(trans = neg_log10_trans)
```

# Add horizontal and vertical lines

The functions `geom_hline()` and `geom_vline()` can be used to add extra
horizontal and vertical lines on your plot respectively. In this
example, I am interested in visualising boundaries for genes which have
an `adj_p_value <= 0.05` and `log_fc <= -1` or `log_fc >= 1`.

``` r
# Plot extra quadrants ---------------------------------------------------------
vol_plot + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") 
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/add%20plot%20quadrants-1.png)<!-- -->

# Modify the x-axis and y-axis

Volcano plots should have a symmetrical x-axis. One way you can do this
is by manually setting the limits of the x-axis using `xlim(min, max)`.

``` r
# Identify the best range for xlim() -------------------------------------------
samples %>%
  select(log_fc) %>%
  min() %>%
  floor() 
#> [1] -10   

samples %>%
  select(log_fc) %>%
  max() %>%
  ceiling()
#> [1] 8   

c(-10, 8) %>%
  abs() %>% 
  max()
#> [1] 10  

# Modify xlim() ----------------------------------------------------------------  
# Manually specify x-axis limits  
vol_plot + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") + 
  xlim(-10, 10) 
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/modify%20xlim-1.png)<!-- -->

You can also change the limits of the x-axis via `scale_x_continuous`.
This method also gives you the flexibility to fine-tune the spacing and
labelling of axis tick marks.

``` r
# Modify scale_x_continuous() --------------------------------------------------
vol_plot + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") +
  scale_x_continuous(breaks = c(seq(-10, 10, 1)), # Modify x-axis tick intervals  
                     limits = c(-10, 10)) # Modify xlim() range
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/modify%20x%20axis%20breaks-1.png)<!-- -->

**Note:** The value specified inside the argument
`scale_continuous_x(limits = ...)` supersedes the range of values
specified inside the argument `scale_continuous_x(breaks = ...)`.

# Add point colour, size and transparency

To visualise different groups of genes using different colours, point
sizes, shapes or transparencies, you need to categorise genes into
different groups and store these categories as a new parameter i.e. new
column of data.

I am interested in labelling genes into the following groups:

-   Genes with `log_fc >= 1 & adj_p_val <= 0.05` as `up`.  
-   Genes with `log_fc <= -1 & adj_p_val <= 0.05` as `down`.  
-   All other genes labelled as `ns` i.e. non-significant.

``` r
# Create new categorical column ------------------------------------------------
samples <- samples %>%
  mutate(gene_type = case_when(log_fc >= 1 & adj_p_val <= 0.05 ~ "up",
                               log_fc <= -1 & adj_p_val <= 0.05 ~ "down",
                               TRUE ~ "ns"))   

#-----obtaining a summary of gene_type numbers-----           
samples %>%
  count(gene_type) %>%
  knitr::kable()

# The function count() is equivalent to     
# samples %>%
#   group_by(gene_type) %>%
#   summarize(count = n()) 
```

In `ggplot2`, you also have the option to visualise different groups by
point colour, size, shape and transparency by modifying parameters via
`scale_color_manual()` etc. A tidy way of doing this is to store each
visual specifications in a separate vector.

``` r
# Check gene_type categories ---------------------------------------------------
samples %>%
  distinct(gene_type) %>%
  pull()
#> [1] "down" "up"   "ns"    

# Add colour, size and alpha (transparency) to volcano plot --------------------
cols <- c("up" = "#ffad73", "down" = "#26b3ff", "ns" = "grey") 
sizes <- c("up" = 2, "down" = 2, "ns" = 1) 
alphas <- c("up" = 1, "down" = 1, "ns" = 0.5)

samples %>%
  ggplot(aes(x = log_fc,
             y = -log10(adj_p_val),
             fill = gene_type,
             size = gene_type,
             alpha = gene_type)) + 
  geom_point(shape = 21, # Specify shape and colour as fixed local parameters    
             colour = "black") + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") +
  scale_fill_manual(values = cols) + # Modify point colour
  scale_size_manual(values = sizes) + # Modify point size
  scale_alpha_manual(values = alphas) + # Modify point transparency
  scale_x_continuous(breaks = c(seq(-10, 10, 1)),  
                     limits = c(-10, 10))   
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/add%20plot%20colours-1.png)<!-- -->

# Layer a new subplot

You can also overlay subplots on top of your main plot. This is useful
when you want to highlight a subset of your data using different
colours, shapes and etc. When overlaying plots, you should not use `%>%`
pipes but use global `ggplot(data = “…”)` and local
`geom_point(data = ...)` arguments instead.

``` r
# Define a subset of interest from the original data ---------------------------
ils <- str_subset(samples$symbol, "^[I|i]l[0-9]+$")  

il_genes <- samples %>%
  filter(symbol %in% ils) 

# Add subplot layer to the main volcano plot -----------------------------------
ggplot(data = samples, # Original data  
       aes(x = log_fc, y = -log10(adj_p_val))) + 
  geom_point(colour = "grey", alpha = 0.5) +
  geom_point(data = il_genes, # New layer containing data subset il_genes       
             size = 2,
             shape = 21,
             fill = "firebrick",
             colour = "black")  
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/add%20subplot-1.png)<!-- -->

**Note:** Unless local aesthetics are specified, secondary geom\_point()
functions will inherit global `ggplot()` aesthetics.

# Label points of interest

You can also label a subset of data using geom\_text(), geom\_label(),
geom\_text\_repel() or geom\_label\_repel and by specifying which column
to display as text using the local argument
`geom_text(aes(label = ...))`.

**Note:** adjusting the parameters for optimal text separation using
`geom_text_repel()` can be a bit fiddly. I generally start by modifying
`force` and then deciding which region of the plot I want to nudge my
text or labels towards. You can read [this
vignette](https://cran.r-project.org/youb/packages/ggrepel/vignettes/ggrepel.html)
for more tips on adjusting `geom_text_repel()` parameters.

``` r
# Define another subset of interest from the original data ---------------------
sig_il_genes <- samples %>%
  filter(symbol %in% c("Il15", "Il34", "Il24"))

up_il_genes <- samples %>%
  filter(symbol == "Il24")  

down_il_genes <- samples %>%
  filter(symbol %in% c("Il15", "Il34"))   

# Add subplot layer and labels to the main volcano plot ------------------------
ggplot(data = samples,
       aes(x = log_fc,
           y = -log10(adj_p_val))) + 
  geom_point(aes(colour = gene_type), 
             alpha = 0.2, 
             shape = 16,
             size = 1) + 
  geom_point(data = up_il_genes,
             shape = 21,
             size = 2, 
             fill = "firebrick", 
             colour = "black") + 
  geom_point(data = down_il_genes,
             shape = 21,
             size = 2, 
             fill = "steelblue", 
             colour = "black") + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") +
  geom_label_repel(data = sig_il_genes, # Add labels last so they appear as the top layer  
                   aes(label = symbol),
                   force = 2,
                   nudge_y = 1) +
  scale_colour_manual(values = cols) + 
  scale_x_continuous(breaks = c(seq(-10, 10, 2)),     
                     limits = c(-10, 10))    
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/add%20subplot%20labels-1.png)<!-- -->

# Modify legend label positions

If you need to change the order of categorical figure legend values, you
will need to `factor()` and re-level your categorical variable. This can
be done using the `forcats` package, which allows you to easily modify
factor levels.

``` r
# Modify legend labels by re-ordering gene_type levels -------------------------
samples <- samples %>%
  mutate(gene_type = fct_relevel(gene_type, "up", "down")) 

ggplot(data = samples,
       aes(x = log_fc,
           y = -log10(adj_p_val))) + 
  geom_point(aes(colour = gene_type), 
             alpha = 0.2, 
             shape = 16,
             size = 1) + 
  geom_point(data = up_il_genes,
             shape = 21,
             size = 2, 
             fill = "firebrick", 
             colour = "black") + 
  geom_point(data = down_il_genes,
             shape = 21,
             size = 2, 
             fill = "steelblue", 
             colour = "black") + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") +
  geom_label_repel(data = sig_il_genes, # Add labels last so they appear as the top layer  
                   aes(label = symbol),
                   force = 2,
                   nudge_y = 1) +
  scale_colour_manual(values = cols) + 
  scale_x_continuous(breaks = c(seq(-10, 10, 2)),     
                     limits = c(-10, 10))   
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/modify%20legend%20labels-1.png)<!-- -->

# Modify plot labels and theme

The finishing touches include modifying plot labels and the plot theme.

The function `labs()` is a handy way of organising all plot labels
inside a single function. You can assign labels as `NULL` to prevent
them from being displayed.

A plot can be further improved by changing its `theme()` and/or by
modifying individual `theme()` parameters.

``` r
# Add plot labels and modify plot theme ----------------------------------------
final_plot <- ggplot(data = samples,
                     aes(x = log_fc,
                         y = -log10(adj_p_val))) + 
  geom_point(aes(colour = gene_type), 
             alpha = 0.2, 
             shape = 16,
             size = 1) + 
  geom_point(data = up_il_genes,
             shape = 21,
             size = 2, 
             fill = "firebrick", 
             colour = "black") + 
  geom_point(data = down_il_genes,
             shape = 21,
             size = 2, 
             fill = "steelblue", 
             colour = "black") + 
  geom_hline(yintercept = -log10(0.05),
             linetype = "dashed") + 
  geom_vline(xintercept = c(log2(0.5), log2(2)),
             linetype = "dashed") +
  geom_label_repel(data = sig_il_genes,   
                   aes(label = symbol),
                   force = 2,
                   nudge_y = 1) +
  scale_colour_manual(values = cols) + 
  scale_x_continuous(breaks = c(seq(-10, 10, 2)),     
                     limits = c(-10, 10)) +
  labs(title = "Gene expression changes in diseased versus healthy samples",
       x = "log2(fold change)",
       y = "-log10(adjusted P-value)",
       colour = "Expression \nchange") +
  theme_bw() + # Select theme with a white background  
  theme(panel.border = element_rect(colour = "black", fill = NA, size= 0.5),    
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

final_plot 
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/modify%20plot%20labels%20and%20theme-1.png)<!-- -->

**Note:** You can alternatively specify
`panel.grid... = element_line(linetype = "dotted")` inside `theme()` to
create dotted gridlines along the x and/or y axis. Major gridline
positions are inherited from the values of axis breaks.

# Annotate text

You can add more descriptions to a plot by using the function
`annotate()` to display text.

``` r
# Annotate text inside plot ----------------------------------------------------
final_plot + 
  annotate("text", x = 7, y = 10,
           label = "3 interleukins of interest", color = "firebrick")
```

![](dv-volcano_plots_with_ggplot_files/figure-gfm/annotate%20text-1.png)<!-- -->

# Other resources

-   The excellent and interactive [RStudio Cloud `ggplot2`
    tutorials](https://rstudio.cloud/learn/primers/3).  
-   RStudio `ggplot2`
    [cheatsheet](https://github.com/rstudio/cheatsheets/blob/master/data-visualization-2.1.pdf).  
-   STHDA
    [tutorial](http://www.sthda.com/english/wiki/ggplot2-axis-scales-and-transformations#axis-transformations)
    on ggplot2 axis transformations.  
-   An RStudio conference
    [presentation](https://www.danaseidel.com/rstudioconf2020#1) on how
    to use the `scales` package.
