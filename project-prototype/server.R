library(shiny)
library(ggplot2)
library(scales)
require(GGally)
library(reshape2)   
library(plyr)       
library(data.table)
library(RColorBrewer)
library(grid)
library(gridExtra)

loadWhite <- function() {
  white <- read.csv("C:\\Users\\Prateek\\Dropbox\\R_Projects\\Data_Visualization\\FinalProject\\winequality-white.csv",sep=";")
  white$quality <- as.factor(white$quality)
  return(white)
}

loadRed <- function() {
  red <- read.csv("C:\\Users\\Prateek\\Dropbox\\R_Projects\\Data_Visualization\\FinalProject\\winequality-red.csv",sep=";")
  red$quality <- as.factor(red$quality)
  return(red)
}

getBubblePlot <- function(white,red,xaxis,yaxis,
                          colScheme,dotAlpha,regions,
                          wineType,bubbleSize,wineQuality) {
  
#   if(wineQuality=='All'){
#     movies<-movies
#   }
#   else{
#     movies<-movies[which(movies$mpaa == radio),]
#   }  
#   print(wineQuality)
  if(wineType=='White'){
    if(length(wineQuality)<1){
      data <- white
    }
    else{
#       data<-white[which(white$quality %in% wineQuality),]      
    }
  }
  else if(wineType=='Red'){
    if(length(wineQuality)<1){
      data <- red
    }
    else{
#       data<-red[which(red$quality %in% wineQuality),]
    }
  }
  else{
    if(length(wineQuality)<1){
      data <- white
      red <- red
    }
    else{
#       data <- white[which(white$quality %in% wineQuality),]
#       red <- red[which(red$quality %in% wineQuality),]
    }
    # Create bubble plot
    q <- ggplot(red, aes_string(
      x = xaxis,
      y = yaxis,
      color = "quality",
      size = bubbleSize))    
    # Give points some alpha to help with overlap/density
    # Can also "jitter" to reduce overlap but reduce accuracy
    q <- q + geom_point(alpha = dotAlpha, position = "jitter")
    
    # Default size scale is by radius, force to scale by area instead
    # Optionally disable legends
    q <- q + scale_size_area(max_size = 7, guide = "none")
    
    # Modify the legend settings
    q <- q + theme(legend.title = element_blank())
    q <- q + theme(legend.direction = "horizontal")
    q <- q + theme(legend.position = c(1, 1))
    q <- q + theme(legend.justification = c(1, 1))
    q <- q + theme(legend.background = element_blank())
    q <- q + theme(legend.key = element_blank())
    q <- q + theme(legend.text = element_text(size = 12))
    
    # Force the dots to plot larger in legend
    q <- q + guides(colour = guide_legend(override.aes = list(size = 6))) # + ylim(3000,6500) + xlim(0,23000)
    q <- q + scale_color_brewer(palette = colScheme) +
      theme(panel.grid.minor.x=element_blank(),
            panel.grid.minor.y=element_blank(), panel.background=element_blank(),
            panel.grid.major.x=element_line(color='grey80',linetype='dashed'),
            panel.grid.major.y=element_line(color='grey80',linetype='dashed')) + 
      theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
      ggtitle('Red')
    palette <- brewer_pal(type = "qual", palette = colScheme)(6)

    if(length(wineQuality>0)){
      palette[which(!levels(red$quality) %in% wineQuality)] <- "#EEEEEE"
      print(palette)
      q <- q + scale_color_manual(values = palette)
    }
  }
  # Create bubble plot
  p <- ggplot(data, aes_string(
    x = xaxis,
    y = yaxis,
    color = "quality",
    size = bubbleSize))
  
  # Give points some alpha to help with overlap/density
  # Can also "jitter" to reduce overlap but reduce accuracy
  p <- p + geom_point(alpha = dotAlpha, position = "jitter")
  
  # Default size scale is by radius, force to scale by area instead
  # Optionally disable legends
  p <- p + scale_size_area(max_size = 7, guide = "none")
  
  # Modify the legend settings
  p <- p + theme(legend.title = element_blank())
  p <- p + theme(legend.direction = "horizontal")
  p <- p + theme(legend.position = c(1, 1))
  p <- p + theme(legend.justification = c(1, 1))
  p <- p + theme(legend.background = element_blank())
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12))
  
  # Force the dots to plot larger in legend
  p <- p + guides(colour = guide_legend(override.aes = list(size = 6))) # + ylim(3000,6500) + xlim(0,23000)
  p <- p + scale_color_brewer(palette = colScheme) +
    theme(panel.grid.minor.x=element_blank(),
          panel.grid.minor.y=element_blank(), panel.background=element_blank(),
          panel.grid.major.x=element_line(color='grey80',linetype='dashed'),
          panel.grid.major.y=element_line(color='grey80',linetype='dashed')) + 
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
    ggtitle(wineType)
  palette <- brewer_pal(type = "qual", palette = colScheme)(6)
  
  if(length(wineQuality>0)){
    palette[which(!levels(data$quality) %in% wineQuality)] <- "#EEEEEE"
    print(palette)
    p <- p + scale_color_manual(values = palette)
  }
  if(wineType=='Both'){
    p <- p + ggtitle('White')
    return(grid.arrange(p,q, ncol=2))
  }
  else{
    return(p)
  }  
}

