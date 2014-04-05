library(shiny)
library(ggplot2)
library(scales)

loadData <- function() {
  data(movies) 
  # filter out movies with budget 0 or lower
  movies<-movies[-which(movies$budget<=0),]
  movies<-movies[-which(is.na(movies$budget)),]
  movies<-movies[-which(movies$mpaa==''),]
  
  genre <- rep(NA, nrow(movies))
  count <- rowSums(movies[, 18:24])
  genre[which(count > 1)] = "Mixed"
  genre[which(count < 1)] = "None"
  genre[which(count == 1 & movies$Action == 1)] = "Action"
  genre[which(count == 1 & movies$Animation == 1)] = "Animation"
  genre[which(count == 1 & movies$Comedy == 1)] = "Comedy"
  genre[which(count == 1 & movies$Drama == 1)] = "Drama"
  genre[which(count == 1 & movies$Documentary == 1)] = "Documentary"
  genre[which(count == 1 & movies$Romance == 1)] = "Romance"
  genre[which(count == 1 & movies$Short == 1)] = "Short"
  movies$genre<-factor(genre)
#   movies<-movies[,!(names(movies) %in% c('Mixed','None'))]
  
  return(movies)
}

million_formatter<-function(x){
  return(sprintf("%dM",round(x/1000000)))
}

getPlot <- function(movies, rating, dotSize, dotAlpha, colScheme,radio, movieGenres) {
  if(radio=='All'){
    movies<-movies
  }
  else{
    movies<-movies[which(movies$mpaa == radio),]
  }
  if(length(movieGenres) < 1){
    movies<-movies
  }
  else{
    movies<-movies[movies$genre %in% movieGenres,]
  }  
  
  p<-ggplot(movies,aes(x=budget,y=rating,color=genre)) + 
    geom_point(size=dotSize,positionn='jitter', stat='identity',alpha=dotAlpha) + 
    xlab('Budget(in Dollars)') + ylab('IMDB Rating')  +
    labs(colour="Genre") + 
    theme(axis.text=element_text(size=14,face="bold"),
          plot.title = element_text(size = 25, face = "bold", colour = "black", vjust = 1)) +
    scale_x_continuous(label=million_formatter) + 
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
    scale_color_brewer(palette = colScheme) + theme(panel.grid.minor.x=element_blank(),
                                                    panel.grid.minor.y=element_blank()) +
    opts(legend.key = theme_blank()) + 
    theme(legend.position="bottom")
    
    
  print(p)
  return(p)
}

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  library(shiny)
  library(ggplot2)
  library(scales)
  
  movies<-loadData()
#   movies<-movies[which(movies$mpaa == input$radio),]
#     rating <- reactive(
#     {
#       movies<-movies[which(movies$mpaa == input$radio),]
#     }
#   )

  output$distPlot <- renderPlot({
#     p<-ggplot(movies,aes(x=budget,y=rating,color=genre)) + geom_point(size=input$dotSize, stat='identity',alpha=input$dotAlpha) + 
#       xlab('Budget') + ylab('Rating') + ggtitle('Movie Budget v/s Movie Rating') +
#       labs(colour="Genre") + theme(axis.text=element_text(size=14,face="bold"),
#                                    plot.title = element_text(size = 25, face = "bold", colour = "black", vjust = 1)) +
#       scale_x_continuous(label=million_formatter) + 
#       theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
#       scale_color_brewer(palette = input$colScheme)
    p<-getPlot(movies,rating,input$dotSize,input$dotAlpha,input$colScheme,input$radio,input$movieGenres)
    print(p)    
  })
})