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
library(httr)
library(XML)
library(RCurl)

loadWhite <- function() {
  white <- read.csv("winequality-white.csv",sep=";")
  white <- white[-which(white$quality==9),]
  white$quality <- as.factor(white$quality)
  white<-white[-which(white$citric.acid==0),]
  return(white)
}

loadRed <- function() {
  red <- read.csv("winequality-red.csv",sep=";")
  red$quality <- as.factor(red$quality)
  red<-red[-which(red$citric.acid==0),]
  return(red)
}

getBubblePlot <- function(white,red,xaxis,yaxis,
                          dotAlpha,
                          wineType,bubbleSize,wineQuality) {
  
  if(wineType=='White'){
    if(length(wineQuality)<1){
      data <- white
    }
    else{
      data<-white[which(white$quality %in% wineQuality),]      
    }
  }
  else if(wineType=='Red'){
    if(length(wineQuality)<1){
      data <- red
    }
    else{
      data<-red[which(red$quality %in% wineQuality),]
    }
  }
  else{
    if(length(wineQuality)<1){
      data <- white
      red <- red
    }
    else{
      data <- white[which(white$quality %in% wineQuality),]
      red <- red[which(red$quality %in% wineQuality),]
    }
    v1 <- red[,xaxis]
    v2 <- red[,yaxis]
    # Create bubble plot
    q <- ggplot(red, aes_string(
      x = log(v1),
      y = yaxis,
      color = "quality",
      size = bubbleSize))  + xlab(xaxis)  
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
    q <- q + theme(legend.justification = c(1, 0))
    q <- q + theme(legend.background = element_blank())
    q <- q + theme(legend.key = element_blank())
    q <- q + theme(legend.text = element_text(size = 12))
    
    # Force the dots to plot larger in legend
    q <- q + guides(colour = guide_legend(override.aes = list(size = 6))) # + ylim(3000,6500) + xlim(0,23000)
    q <- q + scale_color_brewer(palette = 'Set1') +
      theme(panel.grid.minor.x=element_blank(),
            panel.grid.minor.y=element_blank(), panel.background=element_blank(),
            panel.grid.major.x=element_line(color='grey80',linetype='dashed'),
            panel.grid.major.y=element_line(color='grey80',linetype='dashed')) + 
      theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
      ggtitle('Red') + scale_colour_discrete(limits = levels(red$quality)) +
      ylim(min(data[,yaxis]),max(data[,yaxis]))# + xlim(min(log(data[,xaxis])),max(log(data[,xaxis])))
  }
  # Create bubble plot
#   data <- data[-which(data[,xaxis]==0),]
  v1 <- data[,xaxis]
  v2 <- data[,yaxis]
  p <- ggplot(data, aes_string(
    x = log(v1),
    y = yaxis,
    color = "quality",
    size = bubbleSize)) + xlab(xaxis)
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
  p <- p + theme(legend.justification = c(1, 0))
  p <- p + theme(legend.background = element_blank())
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12))
  
  # Force the dots to plot larger in legend
  p <- p + guides(colour = guide_legend(override.aes = list(size = 6))) # + ylim(3000,6500) + xlim(0,23000)
  p <- p + scale_color_brewer(palette = 'Set1') +
    theme(panel.grid.minor.x=element_blank(),
          panel.grid.minor.y=element_blank(), panel.background=element_blank(),
          panel.grid.major.x=element_line(color='grey80',linetype='dashed'),
          panel.grid.major.y=element_line(color='grey80',linetype='dashed')) + 
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
    ggtitle(wineType) + scale_colour_discrete(limits = levels(data$quality)) 

  if(wineType=='Both'){
    p <- p + ggtitle('White')
    return(grid.arrange(p,q, ncol=2))
  }
  else{
    return(p)
  }  
}

