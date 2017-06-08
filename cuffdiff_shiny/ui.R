library(shiny)

# Define UI 
shinyUI(pageWithSidebar(
  
  # Application title
	headerPanel("Human Body Map"),
  
	sidebarPanel(
		textInput("gene", label="Gene", value = ""),
		submitButton("Submit"),

		conditionalPanel(condition="input.gene.length > 0",
			br(),
			selectInput("tissue", "Select a tissue to view isoform expression in:",
				list("adipose" = "adipose", 
					"adrenal" = "adrenal", 
					"brain" = "brain",
					"breast" = "breast",
					"colon" = "colon",
					"heart" = "heart",
					"kidney" = "kidney",
					"liver" = "liver",
					"lung" = "lung",
					"lymph" = "lymph",
					"lymphocyte" = "lymphocyte",
					"muscle" = "muscle",
					"ovary" = "ovary",
					"prostate" = "prostate",
					"testes" = "testes",
					"thyroid" = "thyroid")
			)
		)
	),

	mainPanel(
		conditionalPanel(condition="$('html').hasClass('shiny-busy')",img(src="http://i1215.photobucket.com/albums/cc508/nawel12/loading.gif")),
		plotOutput("genePlot"),
		plotOutput("isoformPlot"),
		plotOutput("tissueIsoformPlot")
	)

))

