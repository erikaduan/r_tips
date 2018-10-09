Data visualisation via volcano plots
================
**Authors:** Erika Duan and Chuanxin Liu  
**Date:** October 8, 2018

As a wet-lab immunologist, most of my job involves trying to **find** and then **illustrate** meaningful patterns from large biological datasets.

We obtain **a lot** of data from RNA sequencing experiments. These are experiments which look at how many mRNA molecules (i.e. message signals) are found in an object and how these signals differ in quantity across multiple objects.

We often analyse datasets with changes across &gt;10,000 signals between &gt;=2 different objects. A [volcano plot](https://en.wikipedia.org/wiki/Volcano_plot_(statistics)) is one way we visualise all statistically significant versus non-significant differences in one graph.

##### **A typical data analysis pipeline**

1.  A large matrix is obtained, containing the number of signals 'counted' per signal type per object. Each row contains a unique signal ID (i.e. in my case, a unique gene ID) and each column contains all the signal counts for one single object. *The researcher also has additional information about each object (i.e. object classification categories like object type, timepoint, batch etc.). This is very important for downstream RNAseq analysis, but not required for this analysis.*
2.  A minimal information threshold is set (i.e. minimal signal count per signal &gt; 1 for at least 1 object). **An awesome statistical package**, in my case `DESeq2` (<https://bioconductor.org/packages/release/bioc/html/DESeq2.html>), is then used to test whether any signals are differentially expressed between different objects.
3.  **Data visualisation** of all statistically **significant** versus **non-significant** signals between at least two objects, with the aim of highlighting any new or particularly interesting biological patterns.

Here, a **volcano plot** is used to depict:

-   How many signals are differentially expressed (using a statistical cut-off),
-   **and** by how much (i.e. signal fold change),
-   between two objects tested.

##### **Drawing volcano plots with `ggplot2`**

A **results output file** can be created in `DESeq2` i.e. using `results(dds, contrast=c("Sample.type", "A", "B"))` and converted into a dataframe.

For convenience, I have provided a fake results output called `AvsB_results.csv` for use (i.e. a dataframe containing all signal differences between object A versus object B). Since we will be using both `dplyr` and `ggplot2`, I always find it more convenient to download the `tidyverse` package.

``` r
library("tidyverse")
```

    ## -- Attaching packages ----------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 3.0.0     v purrr   0.2.5
    ## v tibble  1.4.2     v dplyr   0.7.6
    ## v tidyr   0.8.1     v stringr 1.3.1
    ## v readr   1.1.1     v forcats 0.3.0

    ## -- Conflicts -------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library("ggrepel") # We will also need this package for the final labelling of data points. 
```

We start with our dataset of interest.

Note that for the volcano plot, you only need **three** columns of information:

1.  Gene symbol (aka unique signal ID)
2.  Log2(fold change) (aka how much the level of each signal in A differs from B by)
3.  Padj (the adjusted P-value or statistical likelihood for whether the signal level in A is not different to that of B)

``` r
AvsB_results <- read.csv("AvsB_results.csv", header = T, stringsAsFactors = F)
str(AvsB_results) # The dataframe contains the 3 columns of info described above. 
```

    ## 'data.frame':    600 obs. of  3 variables:
    ##  $ log2FoldChange: num  3.804 2.104 1.804 1.309 0.525 ...
    ##  $ padj          : num  1.24e-13 7.29e-08 2.30e-05 1.69e-03 1.71e-03 ...
    ##  $ Symbol        : chr  "Ep300" "Nemf" "Atad2b" "Rft1" ...

A simple volcano plot depicts:

-   Along its x-axis: log2(fold change)
-   Along its y-axis: -log10(padj)

Note that the y-axis is depicted as -log10(padj), which allows the data points (i.e. volcano spray) to project upwards as the absolute value along the x axis increases. Graphically, this is more intuitive to visualise.

``` r
simple_vp <- ggplot(AvsB_results, aes(x = log2FoldChange,
                         y = -log10(padj))) + 
  geom_point() # A simple volcano plot is created.

simple_vp
```

![](https://github.com/erikaduan/R-tips/blob/master/Vplot1.png)

This plot is too plain as objects of interest do not easily jump out at us.
A good volcano plot will highlight all the signals (represented by individual data points) which are significantly different between A vs B.
In this case, we would be interested in highlighting genes which have a **padj <= 0.05 (or a -log10(padj) >= 1.30103)** (my chosen statistical cut-off). I would also be interested in highlighting genes which additionally have a log2 fold change &lt;= -1 or &gt;= 1 (signals which are at least 2-fold bigger or smaller).

I can now define these quandrants using:

``` r
simple_vp + 
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") + # horizontal dashed line
  geom_vline(xintercept = c(-1,1), linetype = "dashed") # vertical dashed line
```

![](https://github.com/erikaduan/R-tips/blob/master/Vplot2.png)

The top-left quadrant contains all signals that are significantly decreased in A vs B, and the top right quandrant contains genes that are significantly increased in A vs B. The remaining genes are not significantly different and hence much less interesting to me.

The next thing we can therefore do is to **highlight** these three different groups of signals.
To do this, I return to my original dataframe and use the `dplyr::mutate` function.

``` r
AvsB_results <- mutate(AvsB_results,
                       AvsB_type = ifelse(is.na(padj)|padj > 0.05|abs(log2FoldChange) < 1, "ns", 
                         ifelse(log2FoldChange <= -1, "down",
                                "up"))) # creates a new column called AvsB_type, with signals classified as "ns", "down" or "up"

group_by(AvsB_results, AvsB_type) %>%
  summarize(Counts = n()) # counts how many signals are present in each category
```

    ## # A tibble: 3 x 2
    ##   AvsB_type Counts
    ##   <chr>      <int>
    ## 1 down           3
    ## 2 ns           591
    ## 3 up             6

Now that AvsB_type can segregate each signal based on whether it is 'up', 'down' or 'ns' (non-significant), I can colour these three signal types differently (and/or change their size/transparency to make different points stand out more versus less).

``` r
cols <- c("up" = "#ffad73", "down" = "#26b3ff", "ns" = "grey") 
sizes <- c("up" = 3, "down" = 3, "ns" = 1) 
alphas <- c("up" = 1, "down" = 1, "ns" = 0.5)

ggplot(AvsB_results, aes(x = log2FoldChange,
                         y = -log10(padj))) +
  geom_point(aes(colour = AvsB_type, #specify point colour by AvsB_type
                 size = AvsB_type, #specify point size by AvsB_type
                 alpha = AvsB_type)) + #specify point transparency by AvsB_type
  scale_color_manual(values = cols) +
  scale_size_manual(values = sizes) +
  scale_alpha_manual(values = alphas) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") + 
  geom_vline(xintercept = c(-1,1), linetype = "dashed") 
```

![](https://github.com/erikaduan/R-tips/blob/master/Vplot3.png)

This is great! But there is still one final nifty trick!

As a biologist, I often get &gt;100s of genes which are significantly increased or decreased between two objects. To examine whether **interesting patterns (interconnected signals)** exist within these 100 genes, I run them through gene over-representation databases like [this one](http://software.broadinstitute.org/gsea/msigdb/index.jsp).

``` r
Interesting_pathway <- c("Nemf", "Rft1", "Atp5h") # An external database identifies an interesting signal network! 
```

We would like to highlight these particular signals, by representing them in a different (darker) colour and also by labelling each individual point of interest.

``` r
ggplot(AvsB_results, aes(x = log2FoldChange,
                         y = -log10(padj))) +
  geom_point(aes(colour = AvsB_type,
                 size = AvsB_type,
                 alpha = AvsB_type)) +
  scale_color_manual(values = cols) +
  scale_size_manual(values = sizes) +
  scale_alpha_manual(values = alphas) +
  scale_x_continuous(limits = c(-4, 4)) + # changing the x-axis to make my volcano plot symmetrical
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") + 
  geom_vline(xintercept = c(-1,1), linetype = "dashed") +
  geom_text_repel(data = AvsB_results %>% 
                    filter(Symbol %in% Interesting_pathway), # labels only genes in the interesting pathway
                  aes(label = Symbol),
                  size = 3.5,
                  color = "black",
                  nudge_x = 0.3, nudge_y = 0.1) + 
  geom_point(data = AvsB_results %>%
               filter(Symbol %in% Interesting_pathway), # adds new points for only genes in the interesting pathway
             color = "#d91933",
             size = 2) +
  theme_classic() + # creates a white background
  theme(panel.border = element_rect(colour = "black", fill=NA, size= 0.5)) # creates a plot border
```

![](https://github.com/erikaduan/R-tips/blob/master/Vplot4.png)

Voila! Enjoy your volcano plot (and remember, there are lots of graphical modifiers you can use to visualise data using them, as long as your methods are logical and reasonable)!

##### **Development notes**

**Chuanxin Liu** devised the elegant strategy for labelling all signal types as 'up', 'ns' or 'down' and the code for the labelling of specific signal data points.

Please note that for RNAseq, the signals from each object are derived from data from three replicates (i.e. three biological replicates per sample type).  

##### **Other resources**

<http://www.bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html>

<http://www.sthda.com/english/wiki/ggplot2-texts-add-text-annotations-to-a-graph-in-r-software>

<http://www.sthda.com/english/wiki/ggplot2-axis-scales-and-transformations#change-x-and-y-axis-limits>
