# House prices in London's N13 postcode

This app provides information on home prices in the N13 postcode of London, UK over the past five years. Users can investigate a variety of variables in order to determine how they affect the price of homes in this area. Variables included in the dataset are `Date`, `Address`, `Postcode`, `Type`, `New_Build`, `Tenure`, `Bedrooms`, `Price_Paid`, `Latitude`, and `Longitude`.  The data comes from propertydata.co.uk and includes infromation on 836 properties.

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
