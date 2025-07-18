How to set up a Positron IDE
================
Erika Duan
2025-07-16

- [Integrated Development
  Environments](#integrated-development-environments)
- [Choosing Positron as an IDE](#choosing-positron-as-an-ide)
- [Positron Windows setup](#positron-windows-setup)
- [Positron versus RStudio usage
  differences](#positron-versus-rstudio-usage-differences)
  - [File organisation](#file-organisation)
  - [Switching between R and Python](#switching-between-r-and-python)
- [Other resources](#other-resources)

# Integrated Development Environments

An Integrated Development Environment (IDE) is simply a software
application that supports code development. Different IDEs are popular
for different languages:

- R programmers tend to use
  [RStudio](https://posit.co/download/rstudio-desktop/).

- Cloud platform constrained Python programmers tend to use a
  proprietary variation of [JupyterLab](https://jupyter.org/).

- Programmers switching between R, Python, Julia or other programming
  languages tend to use [Visual Studio
  Code](https://code.visualstudio.com/) (VS Code).

The RStudio IDE is already thoughtfully designed to support data
exploration and R code development. If you mostly program in R, I
recommend staying with the [RStudio
IDE](https://posit.co/download/rstudio-desktop/) and skipping this
tutorial.

# Choosing Positron as an IDE

If you are a data scientist who loves the RStudio experience but
frequently codes in Python or Julia, then
[Positron](https://positron.posit.co/start.html) may be an appealing
IDE.

The core features of Positron are:

- It has an [R kernel](https://github.com/posit-dev/ark) for
  [Jupyter](https://docs.jupyter.org/en/latest/what_is_jupyter.html)
  applications. The `ark` R kernel enables R code to be run
  interactively in `.R` scripts and `.Rmd` and `.qmd` notebooks inside
  Positron. It also provides an R console beneath the scripts/notebooks
  panel. This is a key feature that JupyterLab and VS Code previously
  lacked for R programming.

- It uses the [IPython Python
  kernel](https://docs.jupyter.org/en/latest/reference/ipython.html) for
  interactive Python programming and supports interactive Julia
  programming through the [Julia VS Code
  extension](https://github.com/julia-vscode/julia-vscode?tab=readme-ov-file)
  similar to VS Code.

- It has a customisable IDE layout that is better suited for data
  exploration, with ***Variables*** and ***Plots*** panes for each R
  session, and ***Connections***, ***Help*** and ***Viewer*** panes
  similar to RStudio.

  ![](../../figures/s-positron_setup-4_panel_layout.png)

- It supports rendering of `.Rmd` and `.qmd` notebooks into HTML and PDF
  documents similar to RStudio. You can choose to view rendered
  documents through the ***Viewer*** pane inside Positron. **Note:**
  Rendering of `.qmd` notebooks into PDFs currently does not work inside
  Positron for me.

- It is built on the [open source
  version](https://github.com/microsoft/vscode) of VS Code, so it
  aesthetically resembles VS Code.

- It supports most VS Code extensions. Microsoft does not permit access
  to Visual Studio Marketplace for non-Microsoft Visual Studio builds,
  so Positron’s Visual Studio extensions are hosted by [Open
  VSX](https://open-vsx.org/).

# Positron Windows setup

Positron can be [installed](https://positron.posit.co/download.html) in
Windows, Mac or Linux operating systems.

My simple Windows setup only involves several steps. These are all
listed in the ***Migrating from RStudio to Positron*** walkthrough on
the Positron Welcome page.

1.  Download the [Positron IDE](https://positron.posit.co/download.html)
    onto your desktop.

    ![](../../figures/s-positron_setup-migration_walkthrough.png)

2.  Import [RStudio
    keybindings](https://positron.posit.co/rstudio-keybindings.html) by
    navigating to ***File*** \> ***Preferences*** \> ***Settings***,
    searching for `workbench.keybindings.rstudioKeybindings` and
    clicking the ***Enable*** checkbox. Restart Positron for the
    settings to take effect.

    Examples of RStudio keybindings that I use are `Ctrl` + `Alt` + `I`
    to insert a new R markdown cell and `Ctrl` + `I` to re-indent
    selected code.

3.  Opt-in to use the R code formatter
    [`air`](https://www.tidyverse.org/blog/2025/02/air/), which
    re-formats code inside `.R`, `.Rmd` and `.qmd` files. The easiest
    way to integrate `air` inside Positron is to enable it to format
    code on save. Navigate to ***File*** \> ***Preferences*** \>
    ***Settings***, search for `@lang:r editor.formatOnSave` and click
    the ***Format a file on save*** checkbox.

    ![](../../figures/s-positron_setup-air_demo.gif)

    The formatter `air` is used to:

    - Automatically indent R code.  
    - Split long lines of code over multiple lines (with a default code
      line width of 80 characters).  
    - Standardise the white space around code elements.  
    - Code formatting can be manually disabled by placing `# fmt: skip`
      in front of an expression.

# Positron versus RStudio usage differences

## File organisation

In RStudio, it is best practice to set up R projects by creating an
`r_project_name.Rproj` file. This `.Rproj` file marks the project root
folder and is used by the R package `here` to build relative file paths
within a self-contained project. Double clicking on an `.Rproj` file
also launches a new R session with the project directory set as the
project root.

Positron does not support `.Rproj files` and [alternative practices are
required](https://positron.posit.co/rstudio-rproj-file.html).

- In Positron, navigating to ***Explorer*** \> ***Open Folder*** will
  open a directory and set it as the project root.

- If using `here`, the project root folder is still identifiable from
  the presence of the `.git/` folder or by creating an empty `.here`
  file in the project root folder. It is best practice to ensure that
  all your projects use Git for code version control anyway.

- Use the
  [`Project Manager`](https://open-vsx.org/extension/alefragnani/project-manager)
  VS extension to navigate between multiple projects. In Project
  Manager, you can:

  - Set up a list of projects by manually saving individual directories
    as favourites. First open a project by navigating to ***Explorer***
    \> ***Open Folder***. Then navigate to the ***Project Manager tab***
    and click on the ***Save*** icon to save your currently open file
    directory as a new project. Projects are then listed inside a
    `projects.json` file.

  - ![](../../figures/s-positron_setup-vs_project_manager.png)

  - Automatically detect directories with a `.git/` folder as projects.
    Click on the ***Project Manager tab*** and navigate down to the
    ***Git*** panel. Click ***Open Settings*** to add all the base
    folders where Git projects can be found. For example, my projects
    are found inside `C:\Users\Erika\OneDrive\Desktop\git_repos` so I
    add `C:\Users\Erika\OneDrive\Desktop\git_repos` as a file path by
    clicking ***Add Item***.

  - ![](../../figures/s-positron_setup-vs_project_manager_git_base_folder.png)

## Switching between R and Python

Positron is more versatile than RStudio for switching between R and
Python programming. There are three different use cases for programmers
who code in R and Python:

1.  The majority of your code is in R but you want to use a specific
    Python package for a task like machine learning.  
2.  You have a single project that runs both R and Python scripts. I
    recommend avoiding this use case unless you are desperate.  
3.  You frequently switch between projects that only require R or
    Python.

**RStudio** supports the first use case best. We can use `reticulate` to
easily switch between Python and R code and objects within a `.Rmd` or
`.qmd` notebook through the [`reticulate` Python
engine](https://rstudio.github.io/reticulate/articles/r_markdown.html).

Instead of relying on existing Python environments, the `reticulate`
package can embed a temporary Python session with all required packages
within an R session through
[`py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html).
This is the recommended practice for executing Python code within an R
session.

``` r
# Set up a temporary Python session in your current R session ------------------
library(reticulate)

# py_require() uses the excellent Python version/environment/package manager uv
# to create temporary Python sessions.    
py_require(c(numpy,
             pandas,
             sklearn))
```

**Positron** also supports the third use case, which makes it more
appealing to R users who frequently program in other languages.

In Positron, I can easily work on standalone Python projects by:

- Creating a new Python project by navigating to ***File*** \> ***New
  Folder From Template***. This option lets me create a new
  project-specific Python environment using Python environment managers
  like `uv`, `venv` or `conda`.

  ![](../../figures/s-positron_setup-new_python_project.png)

- Simply switching to a Python interpreter inside Positron. You can
  switch interpreters by clicking on your current interpreter in the top
  right corner of the Positron IDE and then selecting a new one.

  ![](../../figures/s-positron_setup-select_python_interpreter.png)

- Coding and rendering Python code in Quarto notebooks. This requires
  installing the Python package `Jupyter` and enabling ***Render on
  Save***. You can choose to view the rendered markdown document in the
  ***Viewer*** pane inside Positron.

  ![](../../figures/s-positron_setup-quarto_notebooks_for_python.png)

**Note:** Python version and environment management is notoriously
finicky. For first-time Python users, I recommend first installing and
using [`uv`](https://github.com/astral-sh/uv) to install a moderately
new version Python.

# Other resources

- A guide on how to [use Docker-based R from
  Positron](https://www.andrewheiss.com/blog/2024/07/08/fun-with-positron/)
  by Andrew Wheiss  
- A review of using [Positron versus
  RStudio](https://www.andrewheiss.com/blog/2024/07/08/fun-with-positron/)
  by Andrew Wheiss  
- The excellent [overview of Python data science
  tools](https://www.emilyriederer.com/post/py-rgo-2025/) by Emily
  Riederer