getScatterPlotMatrix <- function(white,red,xaxis,yaxis,
                                 dotAlpha,
                                 wineType,bubbleSize,wineQuality) {
  if(wineType=='Red'){
    data<-red
    if(!is.null(wineQuality)){
      data<-red[which(red$quality %in% wineQuality),]
    }
  }else{
    data<-white
    if(!is.null(wineQuality)){
      data<-white[which(white$quality %in% wineQuality),]
    }
  }
  xx <- with(data, data.table(id=1:nrow(data), group=quality, log(data[,c(1,2,3,5,6,7,8,9,10,11)])))
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
    scale_color_discrete(name="quality")+
    labs(x="", y="") + scale_color_brewer(palette = 'Set1') + 
    theme(legend.background = element_blank()) +
    theme(legend.title = element_blank()) +
    theme(legend.key = element_blank()) +
    theme(panel.grid.minor.x=element_blank(),
          panel.grid.minor.y=element_blank(),panel.background=element_blank(),
          panel.grid.major.x=element_line(color='grey90',linetype='dashed'),
          panel.grid.major.y=element_line(color='grey90',linetype='dashed')) +
    theme(legend.position = c(1, 1)) +
    theme(legend.justification = c(1, 1)) +
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
    scale_colour_discrete(limits = levels(data$quality))
}

