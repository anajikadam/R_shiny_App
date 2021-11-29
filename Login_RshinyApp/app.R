library(shiny)
library(shinydashboard)
library(shinyauthr)
library(dplyr)
library(shinyjs)
library(DT)

# sample logins dataframe with passwords hashed by sodium package


user_base <- read.csv("user_base.csv")

ui <- dashboardPage(
  
  # put the shinyauthr logout ui module in here
  dashboardHeader(
    title = "My Dashboard",
    tags$li(class = "dropdown", style = "padding: 8px;", 
            shinyauthr::logoutUI(id = "logout",
                                 label = "Log out",
                                 icon = NULL, 
                                 class = "btn-danger",
                                 style = "color: white;"))
  ),
  
  # setup a sidebar menu to be rendered server-side
  dashboardSidebar(
    collapsed = TRUE, sidebarMenuOutput("sidebar")
  ),
  
  dashboardBody(
    shinyjs::useShinyjs(),
    
    # put the shinyauthr login ui module here
    shinyauthr::loginUI("login",
                        title = "Please log in",
                        user_title = "User Name",
                        pass_title = "Password",
                        login_title = "Log in",
                        error_message = "Invalid username or password!",
                        additional_ui = NULL,
                        cookie_expiry = 1),
    
    # setup any tab pages you want after login here with uiOutputs
    tabItems(
      tabItem("tab1", uiOutput("tab1_ui")),
      tabItem("tab2", uiOutput("tab2_ui")),
      tabItem("Iris", uiOutput("Iris1")),
      tabItem("cars", uiOutput("cars")),
      tabItem("tab3", uiOutput("tab3_ui"))
    )
  )
)

server <- function(input, output, session) {
  
  # login status and info will be managed by shinyauthr module and stores here
  credentials <- shinyauthr::loginServer(id =  "login", 
                                         data = user_base,
                                         user_col = user,
                                         pwd_col = password,
                                         sodium_hashed = TRUE,
                                         log_out = reactive(logout_init()))
  
  # logout status managed by shinyauthr module and stored here
  logout_init <- shinyauthr::logoutServer(id = "logout", reactive(credentials()$user_auth))
  
  # this opens or closes the sidebar on login/logout
  observe({
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  # only when credentials()$user_auth is TRUE, render your desired sidebar menu
  output$sidebar <- renderMenu({
    req(credentials()$user_auth)
    sidebarMenu(
      id = "tabs",
      menuItem("Storms Data", tabName = "tab1"),
      menuItem("Starwars Data", tabName = "tab2"),
      menuItem("Iris", tabName = "Iris", icon = icon("tree")),
      menuItem("Cars", tabName = "cars", icon = icon("car")),
      menuItem(credentials()$info$user, tabName = "tab3")
    )
  })
  
  # tab 1 UI and output ----------------------------------------
  output$tab1_ui <- renderUI({
    req(credentials()$user_auth)
    DT::DTOutput("table1")
  })
  
  output$table1 <- DT::renderDT({
    DT::datatable(dplyr::storms, options = list(scrollX = TRUE))
  })
  
  # tab 2 UI and output ----------------------------------------
  output$tab2_ui <- renderUI({
    req(credentials()$user_auth)
    DT::DTOutput("table2")
  })
  
  output$table2 <- DT::renderDT({
    DT::datatable(dplyr::starwars[,1:10], options = list(scrollX = TRUE))
  })
  
  # tab 3 UI and output ----------------------------------------
  output$Iris1 <- renderUI({
    req(credentials()$user_auth)
    fluidPage(
      box(plotOutput("corr_plot"), width = 8),
      box(
      selectInput("features", "Features:",
                  c("Sepal.Width", "Petal.Length","Petal.Width"))
      , width = 4)
    )
  })
  output$corr_plot <- renderPlot({
    plot(iris$Sepal.Length, iris[[input$features]],
         xlab = "Sepal Length", ylab = "Feature")
  })
  
  # tab 4 UI and output ----------------------------------------
  output$cars <- renderUI({
    req(credentials()$user_auth)
    fluidPage(
      h1("Cars"),
      dataTableOutput("carstable")
    )
  })
  output$carstable <- renderDataTable(mtcars)
  
  
  # tab 3 UI and output ----------------------------------------
  output$tab3_ui <-  renderText({
    req(credentials()$info$user)
    print(credentials()$info$user)
  })
}


options(shiny.host = '0.0.0.0')
options(shiny.port = 8787)
shiny::shinyApp(ui, server)

