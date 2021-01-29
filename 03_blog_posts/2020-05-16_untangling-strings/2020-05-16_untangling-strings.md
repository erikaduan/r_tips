Untangling strings (\#@%\*\!\!)
================
Erika Duan
2021-01-29

  - [Introduction](#introduction)
  - [Creating a test dataset](#creating-a-test-dataset)
  - [Introduction to regular
    expressions](#introduction-to-regular-expressions)
      - [Match characters](#match-characters)
      - [Character anchors](#character-anchors)
      - [Character classes and
        groupings](#character-classes-and-groupings)
      - [Greedy versus lazy matches](#greedy-versus-lazy-matches)
      - [Look arounds](#look-arounds)
  - [Improving comment field
    readability](#improving-comment-field-readability)
  - [Extracting topics of interest](#extracting-topics-of-interest)
  - [Extracting a machine learning friendly
    dataset](#extracting-a-machine-learning-friendly-dataset)
  - [Differences between base R and `stringr`
    functions](#differences-between-base-r-and-stringr-functions)
  - [Other resources](#other-resources)

# Introduction

Comment fields sit somewhere in between tidy tabular data entries and
large text files (i.e. documents) in terms of wrangling effort. They
require human naunce to decode and the quality and completeness of
comments vary between individual entries.

This makes it hard to gauge whether cleaning comment fields is a
worthwhile endeavour (especially when you have multiple other data
sources that need examining). Luckily, some knowledge of string
manipulations and regular expressions can help simplify this process.

# Creating a test dataset

Let’s imagine that my local chocolate company, [Haighs
Chocolates](https://www.haighschocolates.com.au), wants to understand
what food critics versus Haighs fans think about their newest product.
They send out a bag of free samples with a link to an online survey that
asks individuals to rate their chocolates (on a scale of 1 to 10) and
provide additional comments.

**Note:** The code used to create this dataset can be accessed from the
`Rmd` file accompanying this tutorial.

``` r
#-----quickly visualise the test dataset-----  
survey %>%
  head(10) # fields containing html flags are not properly rendered by kable 
```

# Introduction to regular expressions

Regular expressions, or regex, can be thought of as a separate syntax
for handling patterns in strings. In R, regular expressions can be
directly enclosed inside quotes like character strings or explicitly
referenced inside `regex()`. For convenience, I prefer the former
approach but the latter approach can help increase code readability.

``` r
#-----call regular expressions in R-----
many_apples <- c("Apple", "apple", "APPLE", "apples")

str_extract(many_apples, 
            "apples?")  
#> [1] NA       "apple"  NA       "apples"

#-----call regular expressions in R using regex()-----
# regex() provides additional arguments

str_extract(many_apples, 
            regex("apples?", ignore_case = T))  
#> [1] "Apple"  "apple"  "APPLE"  "apples"

# regex() also allows comments to improve regex readability  

str_extract(many_apples, 
            regex("
                  apple  # contains the word apple
                  s?  # contains zero or one of the letter s
                  " , comments = T))
#> [1] NA       "apple"  NA       "apples"    
```

## Match characters

Some sequences of characters have specific meanings. For example, `s`
refers to the letter `"s"` but `\s` refers to any type of white space.
To call whitespace in R, a second backslash `\` is required to escape
special character behaviour i.e. `\\s`.

``` r
#-----examples of special character sequences-----  
words_and_spaces <- c("a cat",
                      "acat",
                      "a   cat",
                      "a\ncat",
                      "a\\ncat")

# "a\\s+cat" calls variations of a...cat separated by one or more whitespaces 
# note that the string "a\ncat" also counts because \n refers to a new line

str_extract(words_and_spaces, "a\\s+cat")  
#> [1] "a cat"   NA        "a   cat" "a\ncat"  NA      

# "\\S+" refers to everything that is not white space (starting from left to right)  

str_extract(words_and_spaces, "\\S+")  
#> [1] "a"       "acat"    "a"       "a"       "a\\ncat"
```

**Note:** The special characters `\s` versus `\S`, `\d` versus `\D` and
`\w` versus `\W` are handy as they allow the extraction of opposite
pattern types. For example, `\w` refers to any word character whilst
`\W` and `[^\w]` both refer to anything that is not a word character.

## Character anchors

I feel that the goal of writing good regex is to be as specific as
possible. This is why character anchors can be useful (i.e. using `^`
and `$` to denote the start and end of your string respectively).

If we revisit the example above, we can see that the presence or absence
of character anchors produces very different outputs.

``` r
#-----impact of character anchors-----    
words_and_spaces <- c(" a cat",
                      "acat",
                      "a   cat",
                      "a\ncat",
                      "a\\ncat")

# "\\S+" refers to everything that is not white space (from left to right unless specified)  

str_extract(words_and_spaces, "\\S+")  
#> [1] "a"       "acat"    "a"       "a"       "a\\ncat"  

str_extract(words_and_spaces, "^\\S+")  
#> [1] NA       "acat"    "a"       "a"       "a\\ncat"   

str_extract(words_and_spaces, "\\S+$") 
#> [1] "cat"     "acat"    "cat"     "cat"     "a\\ncat"     
```

## Character classes and groupings

Character classes and groupings are handy for extracting specific letter
and/or digit combinations. Some special characters found inside
character classes and groupings are:

  - The operation `or` is represented by `|` i.e `[a|c]`  
  - The operation `range` is represented by `-` i.e. `[a-z]`  
  - The operation `excludes` is represented by `^` i.e. `[^a-c]`

**Note:** Representation of a single character is denoted by `[]` and
representation of a grouping i.e. combination of characters is denoted
by `()`.

``` r
#-----extract patterns using character classes i.e. []-----    
strange_fruits <- c("apple1",
                    "bapple2",
                    "capple3",
                    "dapple4",
                    "epple5",
                    "aggle0")

str_extract(strange_fruits, "[a-d]")
#> [1] "a" "b" "c" "d" NA  "a"  

str_extract(strange_fruits, "[a-d][^p]")
#> [1] NA   "ba" "ca" "da" NA   "ag"   

# [a-d][^p] refers to one character between a and d followed by one character that is not p  

str_extract(strange_fruits, "[0|4-9]")
#> [1] NA  NA  NA  "4" "5" "0"   

# [0|4-9] refers to one number that is zero or a number from 4 to 9    
```

``` r
#-----extract character using groupings i.e. ()-----     
strange_fruits <- c("apple1",
                    "bapple2",
                    "capple3",
                    "dapple4",
                    "epple5",
                    "aggle1")  

str_extract(strange_fruits, "a(pp|gg)le")
#> [1] "apple" "apple" "apple" "apple" NA      "aggle"    

# groups can be referenced by their order of appearance i.e. \\1 = first group   

str_extract(strange_fruits, "(a)(p|g)\\2")
#> [1] "app" "app" "app" "app" NA    "agg"   

# (a) is group 1 and can be called using \\1    
# (p|g) is group 2 and can be called using \\2     
```

## Greedy versus lazy matches

In R, regular expression parsing is non-greedy by default. This means
that we need to add quantifiers `*` and `+` to greedily extract zero or
more and one or more characters respectively.

In contrast, using a non-greedy match allows you to extract just the
first characters before a white space or punctuation mark. This is
useful for trimming strings or extracting file or object names.

<img src="../../02_figures/2020-05-16_greedy-matches.jpg" title="Taken from the RStudio stringr cheatsheet" alt="Taken from the RStudio stringr cheatsheet" width="80%" style="display: block; margin: auto;" />

``` r
#-----use cases for greedy matches-----   
messy_dates <- c("Thursday 24th May",
                 "Thursday  24th May  ",
                 " May",
                 "May    ")

str_extract(messy_dates, "^\\w")      
#> [1] "T" "T" NA  "M"   

# greedily extract the first word in the string    

str_extract(messy_dates, "^\\w+")   
#> [1] "Thursday" "Thursday" NA      "May"   

str_extract(messy_dates, "^\\w{1,}") # the quantifier + and {1,} are equivalent    
#> [1] "Thursday" "Thursday" NA      "May"    

str_extract(messy_dates, "^(\\S+)")  
#> [1] "Thursday" "Thursday" NA      "May"    

#-----use cases for non-greedy matches----- 
str_replace_all(messy_dates, "\\s" , "-") # replaces each individual whitespace
#> [1] "Thursday-24th-May"    "Thursday--24th-May--" "-May"                  "May----"       

str_replace_all(messy_dates, "\\s{1,2}" , "-") 
#> [1] "Thursday-24th-May"  "Thursday-24th-May-" "-May"                "May--"         

# use look arounds (next topic) to replace the whitespace(s) after the first word     

str_replace_all(messy_dates, "(?<=^\\w{1,100})\\s{1,2}" , "-") 
#> [1] "Thursday-24th May"   "Thursday-24th May  " " May"                 "May-  "     
```

**Note:** For further details explaining the regex syntax for the last
example, read [this stack overflow
post](https://stackoverflow.com/questions/52431841/how-to-find-the-first-space-in-a-sentence-with-regular-expressions-within-r).

## Look arounds

Look around operations are useful when you are unsure of the pattern
itself, but you know exactly what its preceding or following pattern is.
I’ve found that the clearest explanation of look around operations comes
from the [RStudio
cheetsheet](https://github.com/rstudio/cheatsheets/blob/master/strings.pdf)
on `string_r`, as depicted below.

<img src="../../02_figures/2020-05-16_look-arounds.jpg" title="Taken from the RStudio stringr cheatsheet" alt="Taken from the RStudio stringr cheatsheet" width="80%" style="display: block; margin: auto;" />

``` r
#-----use cases for different types of look arounds-----  
recipes <- c("crossiant recipes",
             "apple pie recipe",
             "chocolate cake  recipe", # extra space
             "cookie receipe",  # deliberate typo
             "secret KFC-recipe", 
             "very secret  McDonalds soft-serve recipe") # extra space  

# use positive look-ahead (?=...) to extract the preceding word

str_extract(recipes, "\\S+(?=\\s*recipes?)")   
#> [1] "crossiant"  "pie"        "cake"       NA           "KFC-"       "soft-serve"   

# use positive look-behind (?<=) on "secret" to identify the secret recipes   

str_extract(recipes, "(?<=secret\\s{1,10})\\S+.+")   
#> [1] NA                            NA                            NA                           
#> [4] NA                            "KFC-recipe"                  "McDonalds soft-serve recipe"   
```

**Note:** Positive look-behinds require defined boundary specifications
i.e. the operation `+` needs to be converted into `{1,1000}`.

# Improving comment field readability

With regex revised, let us return to the Haighs chocolate survey. The
first thing we can see is that html tags have been retained inside the
comment field and that this field is very long (i.e. difficult to read).

We can improve the readability of the survey by:

  - Removing all html tags using regex.  
  - Separating phrases into individual fields i.e. columns using
    [`separate()`](https://tidyr.tidyverse.org/reference/separate.html).

<!-- end list -->

``` r
#-----examine survey data-----
survey %>%
  head(5)   

#-----remove html tags-----
remove_html_tags <- regex("
                          <  # starts with <
                          [^>]+  # contains one or more of all characters excepting > 
                          >  # ends with >
                          ", comments = T)

remove_more_html <- regex("
                          \\& # starts with &
                          \\w+ # contains one or more word characters
                          \\; # ends with ;
                          ", comments = T) 

survey <- survey %>%
  mutate(comment_field = str_replace_all(comment_field, remove_html_tags, ""),
         comment_field = str_replace_all(comment_field, remove_more_html, ""))

#-----examine comment field-----  
survey %>%
  select(comment_field) %>%
  head(5) %>%
  knitr::kable()
```

We can then split the single long comment field into multiple smaller
columns. Many R functions require R regex classes to be wrapped in a
second set of square brackets, e.g. `[[:punct:]]`.

``` r
#-----separate comment field into an unknown number of columns of phrases-----    
nmax <- max(str_count(survey$comment_field, "[[:punct:]]|and|with|against")) + 1

survey <- survey %>%   
  separate(comment_field,
           into = paste0("Field", seq_len(nmax)),
           sep = "[[:punct:]]|and|with|against", # separate on punctuation or conjunctions  
           remove = F,
  extra = "warn",
  fill = "right") 

#-----examine comment field-----  
survey %>%
  select(-c(respondee, rating, comment_field)) %>%
  head(5) %>%
  knitr::kable()
```

# Extracting topics of interest

After separating the comment field into individual phrases, I can see
that there are references to:

  - the cocoa bean grade  
  - presence of caramel or vanilla flavour  
  - chocolate smoothness  
  - how well the chocolate melts  
  - sugar content/ sweetness level  
  - malt filling  
  - chocolate coating

Information about cocoa bean grade is highly structured. This means that
extracting the letter following the word “Grade” is sufficient. A
similar logic can be applied to extract whether caramel or vanilla
flavour or chocolate smoothness was mentioned.

``` r
#-----extract information about cocoa bean grade, flavour and smoothness-----
tidy_survey <- survey %>%
  select(respondee,
         comment_field) %>% 
  mutate(cocoa_grade = str_extract(comment_field, "(?<=[G|g]rade\\s{0,2})[A-C]"),
         is_caramel = case_when(str_detect(comment_field, "[C|c]aramel") ~ "yes",
                                TRUE ~ "NA"), 
         is_vanilla = case_when(str_detect(comment_field, "[V|v]anilla") ~ "yes",
                                TRUE ~ "NA"),
         is_smooth = case_when(str_detect(comment_field, "[S|s]mooth") ~ "yes",
                               TRUE ~ "NA")) 

# note that when using case_when, TRUE cannot be converted into a logical vector  

tidy_survey <- tidy_survey %>%
  mutate_at(vars(cocoa_grade), ~ replace_na(., "NA"))

# replace NA in cocoa_grade with the character "NA" for consistency    
```

For more descriptive fields such as whether the chocolate melts, I find
it easier to first extract a matrix of fields containing the topic of
interest.

``` r
#-----extract information about chocolate texture-----
melt_matrix <- survey %>%
  select_at(vars(respondee,
                 starts_with("Field"))) %>% 
  mutate_at(vars(starts_with("Field")),
            ~ replace(., !(str_detect(., ".*\\b[M|m]elt.*\\b.*")), NA)) 

# convert fields which do not contain "melt" into NA and unite all fields     

melt_cols <- str_which(colnames(melt_matrix), "^Field.+")

melt_status <- melt_matrix %>%
  unite("is_melty", # new column 
        melt_cols, # unite these columns  
        sep = "",
        remove = T,
        na.rm = T) # make sure to remove NAs  

#-----convert responses into factors and recode factor levels-----  
melt_status$is_melty <- factor(melt_status$is_melty)

levels(melt_status$is_melty) 
#> [1] ""                     " Easily melts"        " Melts easily"        " melts in your mouth" " Melts well"         

melt_status <- melt_status %>%
  mutate(is_melty = fct_collapse(is_melty,
                                 "yes" = c(" Easily melts",
                                           " Melts well",
                                           " Melts easily",
                                           " melts in your mouth"),
                                 "NA" = ""))

#-----left join tidy_survey to melt_status-----  
tidy_survey <- tidy_survey %>%
  left_join(melt_status,
            by = "respondee")
```

This process is repeated for chocolate sweetness.

``` r
#-----extract information about chocolate sweetness-----  
sweetness_matrix <- survey %>%
  select_at(vars(respondee,
                 starts_with("Field"))) %>% 
  mutate_at(vars(starts_with("Field")),
            ~ replace(., !(str_detect(., ".*\\b[S|s](weet)|(ugar).*\\b.*")), NA)) 

# convert fields which do not contain "sweet" or "sugar" into NA and unite all fields     

sweetness_cols <- str_which(colnames(sweetness_matrix), "^Field.+")

sweetness_status <- sweetness_matrix %>%
  unite("is_sweet", # new column 
        sweetness_cols, # unite these columns  
        sep = "",
        remove = T,
        na.rm = T) # make sure to remove NAs  

#-----convert responses into factors and recode factor levels-----  
sweetness_status$is_sweet <- factor(sweetness_status$is_sweet)

levels(sweetness_status$is_sweet) 
#> [1] ""                                      " low sugar content "                   " not so sweet  I enjoyed this"        
#> [4] "filled core may be too sweet for some"

sweetness_status <- sweetness_status %>%
  mutate(is_sweet = fct_collapse(is_sweet,
                                 "yes" = c("filled core may be too sweet for some"),
                                 "no" = c(" low sugar content ",
                                          " not so sweet  I enjoyed this"),
                                 "NA" = ""))

#-----left join tidy_survey to melt_status-----  
tidy_survey <- tidy_survey %>%
  left_join(sweetness_status,
            by = "respondee")
```

**Note:** This method of converting topics into tabular variables works
well when we are not dealing with too many factors (i.e. when recoding
factors is not too cumbersome).

# Extracting a machine learning friendly dataset

A reason why we might be interested in converting unstructured comment
fields into structured variables is to generate data features for
machine learning (i.e. predictive) purposes. For instance, we might be
interested in whether there is a relationship between the topic
commented on, whether the comment comes from a critic or chocolate fan,
and the chocolate rating.

``` r
#-----create final tidy_survey-----
survey_rating <- survey %>%
  select(respondee,
         rating) # extract rating  

tidy_survey <- tidy_survey %>%
  select(-comment_field) %>%
  left_join(survey_rating,
            by = "respondee") %>%
  mutate(respondee = str_extract(respondee, ".+(?=\\_[0-9]+)"))

set.seed(123) # sample reproducibly  
tidy_survey %>%
  sample_n(5) %>%
  knitr::kable() # machine learning friendly format  
```

# Differences between base R and `stringr` functions

In R, string manipulation can be performed using either base R functions
or functions from the `stringr` library. A key difference between base R
and `stringr` functions is the order that the string and pattern are
specified. The pattern, not the string, is specified first inside base R
functions, which is not a pipe friendly argument order.

``` {r'}
#-----use cases for grep()-----  
desserts <- c("chocolate",
              "chocolate cake",
              "chocolate tart",
              "chocolate icecream",
              "chocolate cookies",
              "dark chocolate fudge", 
              "fruit",
              "fruit tart",
              "fruit sorbet")

grep(".*\\bchocolate\\b.*", desserts, value = F) # default is value = FALSE
#> [1] 1 2 3 4 5 6  

str_which(desserts, ".*\\bchocolate\\b.*")  
#> [1] 1 2 3 4 5 6  

grep(".*\\bchocolate\\b.*", desserts, value = T) 
#> [1] "chocolate"            "chocolate cake"       "chocolate tart"       "chocolate icecream"  
#> [5] "chocolate cookies"    "dark chocolate fudge"  

str_subset(desserts, ".*\\bchocolate\\b.*") 
#> [1] "chocolate"            "chocolate cake"       "chocolate tart"       "chocolate icecream"  
#> [5] "chocolate cookies"    "dark chocolate fudge"  

# str_subset() is a wrapper around x[str_detect(x, pattern)]   
```

``` r
#-----use cases for grepl()-----  
desserts <- c("chocolate",
              "chocolate cake",
              "chocolate tart",
              "chocolate icecream",
              "chocolate cookies",
              "dark chocolate fudge", 
              "fruit",
              "fruit tart",
              "fruit sorbet")

grepl(".*\\bchocolate\\b.*", desserts) 
#> [1]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE  

str_detect(desserts, ".*\\bchocolate\\b.*")  
#> [1]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE  
```

``` r
#-----use cases for gsub()-----   
desserts <- c("chocolate",
              "chocolate cake",
              "chocolate tart",
              "chocolate icecream",
              "chocolate cookies",
              "dark chocolate fudge", 
              "fruit",
              "fruit tart",
              "fruit sorbet")

gsub("chocolate", "vanilla", desserts) 
#> [1] "vanilla"            "vanilla cake"       "vanilla tart"       "vanilla icecream"   "vanilla cookies"   
#> [6] "dark vanilla fudge" "fruit"              "fruit tart"         "fruit sorbet"  

str_replace_all(desserts, "chocolate", "vanilla") 
#> [1] "vanilla"            "vanilla cake"       "vanilla tart"       "vanilla icecream"   "vanilla cookies"   
#> [6] "dark vanilla fudge" "fruit"              "fruit tart"         "fruit sorbet"    
```

<img src="2020-05-16_untangling-strings_files/figure-gfm/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />

**Note:** Base R functions are significantly faster than their `stringr`
equivalents.

# Other resources

  - Tips on regular expression usage are based on the excellent [regular
    expressions
    vignette](https://cran.r-project.org/web/packages/stringr/vignettes/regular-expressions.html)
    from `stringr`.  
  - [Strings chapter](https://r4ds.had.co.nz/strings.html) from R4DS by
    Garrett Grolemund and Hadley Wickham.  
  - The Rstudio [`stringr`
    cheatsheet](https://github.com/rstudio/cheatsheets/blob/master/strings.pdf).  
  - Sites for testing your own regular expressions:
      - <https://regex101.com/>
