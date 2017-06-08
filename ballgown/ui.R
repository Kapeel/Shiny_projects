#!/bin/R
#install.packages("shinythemes")
#install.packages("DT")
library(DT)
library(shinythemes)
shinyUI(fluidPage(
  theme = shinytheme("sandstone"),
  #shinythemes::themeSelector(),
  titlePanel("Ballgown differential expression analysis"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("ballgown_dir", label = "Full path to your Ballgown directory", value = ""),
      #textInput("design_mtx", label = "Full path to your design matrix file", value = ""),
      fileInput('design_mtx', 'Upload desgin matrix file (csv/txt format)',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      textInput("covariate", label = "Name of the covariate of interest for the differential expression tests;correspond column name of design matrix file", value = ""),
      selectInput("featureInput", "Genomic feature",
                  choices = c("gene", "transcript", "exon", "intron")),
      selectInput("measInput", "Expression measurement",
                  choices = c("FPKM", "cov", "rcount", "ucount", "mrcount", "mcov")),
      #uiOutput("covOutput"),
      submitButton("Submit")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Summary",
          h4("Summary of expression data"),
          DT::dataTableOutput('phenoContent'),
          downloadButton('downloadSummary', 'Download Table'),
          br(), br(),
          DT::dataTableOutput('transContent'),
          downloadButton('downloadTrans', 'Download Table')
        ),
        tabPanel("Diffrential expression result",
          h4("Differential expression results"),
          DT::dataTableOutput('contents'),
          downloadButton('downloadDiffResults', 'Download Table')
        ),
        tabPanel("Plot",
                 fluidRow(
                   column(12,
                          p(h3('gene view'),
                            'abundances of transcript mapping to a given gene,',
                            'Visualization of the assembled transcripts',
                            'This plot colors transcripts by expression level')
                   ),
                   offset = 1),
                 
                 textInput('gv_var_input', label = 'gene: ', value = ''),
                 textInput('gv_var_sample', label = 'samples: ', value = ''),
                 plotOutput('plot1'),
                 downloadButton('downloadPlot1', 'Download gene view plot'),
                 fluidRow(
                   column(12,
                          p(h3('gene view between experiment covariates'),
                            'abundances of transcript mapping to a given gene,',
                            'Visualization of the assembled transcripts across experimental covariates.',
                            'This plot colors transcripts by expression level')
                   ),
                   offset = 1),
                 plotOutput('plot2'),
                 downloadButton('downloadPlot2', 'Download experiment view plot')
        )
      )
      
      #br(), br(),
      #DT::dataTableOutput('contents')
      #tableOutput('contents')
    )
    
  )))
