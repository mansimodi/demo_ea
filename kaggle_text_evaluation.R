getwd()
setwd("/Users/mm991t/Desktop/challenges/kaggle_EA")
list.files()

# Data contains keyword of a tweet, location from where it was tweeted,
# and the text of the tweet. 
# Every tweet has a unique id
# target variable is a binary classifier to determine if a tweet is about real disaster or not.

# To predict, based on the 3 columns, keyword, location and text, predict if the tweet
# is related to a real disaster or not. 

# Sample output should be of the form: 
# id , target(0,1)

# Install required packages:

install.packages("stringr")
install.packages("stopwords")


library(stringr)
library(stopwords)

# Read the training data

train_data <- read.csv("train.csv", sep=",", header = TRUE)
head(train_data)
dim(train_data) #7613 5
str(train_data)

unique(train_data$keyword) #222 unique keywords including empty rows
# the rows in keyword with a space between two words is replaced by %20. 
# Do a gsub on %20 and replace it with a space


# Given: NUll : 33%
# USA location: 1%
# Other : 65%

unique(train_data$location) #3342 unique location; 
# lot of locations have punctuations 
# Do a gsub to remove punctuations

unique(train_data$text) #7503 unique text values

train_data$target <- as.logical(train_data$target)
freq <- table(train_data$target)
freq
# 0      1 
# 4342  3271 

# Training data to use will be text and target
train <- train_data[, c(4,5)]
dim(train) # 7613, 2 (text, target)



# Test Data
test <- read.csv("test.csv")
head(test)
dim(test) # 3263 4
str(test)

# test data doesnt have target column
unique(test$keyword) #222
unique(test$location) #1603 ; Null: 34% ; new york - 1%, other (2120) - 65%
unique(test$text) #3243 

# from training_data, for columns keyword and location, remove punctuations

new_keyword <- gsub("%20", " ", train_data$keyword)
new_location <- gsub("[[:punct:]]", " ", train_data$location)


# Data Cleaning for train data:
# There are urls in the text data, we want to delete those
# give a url pattern to be gsubed from the text

url_pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*,]|(?:%[0-9a-fA-F][0-9a-fA-F]))+|\\)$"
train$text <- gsub(url_pattern, " ", train$text)

# Text to lower
# Remove numbers
# Remove brackets
# Remove punctuations


clean_txt_column <- NA

# For each token
for(i in 1:length(train$text)){
  txt_split = strsplit(train$text[i], split = " ")[[1]]
  
  new_txt_split = NA
  for(token in txt_split) {
    
    # convert text to lower
    token = tolower(token)
    
    # Remove numbers
    token = gsub("\\d"," ", token)
    
    # Remove brackets ] [ ( )
    token = gsub(pattern="\\]|\\[|\\(|\\)", " ", token)
    
    # Remove punctuations
    token = gsub("[[:punct:]]"," ", token)
      
    # Remove end period
    token = gsub(pattern="\\.$", " ", token)
    
    # Remove extra whitespace
    token = trimws(gsub(pattern="\\s+", " ", token))
      
    # Remove stopwords
    stopwords_regex = paste(stopwords('en'), collapse = '\\b|\\b')
    stopwords_regex = paste0('\\b', stopwords_regex, '\\b')
      
    token = stringr::str_replace_all(token, stopwords_regex,'')
    
    new_txt_split = c(new_txt_split, token)
    }
  
  new_text = gsub("\\s+"," ",paste(new_txt_split, collapse=" "))
  clean_txt_column = c(clean_txt_column, new_text)
  
  
}

clean_txt_column <- gsub("NA", "", clean_txt_column)
length(clean_txt_column)

clean_txt_column <- clean_txt_column[2:7614]

new_df <- cbind(clean_txt_column, train)
head(new_df)

write.table(new_df, "cleaned_data.csv", quote = FALSE, sep=",", row.names = FALSE, col.names = TRUE)
