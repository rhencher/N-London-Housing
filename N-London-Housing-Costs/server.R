library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(DT)
library(ggplot2)

shinyServer(function(input, output, session) {

  # Read in & clean data
  data <- read_csv("/Users/rachelhencher/Downloads/PropertyData_prices_sold_prices_2022-12-09.csv")
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
    data %>% filter(Price_Grouping == input$prices) %>% select(input$variables)
  })
  
  # Create plots
  output$plots <- renderPlot({
    if (input$plot_var == "Price_Paid") {
      ggplot(data, aes(x = Price_Paid)) + geom_histogram(binwidth = input$bins)
    } else {
      ggplot(data, aes(x = input$plot_var, y = Price_Paid)) + geom_boxplot()
    }
  })

  
  
})
