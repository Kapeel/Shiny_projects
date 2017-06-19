#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(ggplot2)
library(Cairo)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  output$distPlot = renderPlot({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df =read.table(inFile$datapath, header = input$header)
    aed_data = df$AED
    min = input$slider1[1]
    max = input$slider1[2]
    breaks = seq(min,max,by=0.05)
    aed_data.cut = cut(aed_data,breaks,right = FALSE)
    aed_data.freq = table(aed_data.cut)
    cumfreq0 = c(0,cumsum(aed_data.freq/(length(aed_data))))
    dfplot = data.frame(breaks,cumfreq0)
    plot(dfplot$breaks,dfplot$cumfreq0,main = "cumulative fraction of annotations vs AED",xlab = "AED",ylab = "cumulative fraction of annotations")
    lines(breaks,cumfreq0)
  })
  
  output$click_info <- renderPrint({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df =read.table(inFile$datapath, header = input$header)
    aed_data = df$AED
    min = input$slider1[1]
    max = input$slider1[2]
    breaks = seq(min,max,by=0.05)
    aed_data.cut = cut(aed_data,breaks,right = FALSE)
    aed_data.freq = table(aed_data.cut)
    cumfreq0 = c(0,cumsum(aed_data.freq/(length(aed_data))))
    dfplot = data.frame(breaks,cumfreq0)
    nearPoints(dfplot, input$plot_click, xvar = "breaks", yvar = "cumfreq0")
  })
  
  
  output$brush_info <- renderPrint({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df =read.table(inFile$datapath, header = input$header)
    aed_data = df$AED
    min = input$slider1[1]
    max = input$slider1[2]
    breaks = seq(min,max,by=0.05)
    aed_data.cut = cut(aed_data,breaks,right = FALSE)
    aed_data.freq = table(aed_data.cut)
    cumfreq0 = c(0,cumsum(aed_data.freq/(length(aed_data))))
    dfplot = data.frame(breaks,cumfreq0)
    brushedPoints(dfplot, input$plot_brush, xvar = "breaks", yvar = "cumfreq0")
  })
  
  output$info <- renderText({

    xy_str <- function(e) {
      if(is.null(e)) return("NULL\n")
      paste0("x=", round(e$x, 1), " y=", round(e$y, 1), "\n")
    }
    xy_range_str <- function(e) {
      if(is.null(e)) return("NULL\n")
      paste0("xmin=", round(e$xmin, 1), " xmax=", round(e$xmax, 1), 
             " ymin=", round(e$ymin, 1), " ymax=", round(e$ymax, 1))
    }
    
    paste0(
      "click: ", xy_str(input$plot_click),
      "dblclick: ", xy_str(input$plot_dblclick),
      "hover: ", xy_str(input$plot_hover),
      "brush: ", xy_range_str(input$plot_brush)
    )
  })
  
  
  output$dtable = renderDataTable({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df =read.table(inFile$datapath, header = input$header)
    datatable(df)
  })
  
})
