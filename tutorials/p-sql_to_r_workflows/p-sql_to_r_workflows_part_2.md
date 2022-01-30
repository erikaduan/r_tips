How to integrate SQL and R - Part 2
================
Erika Duan
2022-01-30

-   [Introduction](#introduction)
-   [SQL syntax quirks](#sql-syntax-quirks)
    -   [Writing SQL `JOIN` queries](#writing-sql-join-queries)
    -   [Writing SQL `GROUP BY` queries](#writing-sql-group-by-queries)
    -   [Writing SQL `WINDOW` functions](#writing-sql-window-functions)
    -   [Writing SQL subqueries](#writing-sql-subqueries)
-   [Production friendly workflows](#production-friendly-workflows)
-   [Other resources](#other-resources)

``` r
# Load required packages -------------------------------------------------------  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,  
               dbplyr,
               tidyverse,
               odbc,
               DBI,
               Rcpp)   
```

# Introduction

The second part of my tutorial series about SQL to R workflows is mainly
focused on breaking down differences between SQL and R syntax. It also
contains a rehash of Emily Riederer’s excellent [blog
post](https://emilyriederer.netlify.app/post/sql-r-flow/) on designing
flexible workflows for SQL to R projects. We will be using the SQL
database(s) we set up in the [first
tutorial](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-sql_to_r_workflows/p-sql_to_r_workflows_part_1.md)
for the exercises below.

``` r
# Create MS SQL connection -----------------------------------------------------
tsql_conn <- DBI::dbConnect(odbc::odbc(),
                            Driver = "SQL Server Native Client 11.0",
                            Server = "localhost",
                            Database = "sandpit",
                            Trusted_Connection = "Yes")
```

# SQL syntax quirks

In my opinion, the easiest way of learning SQL code is to remember the
sequence of how SQL code is executed. In R, because we can chain
multiple operations together, the sequence in which R code is written is
usually identical to the sequence in which it is executed.

<img src="../../figures/p-sql_to_r_workflows-execution_order.svg" width="80%" style="display: block; margin: auto;" />

In SQL, the sequence in which SQL code is written does not correspond to
the sequence in which it is executed, which leads to common errors like
the example below.

``` r
# Incorrect SQL query ----------------------------------------------------------
# odbc::dbSendQuery(
#   tsql_conn,
#   "
#   SELECT 
#   student_id AS hobbit_id,
#   first_name, 
#   last_name
#   
#   FROM education.student
#   WHERE hobbit_id <> 2
#   
#   -- this query will generate an error as WHERE is executed before SELECT and
#   -- the renaming of student_id to hobbit_id only happens via SELECT 
#   "
# ) 

# Correct SQL query ------------------------------------------------------------
odbc::dbSendQuery(
  tsql_conn,
  "
  SELECT
  student_id AS hobbit_id,
  first_name, 
  last_name
  
  FROM education.student
  WHERE student_id <> 2
  
  -- student_id is first filtered via WHERE and then renamed as hobbit_id via SELECT
  "
) %>%
  odbc::dbFetch() %>%
  knitr::kable()
```

| hobbit\_id | first\_name | last\_name |
|-----------:|:------------|:-----------|
|          1 | Frodo       | Baggins    |
|          3 | Merry       | Brandybuck |
|          4 | Peregrin    | Took       |

## Writing SQL `JOIN` queries

The `dplyr` syntax for joining tables is very similar to its
corresponding SQL syntax. The concept of left joins, right joins, inner
joins and full joins are shared across both languages. In SQL, `JOIN` is
executed directly after `FROM` and it is best practice to aliasing
(rename via `AS`) table names to specify the records to join.

**Note:** Always ensure that you are joining to at least one column
containing unique Ids to prevent unexpected many-to-many joined results.

``` r
# Perform inner join using SQL query -------------------------------------------
odbc::dbSendQuery(
  tsql_conn,
  "
  SELECT
  c.course_name,
  c.course_desc,
  p.platform_name,
  p.company_name
  
  FROM education.course AS c
  INNER JOIN education.platform AS p
    ON c.platform_id = p.platform_id
  
  WHERE is_active = 1 OR is_active IS NULL
  
  -- select course name and description and their corresponding platform and
  -- company name for platforms that are active or NULL for is_active 
  "
) %>%
  odbc::dbFetch() %>%
  knitr::kable()
```

| course\_name                      | course\_desc                                                               | platform\_name  | company\_name |
|:----------------------------------|:---------------------------------------------------------------------------|:----------------|:--------------|
| See shiny orbs                    | 5/5 experience! Just ask the wisest wizard Saruman                         | Seeing Wise     | Palantir Inc  |
| Breakfast pies                    | Savoury pies and sweet pies for breakfast and second breakfast             | Jolly Bakers    | Shire School  |
| Emergency dwarven bread           | Bake these goods to politely send unexpected guests off on their way again | Jolly Bakers    | Shire School  |
| Growing vegetable pie ingredients | All good hobbits should know that vegetable pies cannot be vegetarian      | Happy Gardeners | Shire School  |
| Growing flowers                   | Hobbits should not just grow plants for eating!                            | Happy Gardeners | Shire School  |

The equivalent R `dplyr` syntax follows the execution order, rather than
written order, of the SQL join query.

**Note:** When using `dbplyr`, the education schema needs to explicitly
passed using the function `in_schema("schema", "table")` inside `tbl()`.

``` r
# Perform inner join using R syntax --------------------------------------------
tbl(tsql_conn, in_schema("education", "course")) %>%
  inner_join(tbl(tsql_conn, in_schema("education", "platform")),
             by = c("platform_id" = "platform_id")) %>%
  filter(is_active == 1 | is.na(is_active)) %>%
  select(course_name,
         course_desc,
         platform_name,
         company_name) %>%
  collect() 
```

    ## # A tibble: 5 x 4
    ##   course_name         course_desc                     platform_name company_name
    ##   <chr>               <chr>                           <chr>         <chr>       
    ## 1 See shiny orbs      5/5 experience! Just ask the w~ Seeing Wise   Palantir Inc
    ## 2 Breakfast pies      Savoury pies and sweet pies fo~ Jolly Bakers  Shire School
    ## 3 Emergency dwarven ~ Bake these goods to politely s~ Jolly Bakers  Shire School
    ## 4 Growing vegetable ~ All good hobbits should know t~ Happy Garden~ Shire School
    ## 5 Growing flowers     Hobbits should not just grow p~ Happy Garden~ Shire School

## Writing SQL `GROUP BY` queries

In SQL, grouping by column(s) causes individual records to be grouped
together as record tuples. Because SQL queries return atomic records,
this is why `SELECT` can only be performed on the group by column(s) and
aggregations of other columns.

``` r
# Incorrect SQL query ----------------------------------------------------------
# odbc::dbSendQuery(
#   tsql_conn,
#   "
#   SELECT
#   p.platform_name,
#   COUNT(course_id) as total_courses,
#   c.course_id
#   
#   FROM education.course AS c
#   INNER JOIN education.platform AS p
#     ON c.platform_id = p.platform_id
#   
#   GROUP BY p.platform_id, p.platform_name
#   
#   -- this query will generate an error as course_id is no longer an atomic 
#   -- record once grouped by platform_id and platform_name 
#   "
# )
```

In SQL, `WHERE` and `HAVING` are separate filtering methods as `WHERE`
is executed first across individual records, before the `GROUP BY`
statement. `HAVING` is executed after `GROUP BY` to enable filtering
across individual grouped records and therefore requires an aggregation
as its input.

As `SELECT` is executed last, this also means that the `SELECT`
statement can only refer to the column(s) being grouped and aggregations
of other columns.

``` r
# Perform group by and aggregate SQL query -------------------------------------
odbc::dbSendQuery(
  tsql_conn,
  "
  SELECT
  p.platform_id, 
  p.platform_name,
  COUNT(course_id) as total_courses,
  AVG(course_length) AS avg_course_length, 
  MIN(course_length) AS min_course_length,
  MAX(course_length) AS max_course_length
  
  FROM education.course AS c
  INNER JOIN education.platform AS p
    ON c.platform_id = p.platform_id
  
  WHERE course_length IS NOT NULL
  
  GROUP BY p.platform_id, p.platform_name
  
  HAVING COUNT(course_id) > 1
  
  -- join course and platform tables, filter out courses without a course length
  -- and then group records by platform_id and platform_name 
  -- filter to exclude platforms which only have one course
  -- finally select plaform name, total course count, average course length, min
  -- course length and max course length   
  "
) %>%
  odbc::dbFetch() %>%
  knitr::kable()
```

| platform\_id | platform\_name  | total\_courses | avg\_course\_length | min\_course\_length | max\_course\_length |
|-------------:|:----------------|---------------:|--------------------:|--------------------:|--------------------:|
|            1 | Happy Gardeners |              2 |                  62 |                  35 |                  90 |
|            2 | Jolly Bakers    |              2 |                   5 |                   1 |                  10 |

The equivalent R `dplyr` syntax uses `filter()` before and after
`group_by()` and aggregations are performed inside `summarise()`. R also
allows `mutate()` to be used following `group_by()` to create a new
column that relies on group-based transformations outputted across all
individual records.

``` r
# Perform group by and aggregate using R syntax --------------------------------
tbl(tsql_conn, in_schema("education", "course")) %>%
  inner_join(tbl(tsql_conn, in_schema("education", "platform")),
             by = c("platform_id" = "platform_id")) %>%
  filter(!is.na(course_length)) %>%
  group_by(platform_id, platform_name) %>%
  summarise(total_courses = n_distinct(course_id),
            avg_course_length = mean(course_length),
            min_course_length = min(course_length),
            max_course_length = max(course_length)) %>%
  filter(total_courses > 1) %>%
  ungroup() %>% 
  collect()  
```

    ## `summarise()` has grouped output by 'platform_id'. You can override using the `.groups` argument.

    ## # A tibble: 2 x 6
    ##   platform_id platform_name   total_courses avg_course_length min_course_length
    ##         <int> <chr>                   <int>             <int>             <int>
    ## 1           1 Happy Gardeners             2                62                35
    ## 2           2 Jolly Bakers                2                 5                 1
    ## # ... with 1 more variable: max_course_length <int>

## Writing SQL `WINDOW` functions

## Writing SQL subqueries

# Production friendly workflows

# Other resources

-   A great series of blog posts by Vebash Naidoo, with [part
    1](https://sciencificity-blog.netlify.app/posts/2020-12-12-using-the-tidyverse-with-databases/),
    [part
    2](https://sciencificity-blog.netlify.app/posts/2020-12-20-using-the-tidyverse-with-dbs-partii/)
    and [part
    3](https://sciencificity-blog.netlify.app/posts/2020-12-31-using-tidyverse-with-dbs-partiii/)
    containing advanced tips for using `dbplyr` to query SQL databases
    in R.  
-   Emily Riederer’s excellent [blog
    post](https://emilyriederer.netlify.app/post/sql-r-flow/) containing
    ideas for creating flexible SQL &lt;&gt; R project workflows.  
-   Julia Evan’s entertaining [programming
    zine](https://wizardzines.com/zines/sql/) explaining all things SQL.
    (Paywalled resource)