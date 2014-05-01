library(shiny)
library(ggplot2)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Whining about wines"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(width=3,
    selectInput(
      'wineType','Wine Type:',c('Red'='Red',
                                'White'='White',
                                'Both'='Both'),
      selected='Red'
      ),
    checkboxGroupInput("wineQuality", "Select wine quality:",
                       c("3" = "3",
                         "4" = "4",
                         "5" = "5",
                         "6" = "6",
                         "7" = "7",
                         "8" = "8"),
                       selected="All"),
    selectInput(
        "xaxis","Select X axis variable",
        c(
          "fixed.acidity" = "fixed.acidity",
          "volatile.acidity" = "volatile.acidity",
          "citric.acid" = "citric.acid",
          "residual.sugar" = "residual.sugar",
          "chlorides" = "chlorides",
          "free.sulfur.dioxide" = "free.sulfur.dioxide",
          "total.sulfur.dioxide" = "total.sulfur.dioxide",
          "density" = "density",
          "pH" = "pH",
          "sulphates" ="sulphates",
          "alcohol" = "alcohol"
          ),
        selected = "chlorides"
      ),
    br(),
    selectInput(
      "yaxis","Select Y axis variable",
      c(
        "fixed.acidity" = "fixed.acidity",
        "volatile.acidity" = "volatile.acidity",
        "citric.acid" = "citric.acid",
        "residual.sugar" = "residual.sugar",
        "chlorides" = "chlorides",
        "free.sulfur.dioxide" = "free.sulfur.dioxide",
        "total.sulfur.dioxide" = "total.sulfur.dioxide",
        "density" = "density",
        "pH" = "pH",
        "sulphates" ="sulphates",
        "alcohol" = "alcohol"
      ),
      selected = "pH"
    ),
    selectInput(
      "bubbleSize","Select variable for bubble size:",
      c(
        "fixed.acidity" = "fixed.acidity",
        "volatile.acidity" = "volatile.acidity",
        "citric.acid" = "citric.acid",
        "residual.sugar" = "residual.sugar",
        "chlorides" = "chlorides",
        "free.sulfur.dioxide" = "free.sulfur.dioxide",
        "total.sulfur.dioxide" = "total.sulfur.dioxide",
        "density" = "density",
        "pH" = "pH",
        "sulphates" ="sulphates",
        "alcohol" = "alcohol"
      ),
      selected = "total.sulfur.dioxide"
    ),
    br(),
    selectInput("colScheme","Color Scheme:",
                c( "Default", "Accent", "Set1", "Set2", "Set3", "Dark2", "Pastel1", "Pastel2"),
                selected='Set1'
    ),
    br(),
    sliderInput("dotAlpha", "Dot Alpha:",0.1,1.0,0.8,step=0.1)
  ),
  
  # Show a plot of the generated distribution
  mainPanel(width=9,
    tabsetPanel(
      tabPanel("Bubble Plot",plotOutput("distPlot1"))
#       tabPanel("ScattterPlot Matrix",plotOutput("distPlot2")),
#       tabPanel("Parallel Co-ordinates Plot",plotOutput("distPlot3"))
    )
  )
))