getScatterPlotMatrix <- function(white,red,xaxis,yaxis,colScheme,dotAlpha,regions) {
#   if(length(regions)<1){
#     df<-df
#   }
#   else{
#     df<-df[which(df$Region %in% regions),]
#   }
  xx <- with(white, data.table(id=1:nrow(white), group=Region, df[,c(3,5,6,7)]))
  yy <- melt(xx,id=1:2, variable.name="H", value.name="xval")
  setkey(yy,id,group)
  ww <- yy[,list(V=H,yval=xval),key="id,group"]
  zz <- yy[ww,allow.cartesian=T]
  
  zz <- zz[,list(id, group, xval, yval, min.x=min(xval),min.y=min(yval),
                 range.x=diff(range(xval)),range.y=diff(range(yval))),by="H,V"]
  setkey(zz,H,V,group)
  d  <- zz[H==V,list(x=density(xval)$x,
                     y=min.y+range.y*density(xval)$y/max(density(xval)$y)),
           by="H,V,group"]
  ggplot(zz)+
    geom_point(alpha = dotAlpha,subset= .(xtfrm(H)<xtfrm(V)), 
               aes(x=xval, y=yval, color=factor(group)), 
               size=3)+
    geom_line(subset= .(H==V), data=d, aes(x=x, y=y, color=factor(group)))+
    facet_grid(V~H, scales="free")+
    scale_color_discrete(name="Region")+
    labs(x="", y="") + scale_color_brewer(palette = colScheme) + 
    theme(legend.background = element_blank()) +
    theme(legend.title = element_blank()) +
    theme(legend.key = element_blank()) +
    theme(panel.grid.minor.x=element_blank(),
          panel.grid.minor.y=element_blank()) +
    theme(legend.position = c(1, 1)) +
    theme(legend.justification = c(1, 1)) +
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
    scale_colour_discrete(limits = levels(df$Region))
}

getParallelPlot <- function(df,colScheme,dotAlpha,regions) {
  if(length(regions)<1){
    df<-df
  }
  else if(length(regions)<2){
    #     p<-ggplot(data=NULL) + geom_text(data=NULL,label='Parallel co-ordinates plot cannot be displayed for only one region. Please select atleast one more region.')
    #     output$outputId<-'Parallel co-ordinates plot cannot be displayed for only one region. Please select atleast one more region.'
    return(NULL)
  }
  else{
    df<-df[which(df$Region %in% regions),]
    df$Region<-factor(df$Region)
  }
  
  p <- ggparcoord(data = df,                   
                  # Which columns to use in the plot
                  columns = 2:5,                   
                  # Which column to use for coloring data
                  groupColumn = 11,                   
                  # Allows order of vertical bars to be modified
                  order = "anyClass",                  
                  # Do not show points
                  showPoints = FALSE,                  
                  # Turn on alpha blending for dense plots
                  alphaLines = dotAlpha,                  
                  # Turn off box shading range
                  shadeBox = NULL,                  
                  # Will normalize each column's values to [0, 1]
                  scale = "uniminmax" # try "std" also
  )  
  # Start with a basic theme
  p <- p + theme_minimal()  
  # Decrease amount of margin around x, y values
  p <- p + scale_y_continuous(expand = c(0.02, 0.02))
  p <- p + scale_x_discrete(expand = c(0.02, 0.02))  
  # Remove axis ticks and labels
  p <- p + theme(axis.ticks = element_blank())
  p <- p + theme(axis.title = element_blank())
  p <- p + theme(axis.text.y = element_blank())  
  # Clear axis lines
  p <- p + theme(panel.grid.minor = element_blank())
  p <- p + theme(panel.grid.major.y = element_blank())  
  # Darken vertical lines
  p <- p + theme(panel.grid.major.x = element_line(color = "#bbbbbb"))  
  # Move label to bottom
  p <- p + theme(legend.position = "bottom") + scale_color_brewer(palette = colScheme)  
  # Figure out y-axis range after GGally scales the data
  min_y <- min(p$data$value)
  max_y <- max(p$data$value)
  pad_y <- (max_y - min_y) * 0.1  
  # Calculate label positions for each veritcal bar
  lab_x <- rep(colnames(df)[2:5], times = 2) # 2 times, 1 for min 1 for max
  lab_y <- rep(c(min_y - pad_y, max_y + pad_y), each = 4)  
  # Get min and max values from original dataset
  lab_z <- c(sapply(df[, 2:5], min), sapply(df[, 2:5], max))  
  # Convert to character for use as labels
  lab_z <- as.character(lab_z)  
  # Add labels to plot
  p <- p + annotate("text", x = lab_x, y = lab_y, label = lab_z, size = 3)
  p <- p + scale_colour_discrete(limits = levels(df$Region))
}

# browser()
# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  white <- loadWhite()
  red <- loadRed() 
  output$distPlot1 <- renderPlot({
    p<-getBubblePlot(white,red,input$xaxis,
                     input$yaxis,input$colScheme,
                     input$dotAlpha,input$regions,
                     input$wineType,input$bubbleSize,
                     input$wineQuality)
    print(p)    
  })
  output$distPlot2 <- renderPlot({
    p<-getScatterPlotMatrix(white,red,input$xaxis,
                            input$yaxis,input$dotAlpha,
                            input$regions)
    print(p)    
  })
  output$distPlot3 <- renderPlot({
    p<-getParallelPlot(df,input$colScheme,input$dotAlpha,input$regions)
    print(p)    
  })
})