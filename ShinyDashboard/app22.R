
library(shiny)
library(shinydashboard)

source("./header.R")

ui <- dashboardPage(
  #dashboardHeader(),
  header,
  dashboardSidebar(),
  dashboardBody()
)

server <- function(input, output) { }

shinyApp(ui, server)