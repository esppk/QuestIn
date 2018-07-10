library(shiny)
library(shinydashboard)
library(shinyjs)
# Define UI for application that draws a histogram


body <- dashboardBody(
    useShinyjs(),
    tabItems(
        
        tabItem(tabName = "checkin",
                h2("Let's check by answering a question", class = "center h2"),
                div(id = "cards",
                    div(id = "innercards",
                        fluidRow(
                            # A static valueBox
                            valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
                            valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
                            valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
                            valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
                            valueBoxOutput("progressBox")
                        ) 
                    )
                ),
                hidden(
                    div(id = "questbox",
                        box(
                            title = "Inputs", status = "warning", solidHeader = TRUE,
                            "Box content here", br(), "More box content",
                            sliderInput("slider", "Slider input:", 1, 100, 50),
                            textInput("text", "Text input:")
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
    
    onclick("cards", hide("cards"))
    onclick("innercards", show("questbox"))
 
}

# Run the application 
shinyApp(ui = ui, server = server)

