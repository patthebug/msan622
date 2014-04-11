library(shiny)
library(ggplot2)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("State Data Set"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    checkboxGroupInput("regions", "Region:",
                       c("Northeast" = "Northeast",
                         "South" = "South",
                         "North Central" = "North Central",
                         "West" = "West"
                        )
                      ),
    br(),
    selectInput("colScheme","Color Scheme:",
                c( "Default", "Accent", "Set1", "Set2", "Set3", "Dark2", "Pastel1", "Pastel2"),
                selected='Set1'
                ),
    br(),
    sliderInput("dotAlpha", "Dot Alpha:",0.1,1.0,0.8,step=0.1)
#     sliderInput("zoomPopulation", "Population:",0,23000,c(0,23000))
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    tabsetPanel(
    tabPanel("Bubble Plot",plotOutput("distPlot1")),
    tabPanel("ScattterPlot Matrix",plotOutput("distPlot2")),
    tabPanel("Parallel Co-ordinates Plot",plotOutput("distPlot3"))
    )
  )
))