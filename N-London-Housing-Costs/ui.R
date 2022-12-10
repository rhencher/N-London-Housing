library(shiny)
library(shinydashboard)
library(DT)

### 'About' page ###############################################################

about_info <- HTML("<p>This data comes from propertydata.co.uk and explores the housing market for the N13 postcode of London, UK. I was a resident in this postcode for four years and was never able to break into the housing market, so this data is of personal interest. The data spans five years and includes information on 836 homes sold in this postcode during this time.</p>")

# Set up dashboard components
about_tab <- tabItem("about", fluidRow(box(about_info, width = 8)))


### 'Data' page ################################################################
                   
# Variable selection for datatable
variable_choices <- box(checkboxGroupInput("variables", "Select the variable(s) to display: ", choices = c("Date", "Address", "Postcode", "Type", "New_Build", "Tenure", "Bedrooms", "Latitude", "Longitude", "Price_Paid"), selected = c("Date", "Postcode", "Type", "Bedrooms", "Price_Paid")), width = 2)

# Subsetting by price for datatable
price_choices <- box(selectInput("prices", "Subset the data by price grouping:", choices = c("£1,125,000 or more", "£750,000-£1,124,999", "£375,000-£749,999", "Less than £375,000")), width = 3)

# Create a datatable
data_table <- box(dataTableOutput("table"), width = 10)

# Set up dashboard components
data_tab <- tabItem("data", fluidRow(variable_choices, price_choices, data_table))


### 'Data Exploration' page ####################################################
a <-  box(selectizeInput("plot_var", "Select variable for data exploration:", choices = c("Type", "Tenure", "Bedrooms", "Price_Paid", "Location"), selected = "Price_Paid"), conditionalPanel("input.plot_var == 'Price_Paid'", sliderInput("bins", "Binwidth:", min = 25000, max = 500000, value = 125000, step = 25000)))

# Graph
graph <- box(plotOutput("plots"))

# Set up dashboard components
exploration_tab <- tabItem("exploration", fluidRow(a, graph))


### ??? ########################################################################

dashboardPage(
  skin = "purple",
  dashboardHeader(title = "N13 Housing Prices"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about"),
      menuItem("Data", tabName = "data"),
      menuItem("Data Exploration", tabName = "exploration"),
      menuItem("Modeling", tabName = "modeling"),
      menuItem("Prediction", tabName = "prediction")
    )
  ),
  dashboardBody(
    tabItems(
      about_tab, data_tab, exploration_tab
    )
  )
)