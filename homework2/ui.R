library(shiny)
library(ggplot2)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("IMDB Movie Ratings"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    radioButtons(
        'radio', 'MPAA Rating:',
        c("All"="All","NC-17"="NC-17","PG"="PG","PG-13"="PG-13","R"="R")
              ),   
    checkboxGroupInput("movieGenres", "Movie Genres:",
                       c("Action" = "Action",
                         "Animation" = "Animation",
                         "Comedy" = "Comedy",
                         "Drama" = "Drama",
                         "Documentary" = "Documentary",
                         "Romance" = "Romance",
                         "Short" = "Short",
                         "Mixed" = "Mixed",
                         "None" = "None"
                        ),
                       selected = "All"
                      ),
    selectInput("colScheme","Color Scheme:",
                c( "Default", "Accent", "Set1", "Set2", "Set3", "Dark2", "Pastel1", "Pastel2"),
                selected='Set1'
                ),
    sliderInput("dotSize", "Dot Size:",1,10,3),
    sliderInput("dotAlpha", "Dot Alpha:",0.1,1.0,0.8,step=0.1)
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot")
  )
))