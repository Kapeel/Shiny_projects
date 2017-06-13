# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)
ui <- fluidPage(
                titlePanel("BC Liquor Store prices"),
                sidebarLayout(
                        sidebarPanel(sliderInput("priceInput", "Price", min = 0, max = 100,
                                                 value = c(25, 40), pre = "$"),
                                     uiOutput("productOutput"),
                                     uiOutput("subtypeOutput"),
                                     uiOutput("countryOutput")
                        ),
                        mainPanel(
                          plotOutput("coolplot"),
                          br(), br(),
                          h2(textOutput("cooltext")),
                          br(), br(),
                          tableOutput("results")
                          
                          )
                  )
                )
server <- function(input, output) {
  filtered <- reactive({
    if (is.null(input$countryInput)) {
      return(NULL)
    } 
    bcl %>%
      filter(Price >= input$priceInput[1],
             Price <= input$priceInput[2],
             Type == input$typeInput,
             Country == input$countryInput
      )
  })
  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
      ggplot(filtered(), aes(Alcohol_Content)) +
      geom_histogram()
  })
  output$results <- renderTable({
    filtered()
  })
  output$cooltext <- renderText({"Hello"})
  output$countryOutput <- renderUI({
    selectInput("countryInput", "Country",
                sort(unique(bcl$Country)),
                selected = "CANADA")
  })
  output$productOutput <- renderUI({
    selectInput("typeInput", "Product type",
                sort(unique(bcl$Type)),
                selected = "BEER")
  })
  output$subtypeOutput <- renderUI({
    selectInput("subtypeInput", "Product sub type",
                sort(unique(bcl$Subtype))
                
          )
  })
  
}
shinyApp(ui = ui, server = server)
