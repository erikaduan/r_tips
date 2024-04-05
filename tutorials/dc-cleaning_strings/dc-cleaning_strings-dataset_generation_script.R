# Load required packages -------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               purrr) 

# Create a manual list of survey responses -------------------------------------
# Each list contains a vector containing 2 atomic elements (rating and comment)
survey_list <- list(
  expert_1 = c(
    8,
    '<textarea name="comment" form="1"> &lt;Grade a beans.&gt; Easily melts. 
    Smooth chocolate shell, with a crunchy malty filling, and not so sweet <p> I
    enjoyed this. </textarea>'
    ), 
  expert_2 = c(
    7, 
    '<textarea name="comment" form="1"> &lt;Grade A beans with subtle caramel 
    hints.&gt; Melts well. Smooth exterior. Glossy coating. Malt-filled core may
    be too sweet for some. </textarea>'
    ),  
  expert_3 = c(
    8,
    '<textarea name="comment" form="1"> &lt;Grade A beans.&gt; <p> Caramel and 
    vanilla undertones complement the bitter dark chocolate - low sugar content 
    and smooth chocolate shell. <p> Recommended. </textarea>'
    ),  
  expert_4 = c(
    10, '<textarea name="comment" form="1"> &lt;Grade A cocoa beans.&gt; Melts 
    easily. Smooth dark chocolate contrasts nicely against the crunchy malty 
    filling. </textarea>'
    ),  
  expert_5 = c(
    7,
    '<textarea name="comment" form="1"> &lt;Grade A beans,&gt; likely of Ecuador
    origin. Smooth dark chocolate coating. Malt filling ratio could be 
    decreased. Easy to eat. </textarea>'
    ),  
  fan_1 = c(
    9, 
    '<textarea name="comment" form="1"> Delicious and melts in your mouth. The 
    malt crunch is a nice touch <p> Would recommend. </textarea>'),  
  fan_2 = c(
    10,
    '<textarea name="comment" form="1"> Smooth dark chocolate shell likely made 
    from grade A beans. Has some nice crunch. <p> This is definiely one of my 
    new favourites! </textarea>'
    ),  
  fan_3 = c(
    8,
    '<textarea name="comment" form="1"> Tastes great. Smooth and tasty 
    chocolate. <p> Highly recommended. </textarea>'),  
  fan_4 = c(
    10,
    '<textarea name="comment" form="1"> This will be one of my new favourites. 
    Love the malty interior! </textarea>'
    ),  
  fan_5 = c(
    9, 
    '<textarea name="comment" form="1"> Ive loved Haighs since I was a kid! 
    Love the caramels the most! </textarea>'
    ),  
  fan_6 = c(
    9, 
    '<textarea name="comment" form="1"> Delicious :)!!! </textarea>')
)  

# Convert list into tidy data frame --------------------------------------------
# t() produces a nested data frame where every column contains a matrix array
survey <- survey_list %>% 
  map_df(~ as_tibble(t(.x), .name_repair = "unique")) %>%
  mutate(respondee = names(survey_list)) %>%
  rename("rating" = "...1",
         "comment_field" = "...2") %>%
  select(respondee, everything())  

# Clean global environment by removing redundant objects ----------------------- 
rm(list = setdiff(ls(), "survey"))

# Print output -----------------------------------------------------------------
cat("PASS: loaded survey into global R environment\n") 