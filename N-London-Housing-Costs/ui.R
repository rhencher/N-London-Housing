library(shiny)
library(shinydashboard)
library(DT)

# 'About' page
about_info = HTML("<p>This is a test.</p>")

about_tab = tabItem("about",fluidRow(box(about_info, width=8)))


# 'Data' page
data_table = box(DTOutput("table"), width=8)

data_tab = tabItem("data", fluidRow(data_table))


dashboardPage(
  skin="yellow",
  dashboardHeader(title="N13 Housing Prices"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName="about"),
      menuItem("Data", tabName="data"),
      menuItem("Data Exploration", tabName="exploration"),
      menuItem("Modeling", tabName="modeling")
    )
  ),
  dashboardBody(
    tabItems(
      about_tab, data_tab
    )
  )
)