# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,
               ids, # Generate random ids
               data.table,
               dplyr)   

# Create a function to generate random dates -----------------------------------  
create_start_dates <- function(start_date, end_date, n) {
  # Ensures that start_date and end_date handle the YYYY-mm-dd string format 
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", start_date) | 
     !grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)) {
    stop("Error: start_date and end_date should be written in the format YYYY-mm-dd")
  }
  
  start_date <- as.Date(start_date, format = "%Y-%m-%d")
  end_date <- as.Date(end_date, format = "%Y-%m-%d")  
  
  if(end_date < start_date) {
    stop("Error: start_date should be earlier than end_date")
  }
  
  # Outputs a new date between the start and end date n times 
  # The same date can be outputted using replace = TRUE
  new_date <- sample(seq(start_date, end_date, by = "day"),
                     n,
                     replace = TRUE)
  return(new_date)
}  

# Create a data frame containing 1M course enrollments -------------------------
# Create 300K unique student_ids and sample with replacement 1M times  
set.seed(111)
id <- random_id(n = 300000, bytes = 4,
                use_openssl = FALSE) # Set to FALSE so set.seed() works  

student <- sample(id, 1000000,
                  replace = T) |> 
  sort()

# Simulate 5 platforms with different market shares and generate 1M entries ---- 
set.seed(111)
platform <- sample(LETTERS[1:5], 1000000,
                   replace = T,
                   prob = c(0.70, 0.01, 0.03, 0.06, 0.20)) 

# Create 17 unique course names and generate 1M entries ------------------------
courses_all <- c("R_beginner",
                 "R_intermediate",
                 "R_advanced",
                 "Python_beginner",
                 "Python_intermediate",
                 "Python_advanced",
                 "machine_learning",
                 "linear_algebra",
                 "statistics",
                 "UX_design",
                 "website_design",
                 "data_mining",
                 "travel_writing",
                 "bread_baking",
                 "contemporary_dance",
                 "carpentry",
                 "pottery")  

course <- sample(courses_all, 1000000,
                 replace = T)  

# Create data frame of students, platform and course records -------------------
courses_df <- data.table(index = seq(1, 1000000, 1), # For future left joins  
                         student,
                         platform,
                         course)  

cat("PASS: created student ID, platform and course variables for",
    nrow(courses_df),
    "rows\n")    

# Create the variable platform_start_date -------------------------------------- 
# Concatenate student and platform to create a unique ID   
platform_df <- courses_df[,
                          .(index,
                            student,
                            platform)]

platform_df[,
            student_platform := paste(student, platform, sep = "-")]

# A student switches to a new platform when is.na(previous_student_platform) 
# or previous_student_platform != student_platform is true.      
platform_df[,
            previous_student_platform := lag(student_platform, 1),
            by = student]

platform_subset <- platform_df[is.na(previous_student_platform) | 
                                 previous_student_platform != student_platform] 

# Create a random platform start date every time a student switches to a new platform
platform_subset[,
                platform_start_date := create_start_dates(start_date = "2016-01-01",
                                                          end_date = "2019-01-01",  
                                                          n = nrow(platform_subset))]

# Create the variable platform_end_date ----------------------------------------
set.seed(111)
platform_length <- runif(nrow(platform_subset),
                         min = 9, max = 60) |>
  floor()

platform_subset[,
                platform_end_date := platform_start_date + platform_length]

platform_subset <- platform_subset[,
                                   .(index,
                                     platform_start_date,
                                     platform_end_date)]

cat("PASS: created synthetic platform start and end dates for",
    nrow(courses_df),
    "rows\n")  

# Left join courses_df to platform_df by courses_df index ----------------------
courses_df <- platform_subset[courses_df,
                              on = "index"]   

# Fill platform_start_date and platform_end_date with value above the row with 
# a missing value.
setnafill(courses_df, type = "locf",
          cols = c("platform_start_date",
                   "platform_end_date"))

courses_df <- courses_df[,
                         .(student,
                           platform,
                           course,
                           platform_start_date,
                           platform_end_date)]  

# Sort by student and ascending platform start date i.e. oldest date first   
setorder(courses_df, student, platform_start_date)

# Clean global environment by removing redundant objects ----------------------- 
rm(list = setdiff(ls(), "courses_df"))
gc()

# Print output -----------------------------------------------------------------
cat("PASS: loaded courses_df data.table into global R environment\n")   
