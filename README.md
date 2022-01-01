# R tips  

This repository contains R programming tips covering topics across data cleaning, data visualisation, machine learning, statistical theory and data productionisation.  

<p align="center">  
<img src="https://github.com/erikaduan/r_tips/blob/master/figures/r_milestones.jpg"
width="600"></center>  
</p>  

Many kudos to [Dr Chuanxin Liu](https://github.com/codetrainee), my former PhD student and code editor, for teaching me how to code in R in my past life as an immunologist.  


# Content summary

| Legend | Category |  
|--------|----------|  
| 📚 | Data cleaning |  
| 🎨 | Data visualisation |  
| 🔮 | Machine learning |  
| 🔨 | Productionisation |  
| 🔢 | Statistical theory |  


# Tutorials  
## 🎨 Data visualisation  

+ [An introduction to `ggplot2` using volcano plots](https://github.com/erikaduan/r_tips/blob/master/tutorials/dv-volcano_plots_with_ggplot/dv-volcano_plots_with_ggplot.md)  
+ [Using `DiagrammeR` to draw flow charts](https://github.com/erikaduan/r_tips/blob/master/tutorials/dv-using_diagrammer/dv-using_diagrammer.md)  

## 📚 Data cleaning

+ [Data cleaning using `data.table` and `tidyverse`](https://github.com/erikaduan/r_tips/blob/master/tutorials/2020-04-07_data-table-versus-dplyr/2020-04-07_data-table-versus-dplyr.md)  
+ [Manipulating character strings using regular expressions](https://github.com/erikaduan/r_tips/blob/master/tutorials/2020-05-16_untangling-strings/2020-05-16_untangling-strings.md)   

## 🔨 Data report productionisation  
+ [Creating SQL <> R workflows](https://github.com/erikaduan/r_tips/blob/master/tutorials/dp-sql_to_r_workflows/dp-sql_to_r_workflows.md)  
+ [Automating R Markdown report generation - Part 1](https://github.com/erikaduan/r_tips/blob/master/tutorials/2020-08-30_automating-RMDs-1/2020-08-30_automating-RMDs-1.md)  
+ [Automating R Markdown report generation - Part 2](https://github.com/erikaduan/r_tips/blob/master/tutorials/2020-09-10_automating-RMDs-2/2020-09-10_automating-RMDs-2.md)  

## 🔮 Machine learning   
+ [Working with dummy variables and factors](https://github.com/erikaduan/r_tips/blob/master/tutorials/2020-04-23_dummy-variables-and-factors/2020-04-23_dummy-variables-and-factors.md)  

## 🔢 Statistical theory   
+ [Introduction to expectation and variance](https://github.com/erikaduan/r_tips/blob/master/tutorials/st-expectations_and_variance/st-expectation_and_variance.md)  
+ [Beyond expectations: centrality measures in statistics](https://github.com/erikaduan/r_tips/blob/master/tutorials/2020-07-26_many-roads-to-the-middle/2020-07-26_many-roads-to-the-middle.md)  
+ [Introduction to the normal distribution](https://github.com/erikaduan/r_tips/blob/master/tutorials/st-normal_distribution/st-normal_distribution.md)  
+ [Introduction to the Chi-squared and F distribution](https://github.com/erikaduan/r_tips/blob/master/tutorials/st-chi_squared_and_f_distributions/st-chi_squared_and_f_distributions.md)  
+ [Introduction to binomial distributions](https://github.com/erikaduan/R_tips/blob/master/tutorials/2020-09-12_binomial_distribution/2020-09-12_binomial-distribution.md)  
+ [Introduction to hypergeometric, geometric, negative binomial and multinomial distributions](https://github.com/erikaduan/R_tips/blob/master/tutorials/2020-09-22_hypergeometric-and-other-discrete-distributions/2020-09-22_hypergeometric-and-other-discrete-distributions.md)  


# Tutorial style guide  

A painful form of technical debt is inconsistent code style. This repository now contains the following file naming and code style rules.  

+ Folders are no longer ordered with a numerical prefix and names are no longer case sensitive e.e.g `r_tips\tutorials\...` and `r_tips\figures\...`    
+ Tutorial subtopics share the same prefix e.g. `r_tips\tutorials\dv-...` and   `r_tips\tutorials\st-...`  
+ File names contain `-` to separate file name prefixes and `_` instead of other white space e.g. `r_tips\figures\dv-using_diagrammer-simple_flowchart.svg`  
+ Comments are styled according to the [tidyverse style guide](https://style.tidyverse.org/functions.html?q=comments#comments-1):    
  + The first comment explains the purpose of the code chunk and is styled differently for enhanced readability e.g. `# Code as header --------`     
  + Comments are written in sentence case and only end with a full stop if they contain at least two sentences  
  + Short comments explaining a function argument do not have to be written on a new line  
  + Comments should not be followed by a blank line, unless the comment is a stand-alone paragraph containing in-depth rationale or an alternative solution  
+ R code chunks are styled as follows:  
  + Each R chunk should be named with a short unique description written in the active voice e.g. `create basic plot` and `modify plot labels`    
  + Arguments inside code chunks should not contain white space and boolean argument options should be written in capitals e.g. `{r load libraries, message=FALSE, warning = FALSE}`   
  + To render the github document, results are generally suppressed using `results='hide'` and manually entered in a new line beneath the code.  
  + To render the github document, figures are generally outputed using `fig.show='hold'` and figure outputs can then be suppressed at the local chunk level using `fig.show='hide'`  
+ Set a margin of 80 characters length in RStudio through `Tools\Global options --> Code --> Display --> Show margin` and use this margin as the cut-off for code and comments length   

# Citations  

+ Hadley Wickham (2017). `tidyverse`: Easily Install and Load the 'Tidyverse'. R package version 1.2.1.
  https://CRAN.R-project.org/package=tidyverse  

+ Matt Dowle and Arun Srinivasan (2019). data.table: Extension of `data.frame`. R package version 1.12.6.
  https://CRAN.R-project.org/package=data.table  

+ Hadley Wickham (2019). `stringr`: Simple, Consistent Wrappers for Common String Operations. R package
  version 1.4.0.
   https://CRAN.R-project.org/package=stringr

+ Max Kuhn. (2019). `caret`: Classification and Regression
  Training. R package version 6.0-84. https://CRAN.R-project.org/package=caret  
    + Contributions from Jed Wing, Steve Weston, Andre Williams, Chris Keefer, Allan Engelhardt, Tony
  Cooper, Zachary Mayer, Brenton Kenkel, the R Core Team, Michael Benesty, Reynald Lescarbeau, Andrew Ziem,
  Luca Scrucca, Yuan Tang, Can Candan and Tyler Hunt.  

+ Jacob Kaplan (2020). `fastDummies`: Fast Creation of Dummy (Binary) Columns and Rows from Categorical
  Variables. R package version 1.6.1. https://CRAN.R-project.org/package=fastDummies  

+ Kirill Müller (2017). `here`: A Simpler Way to Find Your Files. R package version 0.1.
  https://CRAN.R-project.org/package=here  

+ Paul Murrell (2015). `compare`: Comparing Objects for Differences. R package version 0.2-6.
  https://CRAN.R-project.org/package=compare  

+ A. Liaw and M. Wiener (2002). Classification and Regression by `randomForest`. R News 2(3), 18--22.  

+ Tianqi Chen, Tong He, Michael Benesty, Vadim Khotilovich, Yuan Tang, Hyunsu Cho, Kailong Chen, Rory
  Mitchell, Ignacio Cano, Tianyi Zhou, Mu Li, Junyuan Xie, Min Lin, Yifeng Geng and Yutian Li (2020).
  `xgboost`: Extreme Gradient Boosting. R package version 1.0.0.2. https://CRAN.R-project.org/package=xgboost  

+ Alexandros Karatzoglou, Alex Smola, Kurt Hornik, Achim Zeileis (2004). `kernlab` - An S4 Package for Kernel
  Methods in R. Journal of Statistical Software 11(9), 1-20. URL http://www.jstatsoft.org/v11/i09/  

+ Microsoft Corporation and Steve Weston (2019). `doParallel`: Foreach Parallel Adaptor for the `parallel`
  Package. R package version 1.0.15. https://CRAN.R-project.org/package=doParallel  

+ Richard Iannone (2020). `DiagrammeR`: Graph/Network Visualization. R package version 1.0.6.1.  https://CRAN.R-project.org/package=DiagrammeR  