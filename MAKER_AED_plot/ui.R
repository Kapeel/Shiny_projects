#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudioinstal.com/
#

library(shiny)
library(DT)
library(ggplot2)
library(Cairo)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("AED stuff"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose txt file",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv")
      ),
      tags$hr(),
      checkboxInput("header", "Header", TRUE),
      sliderInput("slider1","AED Range:",
                  min = 0.0,max = 1.0,value=c(0.0,1.0))
      #submitButton(text="Apply changes")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      #tabsetPanel(
      # tabPanel("plot",
      #          plotOutput("distPlot")),
      # tabPanel("table",
      #          dataTableOutput("dtable"))
      #)
      plotOutput("distPlot",
                 click = "plot_click",
                 dblclick = "plot_dblclick",
                 hover = "plot_hover",
                 brush = "plot_brush"
      ),

    
    fluidRow(
      column(width = 6,
             h4("Points near click"),
             verbatimTextOutput("click_info")
      ),
      column(width = 6,
             h4("Brushed points"),
             verbatimTextOutput("brush_info")
      )
    ),
    verbatimTextOutput("info"),
      dataTableOutput("dtable")
    )
  )
))
