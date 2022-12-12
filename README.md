# House prices in London's N13 postcode

Brief description of the app and its purpose.

## Install relevant packages

The following packages needed to run the app:
```{r}
library(shiny)
library(shinydashboard)
library(DT)
library(dplyr)
library(rio)
library(stargazer)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(caret)
```

They can be installed using the following code:
```{r}
install.packages(c("shiny", "shinydashboard", "DT", "dplyr", "rio", "stargazer", "tidyverse", "lubridate", "ggplot2", "caret"))
```

## Run the app
```{r}
shiny::runGitHub(repo = "N-London-Housing", username = "rhencher", ref = "main", subdir = "N-London-Housing-Costs")
```
