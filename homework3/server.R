library(shiny)
library(ggplot2)
library(scales)
require(GGally)
library(reshape2)   
library(plyr)       
library(data.table)

loadData <- function() {
  data(state)
  
  # Sort bubble plot so smaller colors are displayed last
  # on top of the bigger colors
  df <- data.frame(state.x77,
                   State = state.name,
                   Abbrev = state.abb,
                   Region = state.region,
                   Division = state.division
  )  
  return(df)
}

million_formatter<-function(x){
  return(sprintf("%dM",round(x/1000000)))
}

getBubblePlot <- function(df,colScheme,dotAlpha,regions) {
  if(length(regions)<1){
    df<-df
  }
  else{
    df<-df[which(df$Region %in% regions),]
  }
  
  # Create bubble plot
  p <- ggplot(df, aes(
    x = Population,
    y = Income,
    color = Region,
    size = Area))
  
  # Give points some alpha to help with overlap/density
  # Can also "jitter" to reduce overlap but reduce accuracy
  p <- p + geom_point(alpha = dotAlpha, position = "jitter")
  
  # Default size scale is by radius, force to scale by area instead
  # Optionally disable legends
  p <- p + scale_size_area(max_size = 10, guide = "none")
  
  # Make the grid square
  p <- p + coord_fixed(ratio = 3)
  
  # Modify the labels
  p <- p + labs(
    size = "Area",
    x = "Population",
    y = "Income")
  
  # Modify the legend settings
  p <- p + theme(legend.title = element_blank())
  p <- p + theme(legend.direction = "horizontal")
  p <- p + theme(legend.position = c(1, 0))
  p <- p + theme(legend.justification = c(1, 0))
  p <- p + theme(legend.background = element_blank())
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12))
#   p <- p + theme(legend.margin = unit(0, "pt"))
  
  # Force the dots to plot larger in legend
  p <- p + guides(colour = guide_legend(override.aes = list(size = 8))) + ylim(3000,6500) + xlim(0,23000)
  
  # Indicate size is petal length
  p <- p + annotate(
    "text", x = 11000, y = 6000,
    hjust = 0.5, color = "grey40",
    label = "Circle area is proportional to Area of the State.") +
    scale_color_brewer(palette = colScheme) +
    theme(panel.grid.minor.x=element_blank(),
          panel.grid.minor.y=element_blank()) + 
    theme(axis.ticks.x=element_blank()) + theme(axis.ticks.y=element_blank())
  p <- p + scale_colour_discrete(limits = levels(df$Region))
  return(p)
}

getScatterPlotMatrix <- function(df,colScheme,dotAlpha,regions) {
  if(length(regions)<1){
    df<-df
  }
  else{
    df<-df[which(df$Region %in% regions),]
  }
  xx <- with(df, data.table(id=1:nrow(df), group=Region, df[,c(3,5,6,7)]))
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
  df<-loadData()  
  output$distPlot1 <- renderPlot({
    p<-getBubblePlot(df,input$colScheme,input$dotAlpha,input$regions)
    print(p)    
  })
  output$distPlot2 <- renderPlot({
    p<-getScatterPlotMatrix(df,input$colScheme,input$dotAlpha,input$regions)
    print(p)    
  })
  output$distPlot3 <- renderPlot({
    p<-getParallelPlot(df,input$colScheme,input$dotAlpha,input$regions)
    print(p)    
  })
})