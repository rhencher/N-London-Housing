library(shiny)
library(shinydashboard)
library(DT)
library(maps)
library(dplyr)
library(leaflet)
library(shinycssloaders)
library(shinythemes)
library(rio)
library(stargazer)

### 'About' page ###############################################################

about_info <- box(HTML("<p>This data comes from propertydata.co.uk and explores the housing market for the N13 postcode of London, UK. I was a resident in this postcode for four years and was never able to break into the housing market, so this data is of personal interest. The data spans five years and includes information on 836 homes sold in this postcode during this time.</p>"), width = 12)

# Set up dashboard components
about_tab <- tabItem("about", fluidRow(about_info))


### 'Data' page ################################################################
                   
# Variable selection for datatable
variable_choices <- box(checkboxGroupInput("variables", 
                                           h3("Select the variable(s) to display:"), 
                                           choices = c("Date", 
                                                       "Address", 
                                                       "Postcode", 
                                                       "Type", 
                                                       "New_Build", 
                                                       "Tenure", 
                                                       "Bedrooms", 
                                                       "Latitude", 
                                                       "Longitude", 
                                                       "Price_Paid"), 
                                           selected = c("Date", 
                                                        "Postcode", 
                                                        "Type", 
                                                        "Bedrooms", 
                                                        "Price_Paid")), 
                        width = 3)

grouping_choice <- box(checkboxInput("grouping", 
                                     h4(strong("Subset the data by price group?"))), 
                       conditionalPanel("input.grouping", 
                                        selectInput("prices", 
                                                    h4("Price grouping:"), 
                                                    choices = c("£1,125,000 or more", 
                                                                "£750,000-£1,124,999", 
                                                                "£375,000-£749,999", 
                                                                "Less than £375,000"))), 
                       width = 3)

download_button <- box(downloadButton("download_data", "Download Data"), width = 2)

# Create a datatable
data_table <- box(dataTableOutput("table"), 
                  width = 12)

# Set up dashboard components
data_tab <- tabItem("data", fluidRow(variable_choices, grouping_choice, download_button, data_table))


### 'Data Exploration' page ####################################################
plot_generator <-  box(selectInput("plot_var", 
                                    h3("Select variable for data exploration:"), 
                                    choices = c("Type", 
                                                "Tenure", 
                                                "Bedrooms", 
                                                "Price_Paid", 
                                                "Location", 
                                                "Date"), 
                                    selected = "Price_Paid"), 
                       conditionalPanel("input.plot_var == 'Price_Paid'", 
                                        sliderInput("bins", 
                                                    h5("Binwidth:"), 
                                                    min = 25000, 
                                                    max = 500000, 
                                                    value = 125000, 
                                                    step = 25000)))

# Graph
graph <- box(plotOutput("plots"), 
             dataTableOutput("summaries"), 
             width = 8)

# Set up dashboard components
exploration_tab <- tabItem("exploration", fluidRow(plot_generator, graph))


### 'Modeling' page ############################################################
modeling_intro <- box(HTML("<p>Below you will find three fitted supervised learning models: a multiple linear regression model, a regression tree, and a random forest model.</p>"), width = 12)

tabs <- tabBox(
  id = "tabset1",
  height = "1000px",
  width = 12,
  tabPanel("Modeling Info",
           box(HTML("<p>Linear regression models make sense to explore in this scenario because they describe relationships between predictor and response variables, which is precisely what our goal is. In linear regression, we generate a model where we fit betas, our intercept and slope(s), by minimizing the sum of the squared residuals. However, in situations such as this where there are many predictors, we do not typically include all predictors in the model in order to prevent overfitting.<p>"), 
               title = h4("Multiple Linear Regression")),
           box(HTML("<p>A boosted tree model can look at variable importance measures and make predictions, but loses interpretability. A boosted tree model involves the slow training of trees. We begin by initializing predictions as 0, then find the residuals, fit a tree with d splits, update the predictors, and finally update the residuals and repeat.<p>"), 
               title = h4("Boosted Tree Models")),
           box(HTML("<p>Random forest models can only be used for prediction. Like a bagged tree model, we first create bootstrap sample, then train tree on this sample, repeat, and either average or use majority vote for final prediction depending on whether our predictors are continuous or categorical respectively. However, random forest models extends the idea of bagging and is usually better, but instead of including every predictor in each one of our trees, we only include a random subset of predictors. In a random forest model, we include p/3 predictors since our data is continuous.<p>"), 
               title = h4("Random Forest Models"))
           ),
  
  tabPanel("Model Fitting", 
           box(sliderInput("train_pct", 
                           h3("Train/test split %"), 
                           min = 0, 
                           max = 100, 
                           value = 75,
                           step = 1), 
               textOutput("cntTrain"), 
               textOutput("cntTest"),
               width = 3), 
           box(selectizeInput("expl_vars", 
                              h4("Choose one or more explanatory variables:"), 
                              choices = c("Type", "Tenure", "Bedrooms"),
                              multiple = TRUE),
               width = 3), 
           box(verbatimTextOutput("model"),
               actionButton("predict_lm", 
                            h4("Fit Stats")),
               conditionalPanel("input.predict_lm == 1",
                                verbatimTextOutput("lm_pred")),
               title = h4("Linear Regression Model Summary")),
           box(verbatimTextOutput("rfmodel"),
               actionButton("predict_rf", 
                            h4("Fit Stats")),
               conditionalPanel("input.predict_rf == 1",
                                verbatimTextOutput("rf_pred")),
               title = h4("Random Forest Model Summary")),
           box(verbatimTextOutput("btmodel"),
               actionButton("predict_bt", 
                            h4("Fit Stats")),
               conditionalPanel("input.predict_bt == 1",
                                verbatimTextOutput("bt_pred")),
               title = h4("Boosted Tree Model Summary"))
           ),
  
  tabPanel("Prediction")
  )


# Set up dashboard components
modeling_tab <- tabItem("modeling", fluidRow(modeling_intro, tabs))


### ??? ########################################################################

dashboardPage(
  skin = "purple",
  dashboardHeader(title = "N13 Housing Prices"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("info")),
      menuItem("Data", tabName = "data", icon = icon("sterling-sign")),
      menuItem("Data Exploration", tabName = "exploration", icon = icon("chart-line")),
      menuItem("Modeling", tabName = "modeling", icon = icon("house"))
    )
  ),
  dashboardBody(
    tabItems(
      about_tab, data_tab, exploration_tab, modeling_tab
    )
  )
)