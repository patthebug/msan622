require(ggplot2)
# source("sotu.r")

require(tm)        # corpus
require(SnowballC) # stemming

sotu_source <- DirSource(
  # indicate directory
  directory = "D:\Data",
  encoding = "UTF-8",     # encoding
  pattern = "*.txt",      # filename pattern
  recursive = FALSE,      # visit subdirectories?
  ignore.case = FALSE)    # ignore case in pattern?

sotu_corpus <- Corpus(
  sotu_source, 
  readerControl = list(
    reader = readPlain, # read as plain text
    language = "en"))   # language is english

sotu_corpus <- tm_map(sotu_corpus, tolower)

sotu_corpus <- tm_map(
  sotu_corpus, 
  removePunctuation,
  preserve_intra_word_dashes = TRUE)

sotu_corpus <- tm_map(
  sotu_corpus, 
  removeWords, 
  stopwords("english"))

# getStemLanguages()
sotu_corpus <- tm_map(
  sotu_corpus, 
  stemDocument,
  lang = "porter") # try porter or english

sotu_corpus <- tm_map(
  sotu_corpus, 
  stripWhitespace)

# Remove specific words
sotu_corpus <- tm_map(
  sotu_corpus, 
  removeWords, 
  c("will", "can", "get", "that", "year", "let"))

# print(sotu_corpus[["sotu2013.txt"]][3])

# Calculate Frequencies
sotu_tdm <- TermDocumentMatrix(sotu_corpus)

# Convert to term/frequency format
sotu_matrix <- as.matrix(sotu_tdm)
sotu_df <- data.frame(
  word = rownames(sotu_matrix), 
  # necessary to call rowSums if have more than 1 document
  freq = rowSums(sotu_matrix),
  stringsAsFactors = FALSE) 

# Sort by frequency
sotu_df <- sotu_df[with(
  sotu_df, 
  order(freq, decreasing = TRUE)), ]

# Do not need the row names anymore
rownames(sotu_df) <- NULL

# Sort bars by frequency
bar_df <- head(sotu_df, 10)
bar_df$word <- factor(bar_df$word, 
                      levels = bar_df$word, 
                      ordered = TRUE)

# Print a simple bar plot of the top 10 words
p <- ggplot(bar_df, aes(x = word, y = freq)) +
  geom_bar(stat = "identity", fill = "grey60") +
  ggtitle("Pride and Prejudice") +
  xlab("Top 10 Word Stems (Stop Words Removed)") +
  ylab("Frequency") +
  theme_minimal() +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme(panel.grid = element_blank()) +
  theme(axis.ticks = element_blank())

print(p)

require(wordcloud) # word cloud

wordcloud(
  sotu_df$word,
  sotu_df$freq,
#   scale = c(0.5, 6),      # size of words
  min.freq = 10,          # drop infrequent
  max.words = 50,         # max words in plot
#   random.order = FALSE,   # plot by frequency
#   rot.per = 0.3,          # percent rotated
#   # set colors
#   # colors = brewer.pal(9, "GnBu")
  colors = brewer.pal(9, "Paired"),
#   # color random or by frequency
  random.color = TRUE,
#   # use r or c++ layout
#   use.r.layout = FALSE    
)

sotu_tdm<- TermDocumentMatrix(sotu_corpus)
sotu_tdm <- as.matrix(sotu_tdm)
comparison.cloud(sotu_tdm,max.words=Inf,random.order=FALSE)

