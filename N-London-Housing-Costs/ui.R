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

about_info <- box(HTML("<h1>About</h1>
                        <p>The data explored in the following pages comes from 
                        <a href='https://propertydata.co.uk'>the following website</a> 
                        and explores the housing market for the N13 postcode of 
                        London, UK. The site allows the user to search for 
                        information on properties sold from all over the UK and 
                        allows the user to set the search criteria. I opted to 
                        stick to the N13 postcode as I was a resident in this 
                        postcode for four years and was never able to break into 
                        the housing market, so this data is of personal interest. 
                        I also opted to extend the search over the previous five 
                        years and to include number of bedrooms for each property.
                        An image of the generated data can be seen below. The 
                        full dataset can be downloaded in the Data page.
                        <p style='text-align:center;'>
                        <img src='Capture.PNG' height='360' width='650'/>
                        </p>
                        The data includes information on 836 homes sold in this 
                        postcode during the specified timeframe. For each home 
                        sold, there is information on the date it was sold, the 
                        address, the postcode, the type of home, whether it was 
                        a new-build, the tenure, number of bedrooms, price paid, 
                        as well as the latitude and longitude of the home.
                       <br>
                       <h3>Data</h3>
                       On the following page, the full dataset can be viewed and 
                       downloaded. The user has the option to view all variables, 
                       or to select just those they are interested in. The user 
                       also has the ability to subset the data by selling price.
                       <br>
                       <h3>Data Exploration</h3>
                       On the Data Exploration page, plots can be generated to 
                       display price information for each explanatory variable.
                       A table with relevant information will also be generated 
                       for each option. For some, mean and five-number summaries 
                       detailing price paid for each level of the variable can be 
                       seen.
                       <br>
                       <h3>Modeling</h3>
                       On the Modeling page, three types of models are discussed 
                       and fitted to our data: a Multiple Linear Regression Model, 
                       Boosted Tree Model, and Random Forest Model.
                       </p>"), 
                  width = 12)

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
                        width = 4)

grouping_choice <- box(checkboxInput("grouping", 
                                     h3("Subset the data by price group")), 
                       conditionalPanel("input.grouping", 
                                        selectInput("prices", 
                                                    h4("Price grouping:"), 
                                                    choices = c("£1,125,000 or more", 
                                                                "£750,000-£1,124,999", 
                                                                "£375,000-£749,999", 
                                                                "Less than £375,000"))), 
                       width = 4)

download_button <- box(downloadButton("download_data", "Download Dataset"), width = 2)

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
tabs <- tabBox(
  id = "tabset1",
  height = "1000px",
  width = 12,
  tabPanel("Modeling Info",
  box(HTML("<p><h3>Multiple Linear Regression</h3>
  Linear regression models make sense to explore in this scenario because they describe relationships between predictor and response variables, which is precisely what our goal is. In linear regression, we generate a model where we fit betas, our intercept and slope(s), by minimizing the sum of the squared residuals. However, in situations such as this where there are many predictors, we do not typically include all predictors in the model in order to prevent overfitting.
  <br>
  <h3>Boosted Tree Models</h3>
  A boosted tree model can look at variable importance measures and make predictions, but loses interpretability. A boosted tree model involves the slow training of trees. We begin by initializing predictions as 0, then find the residuals, fit a tree with d splits, update the predictors, and finally update the residuals and repeat.
  <br>
  <h3>Random Forest Models</h3>
  Random forest models can only be used for prediction. Like a bagged tree model, we first create bootstrap sample, then train tree on this sample, repeat, and either average or use majority vote for final prediction depending on whether our predictors are continuous or categorical respectively. However, random forest models extends the idea of bagging and is usually better, but instead of including every predictor in each one of our trees, we only include a random subset of predictors. In a random forest model, we include p/3 predictors since our data is continuous.<p>"), 
      width = 12)
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
               width = 4), 
           box(selectizeInput("expl_vars", 
                              h3("Choose one or more explanatory variables:"), 
                              choices = c("Type", "Tenure", "Bedrooms"),
                              multiple = TRUE),
               width = 4), 
           box(checkboxInput("click", 
                         h3("Display models & summaries")), width = 4), 
           conditionalPanel("input.click",
                            box(verbatimTextOutput("model"),
                                actionButton("predict_lm", 
                                             h4("Click for Fit Stats")),
                                conditionalPanel("input.predict_lm == 1",
                                                 verbatimTextOutput("lm_pred")),
                                title = h4("Linear Regression Model Summary")),
                            box(sliderInput("cv1", 
                                            h5("Number of folds:"), 
                                            min = 1, 
                                            max = 10, 
                                            value = 5, 
                                            step = 1),
                                sliderInput("mtry", 
                                            h5("Mtry:"), 
                                            min = 1, 
                                            max = 3, 
                                            value = 1, 
                                            step = 1),
                                verbatimTextOutput("rfmodel"),
                                actionButton("predict_rf", 
                                             h4("Click for Fit Stats")),
                                conditionalPanel("input.predict_rf == 1",
                                                 verbatimTextOutput("rf_pred")),
                                title = h4("Random Forest Model Summary")),
                            box(sliderInput("cv2", 
                                            h5("Number of folds:"), 
                                            min = 1,
                                            max = 10,
                                            value = 5,
                                            step = 1),
                                verbatimTextOutput("btmodel"),
                                actionButton("predict_bt", 
                                             h4("Click for Fit Stats")),
                                conditionalPanel("input.predict_bt == 1",
                                                 verbatimTextOutput("bt_pred")),
                                title = h4("Boosted Tree Model Summary"))
                            )
           ),
  
  tabPanel("Prediction",
           box(numericInput("type", "Type:", min = 1, max = 4, value = 1),
               numericInput("tenure", "Tenure:", min = 1, max = 2, value = 1),
               numericInput("bedrooms", "Bedrooms:", min = 1, max = 6, value = 1),
               actionButton("prediction", "Predict"),
               verbatimTextOutput("pred"))
           )
  )

# Set up dashboard components
modeling_tab <- tabItem("modeling", fluidRow(tabs))

### Overall setup ##############################################################

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