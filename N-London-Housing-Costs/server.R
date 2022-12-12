library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(DT)
library(ggplot2)
library(caret)
library(maps)
library(leaflet)
library(plotly)
library(corrplot)
library(stargazer)

shinyServer(function(input, output, session) {

  # Read in & clean data
  data <- read_csv("N13PropertyData.csv")
    data$Type <- as.factor(data$Type)
    data$'New-build' <- as.factor(data$'New-build')
    data$Tenure <- as.factor(data$Tenure)
    data$Bedrooms <- as.factor(data$Bedrooms)
    data$Date <- as.Date(data$Date, format="%m/%d/%Y")
    data$Lat <- round(data$Lat, digits = 4)
    data$Lng <- round(data$Lng, digits = 4)
  
  data <- data %>%
    rename("New_Build" = 'New-build', "Price_Paid" = 'Price paid', "Latitude" = Lat, "Longitude" = Lng)
  
  # Set up price groupings
  data$Price_Grouping <-
    ifelse(data$Price_Paid >= 1125000, "£1,125,000 or more",
           ifelse(data$Price_Paid >= 750000, "£750,000-£1,124,999",
                  ifelse(data$Price_Paid >= 375000, "£375,000-£749,999", "Less than £375,000")))
  
  # Create a datatable
  output$table <- renderDataTable({
    if (input$grouping) {
    data %>% 
      filter(Price_Grouping == input$prices) %>% 
      select(input$variables)
    } else {
      data %>% 
        select(input$variables)
    }
  })
  
  # Download data
  output$download_data <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(data, file)
    })
  
  
  # Create plots
  output$plots <- renderPlot({
    if (input$plot_var == "Price_Paid") {
      ggplot(data, aes(x = Price_Paid)) + 
        geom_histogram(binwidth = input$bins, fill = "#b2abd2") + 
        labs(title = "Histogram of Price Paid for Homes", x = "Price Paid (in GBP)", y = "Count")
    } else if (input$plot_var == "Type") {
      ggplot(data, aes(x = Type, y = Price_Paid)) + 
        geom_boxplot(fill = "#b2abd2") + 
        labs(title = "Boxplot of Price Paid by Type", y = "Price Paid (in GBP)")
    } else if (input$plot_var == "Tenure") {
      ggplot(data, aes(x = Tenure, y = Price_Paid)) + 
        geom_boxplot(fill = "#b2abd2") + 
        labs(title = "Boxplot of Price Paid by Tenure", y = "Price Paid (in GBP)")
    } else if (input$plot_var == "Bedrooms") {
      ggplot(data, aes(x = Bedrooms, y = Price_Paid)) + 
        geom_boxplot(fill = "#b2abd2") + 
        labs(title = "Boxplot of Price Paid by Bedrooms", y = "Price Paid (in GBP)")
    } else if (input$plot_var == "Date") {
      ggplot(data, aes(x = Date, y = Price_Paid)) + 
        geom_point() +
        geom_smooth(method = lm, col = "#e08214") +
        labs(title = "Plot of Price Paid by Over Time", y = "Price Paid (in GBP)")
    } else {
      ggplot(data, aes(x = Longitude, y = Latitude)) + 
        geom_point(aes(col = Price_Grouping), size = 1.3) + 
        labs(title = "Price Paid by Location Within N13 Postcode", x = "Longitude", y = "Latitude") + 
        scale_color_brewer(palette = "PuOr")
    }
  })

  output$summaries <- renderDataTable({
    if (input$plot_var == "Price_Paid") {
      data %>%
        select(Date, Address, Postcode, Type, Tenure, Bedrooms, Price_Paid)
    } else if (input$plot_var == "Type") {
      data %>%
        group_by(Type) %>%
        summarise(Mean = round(mean(Price_Paid), digits = 0), Min = min(Price_Paid), Q1 = quantile(Price_Paid, probs = 0.25), Median = median(Price_Paid), Q3 = quantile(Price_Paid, probs = 0.75), Max = max(Price_Paid))
    } else if (input$plot_var == "Tenure") {
      data %>%
        group_by(Tenure) %>%
        summarise(Mean = round(mean(Price_Paid), digits = 0), Min = min(Price_Paid), Q1 = quantile(Price_Paid, probs = 0.25), Median = median(Price_Paid), Q3 = quantile(Price_Paid, probs = 0.75), Max = max(Price_Paid))
    } else if (input$plot_var == "Bedrooms") {
      data %>%
        group_by(Bedrooms) %>%
        summarise(Mean = round(mean(Price_Paid), digits = 0), Min = min(Price_Paid), Q1 = quantile(Price_Paid, probs = 0.25), Median = median(Price_Paid), Q3 = quantile(Price_Paid, probs = 0.75), Max = max(Price_Paid))
    } else if (input$plot_var == "Date") {
      data %>%
        select(Date, Price_Paid)
    } else {
      data %>%
        select(Latitude, Longitude, Price_Grouping)
    }
  })
  

  # Split data into training and test set
  input_dataset_model <- reactive({
    if (is.null(input$expl_vars)) {
      dt <- data[, c("Type", "Tenure", "Bedrooms", "Price_Paid")]
    }
    else{
      dt <- data[, c("Price_Paid", input$expl_vars)]
    }
  })
  
  
  split_slider <- reactive({
    input$train_pct / 100
  })
  
  set.seed(100)
  training_split <-
    reactive({
      sample(1:nrow(input_dataset_model()),
             split_slider() * nrow(input_dataset_model()))
    })
  
  training_data <- reactive({
    tmptraindt <- input_dataset_model()
    tmptraindt[training_split(), ]
  })
  
  test_data <- reactive({
    tmptestdt <- input_dataset_model()
    tmptestdt[-training_split(),]
  })
  
  output$cntTrain <-
    renderText(paste("Training data:", NROW(training_data()), "records"))
  output$cntTest <-
    renderText(paste("Testing data:", NROW(test_data()), "records"))
  
  
  

  f <- reactive({
    as.formula(paste("Price_Paid", "~."))
  })
  
  
  linear_model <- reactive({
    lm(f(), data = training_data())
  })
  
  output$model <- renderPrint(summary(linear_model()))
  
  
  lm_predict <- eventReactive(input$predict_lm, {
    lm <- linear_model()
    test <- test_data()
    pred <- predict(lm, test)
    rmse <- postResample(pred, obs = test$Price_Paid)
    return(rmse)
    })
  
  output$lm_pred = renderPrint(lm_predict())
  
 ##############################################################################
  
  randfor_predict <- reactive({
  
  rf_model <- train(Price_Paid ~ Type + Tenure + Bedrooms, 
                    data = training_data(), 
                    method = "rf", 
                    preProcess = c("center", "scale"), 
                    trControl = control, 
                    tuneGrid = expand.grid(mtry = 1:2))

  predict(rf_model, newdata = test_data())
 
  })
  
  output$rf_pred = renderUI(randfor_predict())  
  
  
})