getParallelPlot <- function(white,red,xaxis,yaxis,
                            dotAlpha,
                            wineType,bubbleSize,wineQuality) {

  if(wineType=='Both'){
    return(NULL)
  }
  if(length(wineQuality)==1){
    return(NULL)
  }
  if(wineType=='White'){
    if(length(wineQuality)<1){
      data <- white
      data$quality <- factor(data$quality)
    }
    else{
      data<-white[which(white$quality %in% wineQuality),]  
      data$quality <- factor(data$quality)
    }
  }
  else if(wineType=='Red'){
    if(length(wineQuality)<1){
      data <- red
      data$quality <- factor(data$quality)
    }
    else{
      data<-red[which(red$quality %in% wineQuality),]
      data$quality <- factor(data$quality)
    }
  }
  else{
    if(length(wineQuality)<1){
      data <- white
      red <- red
    }
    else{
      data <- white[which(white$quality %in% wineQuality),]
      data$quality <- factor(data$quality)
      red <- red[which(red$quality %in% wineQuality),]
      red$quality <- factor(red$quality)
    }
    
    q <- ggparcoord(data = red,                   
                    # Which columns to use in the plot
                    columns = 1:11,                   
                    # Which column to use for coloring data
                    groupColumn = 12,                   
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
    q <- q + theme_minimal()  
    # Decrease amount of margin around x, y values
    q <- q + scale_y_continuous(expand = c(0.02, 0.02))
    q <- q + scale_x_discrete(expand = c(0.02, 0.02))  
    # Remove axis ticks and labels
    q <- q + theme(axis.ticks = element_blank())
    q <- q + theme(axis.title = element_blank())
    q <- q + theme(axis.text.y = element_blank())  
    # Clear axis lines
    q <- q + theme(panel.grid.minor = element_blank())
    q <- q + theme(panel.grid.major.y = element_blank())  
    # Darken vertical lines
    q <- q + theme(panel.grid.major.x = element_line(color = "#bbbbbb"))  
    # Move label to bottom
    q <- q + theme(legend.position = "bottom") + scale_color_brewer(palette = 'Set1')  
    # Figure out y-axis range after GGally scales the data
    min_y <- min(p$data$value)
    max_y <- max(p$data$value)
    pad_y <- (max_y - min_y) * 0.1  
    # Calculate label positions for each veritcal bar
    lab_x <- rep(colnames(red)[1:11], times = 2) # 2 times, 1 for min 1 for max
    lab_y <- rep(c(min_y - pad_y, max_y + pad_y), each = 11)  
    # Get min and max values from original dataset
    lab_z <- c(sapply(red[, 1:11], min), sapply(red[, 1:11], max))  
    # Convert to character for use as labels
    lab_z <- as.character(lab_z)  
    # Add labels to plot
    q <- q + annotate("text", x = lab_x, y = lab_y, label = lab_z, size = 3)
    q <- q + scale_colour_discrete(limits = levels(red$quality)) + 
      guides(colour = guide_legend(
        override.aes = list(alpha=0.8,size=1)))
  }
  
  p <- ggparcoord(data = data,                   
                  # Which columns to use in the plot
                  columns = 1:11,                   
                  # Which column to use for coloring data
                  groupColumn = 12,                   
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
  p <- p + theme(legend.position = "bottom") + scale_color_brewer(palette = 'Set1')  
  # Figure out y-axis range after GGally scales the data
  min_y <- min(p$data$value)
  max_y <- max(p$data$value)
  pad_y <- (max_y - min_y) * 0.1  
  # Calculate label positions for each veritcal bar
  lab_x <- rep(colnames(data)[1:11], times = 2) # 2 times, 1 for min 1 for max
  lab_y <- rep(c(min_y - pad_y, max_y + pad_y), each = 11)  
  # Get min and max values from original dataset
  lab_z <- c(sapply(data[, 1:11], min), sapply(data[, 1:11], max))  
  # Convert to character for use as labels
  lab_z <- as.character(lab_z)  
  # Add labels to plot
  p <- p + annotate("text", x = lab_x, y = lab_y, label = lab_z, size = 3)
  p <- p + scale_colour_discrete(limits = levels(data$quality)) +
    guides(colour = guide_legend(
      override.aes = list(alpha=0.8,size=1)))
  
  if(wineType=='Both'){
    return(NULL)
  }
  else{
    return(p)
  }
}

getHeatMap <- function(white,red,xaxis,yaxis,
                       dotAlpha,
                       wineType,bubbleSize,wineQuality){
  
  if(wineType=='Red'){
    midrange<-range(red[,xaxis])
    xaxis <- c(xaxis,'quality')
    data<-melt(red[,xaxis],'quality')
  }
  else{
    midrange<-range(white[,xaxis])
    xaxis <- c(xaxis,'quality')
    data<-melt(white[,xaxis],'quality')
  }
  
  p <- ggplot(data, aes(x = value, y = quality))
  p <- p + geom_tile(aes(fill = value))
  p <- p + theme_minimal()
  
  # turn y-axis text 90 degrees (optional, saves space)
  p <- p + theme(axis.text.y = element_text(angle = 90, hjust = 0.5))
  
  # remove axis titles, tick marks, and grid
  p <- p + theme(axis.title = element_blank())
  p <- p + theme(axis.ticks = element_blank())
  p <- p + theme(panel.grid = element_blank())
  
  # remove padding around grey plot area
  p <- p + scale_y_discrete(expand = c(0, 0)) 
  
  # optionally remove row labels (not useful depending on molten)
  p <- p + theme(axis.text.x = element_blank()) 
  
  # get diverging color scale from colorbrewer
  # #008837 is green, #7b3294 is purple
  palette <- c("#008837", "#b7f7f4", "#b7f7f4", "#7b3294")
  
  if(midrange[1] == midrange[2]) {
    # use a 3 color gradient instead
    p <- p + scale_fill_gradient2(low = palette[1], mid = palette[2], high = palette[4], midpoint = midrange[1]) +
      xlim(midrange[1],midrange[2]) + xlab(xaxis) +
  guides(fill = guide_legend(title=xaxis))
  }else{
    # use a 4 color gradient (with a swath of white in the middle)
    p <- p + scale_fill_gradientn(colours = palette, values = c(0, midrange[1], midrange[2], 1)) +
      xlim(midrange[1],midrange[2]) + xlab(xaxis) +
  guides(fill = guide_legend(title=xaxis))
  }
}

getStackedBarPlot <- function(white,red,xaxis,yaxis,
                       dotAlpha,
                       wineType,bubbleSize,wineQuality){
  if(min(red[,xaxis]) > min(white[,xaxis])){
    minimum <- min(white[,xaxis])
  }else{
    minimum <- min(red[,xaxis])
  }
  if(max(red[,xaxis]) > max(white[,xaxis])){
    maximum <- max(red[,xaxis])
  }else{
    maximum <- max(white[,xaxis])
  }
  
  if(wineType == 'Red'){
    data <- red
    title <- 'Red'
  }else if(wineType == 'White'){
    data <- white
    title <- 'White'
  }else if(wineType == 'Both'){
    data <- white
    title <- 'White'
  }
  if(length(wineQuality)<1){
  }
  else{
    data <- data[which(data$quality %in% wineQuality),]
    red <- red[which(red$quality %in% wineQuality),]
  }
  data$quality <- as.factor(data$quality)
  stackbar <- ggplot(data, aes_string(x = xaxis, fill = "quality")) +
    geom_bar() +
    labs(fill = "Wine Quality") +
    ggtitle(title) +
    xlab(xaxis) +
    ylab("Count") + theme(legend.title = element_blank()) +
    theme(legend.direction = "horizontal") + 
    theme(legend.position = c(1, 1)) + 
    theme(legend.justification = c(1, 0)) +
    theme(panel.grid.minor.x=element_blank(),
          panel.grid.minor.y=element_blank(), panel.background=element_blank(),
          panel.grid.major.x=element_line(color='grey90',linetype='dashed'),
          panel.grid.major.y=element_line(color='grey90',linetype='dashed')) + 
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) +
    scale_color_brewer(palette = 'Set1') +
    scale_colour_discrete(limits = levels(data$quality))

    
red$quality <- as.factor(red$quality)
  if(wineType == 'Both'){
    stackbar1 <- ggplot(red, aes_string(x = xaxis, fill = "quality")) +
      geom_bar() +
      labs(fill = "Wine Quality") +
          ggtitle("Red") +
      xlab(xaxis) +
      ylab("Count") + theme(legend.title = element_blank()) +
      theme(legend.direction = "horizontal") + 
      theme(legend.position = c(1, 1)) + 
      theme(legend.justification = c(1, 0)) +
      theme(panel.grid.minor.x=element_blank(),
            panel.grid.minor.y=element_blank(), panel.background=element_blank(),
            panel.grid.major.x=element_line(color='grey90',linetype='dashed'),
            panel.grid.major.y=element_line(color='grey90',linetype='dashed')) + 
      theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank()) + 
      scale_color_brewer(palette = 'Set1') +
      scale_colour_discrete(limits = levels(red$quality))
  }

  if(wineType=='Both'){
    stackbar <- stackbar + xlim(minimum, maximum)
    stackbar1 <- stackbar1 + xlim(minimum, maximum)
    return(grid.arrange(stackbar,stackbar1, nrow=2))
  }
  else{
    return(stackbar)
  }
}

