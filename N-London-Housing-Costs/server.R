library(shiny)
library(shinydashboard)
library(DT)
library(readr)

shinyServer(function(input, output, session) {
  
  data <- read_csv("/Users/rachelhencher/Downloads/PropertyData_prices_sold_prices_2022-12-09.csv")
  
  output$table <- renderDT({
    data
  })
  
  
})
