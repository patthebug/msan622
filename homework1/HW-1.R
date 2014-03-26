library(ggplot2) 
library(scales)
library(reshape2)
data(movies) 
data(EuStockMarkets)

# filter out movies with budget 0 or lower
movies<-movies[-which(movies$budget<=0),]

# add a genre column
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
movies$genre<-genre

# transform the Eu dataset to time series
eu <- transform(data.frame(EuStockMarkets), time = time(EuStockMarkets))

# Plot 1 - Scatterplot (changed the size and color of the points)
# changed the size of the font on the axes and in the title
p<-ggplot(movies,aes(x=budget,y=rating,color=genre)) + geom_point(size=2, stat='identity') + 
  xlab('Budget of the movie') + ylab('Rating of the movie') + ggtitle('Movie Budget v/s Movie Rating') +
  labs(colour="Genre") + theme(axis.text=element_text(size=14,face="bold"),
                               plot.title = element_text(size = 25, face = "bold", colour = "black", vjust = 1)) 
p
# save the file
ggsave(filename='hw1-scatter.png', plot=p, scale=1, height=6.5, width=13, units='in', dpi=300)


# PLot 2 - Bar Chart
# create a temparary data frame to calculate percentages
tempdf<-as.data.frame(table(movies$genre))
tempdf$percentage<-tempdf$Freq/sum(tempdf$Freq)
names(tempdf)<-c('Genre','Count','Percentage')

# plot the bar chart with number of movies in each genre on top of each bar, removed the legend,
# changed the size of the text on the axes and on the title
p<-ggplot(data=tempdf,aes(x=Genre,y=Count,fill=Genre)) + geom_bar(stat='identity') + 
  geom_text(data=tempdf,aes(label=Count),vjust=0) +
  xlab('Genre of the Movie') + ylab('Count') + ggtitle('# of Movies in each genre') + guides(fill=FALSE) +
  theme(axis.text=element_text(size=14,face="bold"),
        plot.title = element_text(size = 25, face = "bold", colour = "black", vjust = 1)) 
p

# save the file
ggsave(filename='hw1-bar.png', plot=p, scale=1, height=6.5, width=13, units='in', dpi=300)

# PLot 3 - Small Multiples
# plot small multiples, removed legend, changed size of the text on the axes as some of it was overlapping,
# also changed the size of the font on the title
p <- ggplot(movies, aes(x=budget, y=rating, group = factor(genre),color=factor(genre))) + geom_point() +
  xlab('Budget') + ylab('Rating') + facet_wrap(~genre,ncol=3) + 
  theme(legend.position="none",text = element_text(size=13),
        plot.title = element_text(size = 25, face = "bold", colour = "black", vjust = 1)) +
  ggtitle('Movie genre - Rating v/s Budget')
p

# save the file
ggsave(filename='hw1-multiples.png', plot=p, scale=1, height=6.5, width=13, units='in', dpi=300)


# PLot 4 - Multi-Line Chart

tempdf<-as.data.frame(melt(eu[,1:4]))
tempdf$time<-rep(eu$time,times=4)
names(tempdf)<-c('Market','Value','Time')
# increased the font size on the axes and on the title
p <- ggplot(tempdf, aes(x=Time, y=Value, group = factor(Market),color=factor(Market))) + geom_line() +
  xlab('Year') + ylab('Value') + 
  ggtitle("Changes in Market's value over time") + labs(colour="Market") + 
  theme(axis.text=element_text(size=14,face="bold"),
        plot.title = element_text(size = 25, face = "bold", colour = "black", vjust = 1)) 
p

# save the file
ggsave(filename='hw1-multiline.png', plot=p, scale=1, height=6.5, width=13, units='in', dpi=300)