# browser()
# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  white <- loadWhite()
  red <- loadRed() 
  output$distPlot1 <- renderPlot({
    p<-getBubblePlot(white,red,input$xaxis,
                     input$yaxis,
                     input$dotAlpha,
                     input$wineType,input$bubbleSize,
                     input$wineQuality)
    print(p)    
  })
  output$distPlot2 <- renderPlot({
    p<-getScatterPlotMatrix(white,red,input$xaxis,
                            input$yaxis,
                            input$dotAlpha,
                            input$wineType,input$bubbleSize,
                            input$wineQuality)
    print(p)    
  })
  output$distPlot3 <- renderPlot({
    p<-getParallelPlot(white,red,input$xaxis,
                       input$yaxis,
                       input$dotAlpha,
                       input$wineType,input$bubbleSize,
                       input$wineQuality)
    print(p)    
  })

  output$distPlot4 <- renderPlot({
    p<-getHeatMap(white,red,input$xaxis,
                       input$yaxis,
                       input$dotAlpha,
                       input$wineType,input$bubbleSize,
                       input$wineQuality)
    print(p)    
  })
  
  output$distPlot5 <- renderPlot({
    p<-getStackedBarPlot(white,red,input$xaxis,
                        input$yaxis,
                        input$dotAlpha,
                        input$wineType,input$bubbleSize,
                        input$wineQuality)
    print(p)    
  })
})