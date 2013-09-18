library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  # Application title
  headerPanel("ANOVA model"),
  sidebarPanel(
    wellPanel(
      h3("Dependent variable"),
      checkboxInput("hasMin","Minimum"),
      conditionalPanel(
        condition = "input.hasMin",
        numericInput("minimum","",value=-100)
      ),
      checkboxInput("hasMax","Maximum"),
      conditionalPanel(
        condition = "input.hasMax",
        numericInput("maximum","",value=100)
      ),
      numericInput("digits","Decimals",value=8,min=0,max=8,step=1)
    ),
    wellPanel(
      h3("Independent variables"),
      numericInput("nFactor", "Number of factors:",value=2,min=1,max=10,step=1),
      uiOutput("factorLevels")
    )
  ),
  mainPanel(
    HTML("<p>"),
    downloadButton('downloadData', 'Download data'),
    HTML("</p>"),
    tabsetPanel(
      tabPanel("Parameters", uiOutput("parameters")), 
      tabPanel("Data", tableOutput("dataTable")), 
      tabPanel("Summary", verbatimTextOutput("summary")),
      tabPanel("Plot", plotOutput("plot"))
    )
  )
))
