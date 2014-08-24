### Getting and Cleaning Data Course Project ###
###
### GOALS ###
# demonstrate your ability to 
# 1. collect
# 2. work with
# 3. clean a data set
# 
# required to submit: 
# 1) A tidy data set as described below
# 2) A link to a Github repository with your script for performing the analysis
# 3) A code book (CodeBook.Rmd) that describes the variables, the data, and any transformations or work that you performed to clean up the data
#    You should also include a README file (README.Rmd) in the repo with your scripts. This explains how all of the scripts works and how they are connected.  

# Data location:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

### ------- EXTRACT the above zip in the working directory, the script will read it from there ------------- #####

# You should create one R script called run_analysis.R that does the following. 
# 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
#         1 WALKING
#         2 WALKING_UPSTAIRS
#         3 WALKING_DOWNSTAIRS
#         4 SITTING
#         5 STANDING
#         6 LAYING
#
# Appropriately labels the data set with descriptive variable names. 
#   Insert colnames in data set.
    
# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Step 1 : Getting data/Merging/cleaning

# get the test data X_test.txt
X_test <- read.delim(file="./UCI HAR Dataset/test/X_test.txt",sep="",header=F)
# Col bind for activity and subject
Activity_test.txt <- read.delim(file="./UCI HAR Dataset/test/y_test.txt",sep="",header=F)
X_test <- cbind(Activity_test.txt,X_test)
Subject_test <- read.delim(file="./UCI HAR Dataset/test/subject_test.txt",sep="",header=F)
X_test <- cbind(Subject_test,X_test)

# get the train data X_train.txt
X_train <- read.delim(file="./UCI HAR Dataset/train/X_train.txt",sep="",header=F)
# Col bind for activity and subject
Activity_train.txt <- read.delim(file="./UCI HAR Dataset/train/y_train.txt",sep="",header=F)
X_train <- cbind(Activity_train.txt,X_train)
Subject_train <- read.delim(file="./UCI HAR Dataset/train/subject_train.txt",sep="",header=F)
X_train <- cbind(Subject_train,X_train)


# Get columns names as vector
X_ColNames <- read.delim(file="./UCI HAR Dataset/features.txt",sep="",header=F)
X_ColNames_vector <- as.vector(X_ColNames[,2])

# Clean up column names for clarity and for sqldf select
# 1. tBody to TimeBody
# 2. tGravity to TimeGravity
# 3. fBody to FrequenctBody
# 4. - to _
# 5. ( to _
# 6. ) to _
# 7 , to _


X_ColNames_vector <- gsub("tBody","TimeBody", X_ColNames_vector)
X_ColNames_vector <- gsub("tGravity","TimeGravity", X_ColNames_vector)
X_ColNames_vector <- gsub("fBody","FrequenctBody", X_ColNames_vector)
X_ColNames_vector <- gsub("fBody","FrequenctBody", X_ColNames_vector)
X_ColNames_vector <- gsub("-","_", X_ColNames_vector)
X_ColNames_vector <- gsub("(","_", X_ColNames_vector, fixed=T)
X_ColNames_vector <- gsub(")","_", X_ColNames_vector, fixed=T)
X_ColNames_vector <- gsub(",","_", X_ColNames_vector, fixed=T)

# Get Column position where case insentive (mean and std) are
X_ColNumbers_grep <- grep("mean|std", X_ColNames_vector, value = FALSE, ignore.case=T)
# adding 2 for column Subject and Activity.
X_ColNumbers <- c(1, 2, X_ColNumbers_grep + 2)


# New DF with only the columns showing mean and standard deviation. 86 cols vs 561.
X_train_Mean_Std <- X_train[,X_ColNumbers]
X_test_Mean_Std <- X_test[,X_ColNumbers]

# Merge X_test.txt and X_train.txt
X_Merged_Data <- merge(x = X_train_Mean_Std,y = X_test_Mean_Std, all=T)

# Add columns names to X_Merged_Data data frame
colnames(X_Merged_Data) <- c("Subject","Activity",X_ColNames_vector[X_ColNumbers_grep])

## We now have X_Merged_Data with both test/train data, columns of (mean/std) only and column names

# rename of activity label
X_Merged_Data$Activity[X_Merged_Data$Activity == 1] <- "Walking"
X_Merged_Data$Activity[X_Merged_Data$Activity == 2] <- "Walking_Upstairs"
X_Merged_Data$Activity[X_Merged_Data$Activity == 3] <- "Walking_Downstairs"
X_Merged_Data$Activity[X_Merged_Data$Activity == 4] <- "Sitting"
X_Merged_Data$Activity[X_Merged_Data$Activity == 5] <- "Standing"
X_Merged_Data$Activity[X_Merged_Data$Activity == 6] <- "Laying"

## We now have a clean data set with column names and clear activity names
head(X_Merged_Data)

# Step2 : Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# Using sqldf

library("sqldf", lib.loc="~/R/win-library/3.1")

SelectStatment <- "select Subject,Activity,"

for (Index in 1:length(X_ColNumbers_grep)){
    SelectStatment <- paste (SelectStatment,"avg(",X_ColNames_vector[X_ColNumbers_grep[Index]],")")
    if (!Index==length(X_ColNumbers_grep)){
        SelectStatment <- paste(SelectStatment,",")
    }
}
SelectStatment <- paste(SelectStatment,"from X_Merged_Data group by Activity, Subject")

X_Merge_Data_Averages_Grouped <- sqldf(SelectStatment,drv='SQLite')

write.table(X_Merge_Data_Averages_Grouped,file = "X_Merge_Data_Averages_Grouped.txt",row.names=F)
