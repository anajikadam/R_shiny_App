library(shiny)
library(shinydashboard)
library(shinyauthr)
library(dplyr)
library(shinyjs)
library(DT)

source("./data.R")
Ins_df <- Insurances_df


ui <- dashboardPage(
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
    Ins_df
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
      box(
          selectInput("Insurances", "Insurances:",
                      Ins_df[,'Groupname'])
          , width = 6),
      box(
        selectInput("Insurances1", "Insurances11:",
                    Corporates_df[,'Groupname'])
        , width = 6),
      box(textOutput("capt1")),
      box(textOutput("capt2")),
      box(DT::DTOutput("table11")),
      #box(DT::DTOutput("table12")),
      #Policy_df<-GetPolicy(GetId1(input$Insurances1)),
    
      )
  })
  output$capt1 <- renderText({GetId(input$Insurances)})
  output$capt2 <- renderText({GetId1(input$Insurances1)})
  output$table11 <- DT::renderDT({
    GetCorporate(GetId(input$Insurances))
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
  
  
  # tab 5 UI and output ----------------------------------------
  output$tab3_ui <-  renderText({
    req(credentials()$info$user)
    print(credentials()$info$user)
  })
}


options(shiny.host = '0.0.0.0')
options(shiny.port = 8787)
shiny::shinyApp(ui, server)

