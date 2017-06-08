#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#source("http://bioconductor.org/biocLite.R")
#biocLite("ballgown")
#install.packages("DT")
#install.packages("downloader")
library(shiny)
library(ballgown)
library(genefilter)
library(DT)
library(downloader)
library(dplyr)
library(RCurl)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  saved_plots_and_tables <- reactiveValues(
    plot1 = NULL,
    plot2 = NULL
  )
  
  bg <- reactive({
    inFile <- input$design_mtx
  #  if(input$design_mtx==0)
     if(is.null(inFile))
      return(NULL)
    ctab_path <- input$ballgown_dir
  #  ctab_path
  #  browser()
    ctab_fdr <- basename(ctab_path)
    #ctab_fdr2 <- paste("/usr/local/apache2/htdocs/data/ballgown_shiny",ctab_fdr, sep= '/')
    download(input$ballgown_dir,ctab_fdr,mode = "wb")
    #download(input$ballgown_dir,ctab_fdr,mode = "wb")
    #file_url <- "http://brie.cshl.edu/data/test.zip"
    #download(file_url,"ctest.zip",mode = "wb")
    unzip(zipfile=ctab_fdr,exdir = "./")
    #unzip( zipfile="ctest.zip" , exdir = "./" )
    ctab_fdr_ucmp<-tools::file_path_sans_ext(ctab_fdr)
    pheno_data <- read.table(inFile$datapath, header = TRUE, sep = "\t")
    #sample_full_path <- paste(input$ballgown_dir,pheno_data[,1], sep = '/')
    #sample_full_path <- paste(ctab_fdr_ucmp,pheno_data[,1], sep = '/')
    sample_full_path <- paste(ctab_fdr_ucmp,pheno_data[,1], sep = '/')
    #sample_full_path <- paste("/usr/local/apache2/htdocs/data/ballgown_shiny",ctab_fdr_ucmp,pheno_data[,1], sep = '/')
    bg <- ballgown(samples=as.vector(sample_full_path),pData=pheno_data)
  })
  
  pheno_data <- reactive({
    inFile <- input$design_mtx
    #if(input$design_mtx==0)
    if(is.null(inFile))
      return(NULL)
    pheno_data <- read.table(inFile$datapath, header = TRUE, sep = "\t")
  })
 
 # output$covOutput <- renderUI({
  #  selectInput("covInput", "Covariate of interest",
  #              sort(unique(colnames(pheno_data()))),
  #              selected = "NA"
   #             )
 # }) 
  output$phenoContent <- DT::renderDataTable({
    pheno_data()
  })
  output$downloadSummary <- downloadHandler(
    filename = function() { "desgin_matrix.txt" },
    content = function(file) {
      write.table(pheno_data(), file)
    }
  )
  output$transContent <-  DT::renderDataTable({
    texpr(bg(), 'all')
  })
  output$downloadTrans <- downloadHandler(
    filename = function() { "Transcript_summary_table.txt" },
    content = function(file) {
      write.table(texpr(bg(), 'all'), file)
    }
  )
  output$contents <- DT::renderDataTable({
    results_genes = stattest(bg(), feature=input$featureInput, meas=input$measInput, covariate=input$covariate, getFC = TRUE)
  })
  output$downloadDiffResults <- downloadHandler(
    filename = function() { "Diff_expression_summary_table.txt" },
    content = function(file) {
      write.table(stattest(bg(), feature=input$featureInput, meas=input$measInput, covariate=input$covariate, getFC = TRUE), file)
    }
  )
  output$plot1 <- renderPlot({
#    fpkm=texpr(bg(),meas =input$measInput)
#    fpkm= log2(fpkm+1)
 #   #boxplot(fpkm,col=as.numeric(pheno_data()$group),las=2,ylab='log2')
#    cov_positon = match(input$covariate,colnames(pheno_data()))
#    boxplot(fpkm,col=as.numeric(pheno_data()[,cov_positon]),las=2,ylab=paste("log2", input$measInput,collapse = ", ") )
    all_sample_list <- c(strsplit(input$gv_var_sample, " ")[[1]])
  saved_plots_and_tables$plot1 <- plotTranscripts(gene=input$gv_var_input, gown=bg(), samples=all_sample_list, meas=input$measInput, colorby=input$featureInput, labelTranscripts= TRUE)
 # ggsave("gene_view_plot.png",saved_plots_and_tables$plot1)
  })
 
  output$downloadPlot1 <- downloadHandler(
    filename = function() {
      "gene_view_plot.png"
    },
    content = function(file) {
      ggsave(saved_plots_and_tables$plot1)
      #unlink(saved_plots_and_tables$plot1)
      #png(file)
      #print(saved_plots_and_tables$plot1)
      #dev.off
     # file.copy("gene_view_plot.png", file, overwrite=TRUE)
    })
  output$plot2 <- renderPlot({
    saved_plots_and_tables$plot2 <- plotMeans(input$gv_var_input, bg(), groupvar=input$covariate, meas=input$measInput, colorby=input$featureInput, labelTranscripts= TRUE)
    saved_plots_and_tables$plot2
  })
  
  output$downloadPlot2 <- downloadHandler(
    filename = function() {
      "gene_experiment_view_plot.png"
    },
    content = function(file) {
      ggsave(saved_plots_and_tables$plot2)
    })
  
  
})

