library(shiny)
library(shinydashboard)
library(shinyjs)
library(mongolite)
library(jsonlite)
# Define UI for application that draws a histogram


body <- dashboardBody(
    useShinyjs(),
    tabItems(
        tabItem(tabName = "checkin",
                h2("Let's check by answering a question", class = "center h2"),
                
                div(id = "cards",
                    div(id = "innercards",
                        fluidRow(
                            # A dynamic valueBox
                            lapply(1:10, function(i) {
                                div(id = paste0("stud",i),
                                    valueBoxOutput(paste0("stu",i))  
                                )
                            })
                        ) 
                    )
                ),
                hidden(
                    div(id = "questbox",
                        box(
                            title = "Here's your question...", status = "warning", 
                            
                            solidHeader = TRUE,
                            tags$em(textOutput("idreminder")),
                            tags$strong(textOutput("questbody")), 
                            br(), 
                            textInput("text", "Text input:"),
                            uiOutput("questopts"),
                            actionButton("ckbtn", "Check In")
                        )
                    )
                )
        )
    )
)



ui <- dashboardPage(
    dashboardHeader(title = "Quest In"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Check In", tabName = "checkin", 
                     icon = icon("dashboard")),
            menuItem("leaderboard", icon = icon("th"), 
                     tabName = "leaderboard", 
                     badgeColor = "red", badgeLabel = "HOT")
        )
    ),
    body
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    #setup database
    options(mongodb = list(
        "host" = "ds018168.mlab.com:18168",
        "username" = "questin",
        "password" = "asd123"
    ))
    databaseName <- "jellylab"
    collectionName <- "questinfo"
    
    saveData <- function(data) {
        # Connect to the database
        db <- mongo(collection = collectionName,
                    url = sprintf(
                        "mongodb://%s:%s@%s/%s",
                        options()$mongodb$username,
                        options()$mongodb$password,
                        options()$mongodb$host,
                        databaseName))
        # Insert the data into the mongo collection as a data.frame
        data <- as.data.frame(data)
        db$replace('{"stuId": 5}', '{"$set": {"check": TRUE }}')
    }
    loadData <- function() {
        # Connect to the database
        db <- mongo(collection = collectionName,
                    url = sprintf(
                        "mongodb://%s:%s@%s/%s",
                        options()$mongodb$username,
                        options()$mongodb$password,
                        options()$mongodb$host,
                        databaseName))
        # Read all the entries
        data <- db$find()
        data
    }
    
    #load userinfo
    stuinfo <- loadData()
    
    current_user <- "UNKOWN"
    num <- 10
    
    #render stu checkin cards
    lapply(1:num, function(i){
        if (!stuinfo[i, 3]){
            output[[paste0("stu", i)]] <- renderValueBox({
                valueBox(
                    i, "Check In", icon = icon("thumbs-up", lib = "glyphicon"),
                    color = "green"
                )
            })
        }
    })
    
    lapply(1:num, function(i){
        onclick(paste0("stu", i), function() current_user <<- i)
    })
    
    
    
    #React to hide the cards and show question
    onclick("cards", {
        hide("cards",animType = "slide")
        show("questbox",animType = "slide")})
    
    
    questions <- read.csv("https://raw.githubusercontent.com/esppk/aitaquestions/master/day1.csv", stringsAsFactors = FALSE)
    output$questbody <- renderText(questions$question[1])
    output$test <- renderText(current_user)
    
    
    output$idreminder <- renderText(paste0("You're checking in as ",current_user))
    output$questopts <- renderUI({
        opts <- questions[1,3:6]
        checkboxGroupInput("qoptions", "Choose Correct ones", opts)
    })
    
    
    
    observeEvent(input$ckbtn, {
        showModal(modalDialog(
            title = "Success",
            "You have successfully check in",
            
            easyClose = TRUE
        ))
        
        stuinfo[current_user, 3] <<- TRUE
        hide("questbox",animType = "slide")
        show("cards",animType = "slide")
        
        saveData(stuinfo)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

