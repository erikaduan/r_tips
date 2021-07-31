# replicate the minimal example in targets walkthrough 
# https://books.ropensci.org/targets/walkthrough.html

## set up data structure  

airquality <- datasets::airquality
write_csv(datasets::airquality, here("03_blog_posts", "2021-04-03_targets-project-organisation", "data","airquality.csv"))

## create series of functions  

# We will have questions when we set up these environments. 
# where does installing packages go? 
# what checks do we have in place, to check package version (extra consideration)  
# use Roxygen skeletons to consistently name your functions  
# https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html  

# function_1
# plot scatter plot

# function_2  
# create linear model and print summary information  

# function_3 
# output scatter plot with fitted linear model  