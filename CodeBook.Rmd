---
title: "Getting and Cleaning Data - Course Project - CodeBook.md"
author: "Simon Filiatrault"
date: "Monday, August 18, 2014"
output: html_document
---

## Goal of this project
### create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

### Detailed steps explained
#### Section #1 for steps 1 to 4 of the project (described above)

1. get the test and train data
    + Here we use the **read.delim** function with space seperator and no header

    ```
    X_test <- read.delim(file="./UCI HAR Dataset/test/X_test.txt",sep="",header=F)
    X_train <- read.delim(file="./UCI HAR Dataset/train/X_train.txt",sep="",header=F)
    ``` 

2. Add new columns for activity and subject
    + Here we use **read.delim** and **cbind** to add new columns
 
    ``` 
    Activity_test.txt <- read.delim(file="./UCI HAR Dataset/test/y_test.txt",sep="",header=F)
    X_test <- cbind(Activity_test.txt,X_test)
    Subject_test <- read.delim(file="./UCI HAR Dataset/test/subject_test.txt",sep="",header=F)
    X_test <- cbind(Subject_test,X_test)
    
    Activity_train.txt <- read.delim(file="./UCI HAR Dataset/train/y_train.txt",sep="",header=F)
    X_train <- cbind(Activity_train.txt,X_train)
    Subject_train <- read.delim(file="./UCI HAR Dataset/train/subject_train.txt",sep="",header=F)
    X_train <- cbind(Subject_train,X_train)
    ```

3. We now grab the columns name from the features data set and clean it
    + This is needed for the following sqldf function
    + It's also a quick way to have more human readable column headers.
    + The code can be adjusted quickly to modify the colomns names
    + Here we use **as.vector** and **gsub** function to do some cleaning

    ```
    X_ColNames <- read.delim(file="./UCI HAR Dataset/features.txt",sep="",header=F)
    X_ColNames_vector <- as.vector(X_ColNames[,2])
    X_ColNames_vector <- gsub("tBody","TimeBody", X_ColNames_vector)
    X_ColNames_vector <- gsub("tGravity","TimeGravity", X_ColNames_vector)
    X_ColNames_vector <- gsub("fBody","FrequenctBody", X_ColNames_vector)
    X_ColNames_vector <- gsub("fBody","FrequenctBody", X_ColNames_vector)
    X_ColNames_vector <- gsub("-","_", X_ColNames_vector)
    X_ColNames_vector <- gsub("(","_", X_ColNames_vector, fixed=T)
    X_ColNames_vector <- gsub(")","_", X_ColNames_vector, fixed=T)
    X_ColNames_vector <- gsub(",","_", X_ColNames_vector, fixed=T)
    ```

4. We now need to find the Column position where case insentive (mean and std) are
    + We use here **grep** to find the columns index
    + We then add two columns index for subject and activity

    ```
    X_ColNumbers_grep <- grep("mean|std", X_ColNames_vector, value = FALSE, ignore.case=T)
    X_ColNumbers <- c(1, 2, X_ColNumbers_grep + 2)
    ```


5. We now create 2 new data frame with only the columns showing mean and standard deviation. We get 86 cols vs 561.

    ```
    X_train_Mean_Std <- X_train[,X_ColNumbers]
    X_test_Mean_Std <- X_test[,X_ColNumbers]
    ```

6. Now it's time to merge the two data set
    + This is done here after clean up and with less columns
    + because merging the originals causes errors because of size
    + This is done with the **merge** function
    
    ```
    X_Merged_Data <- merge(x = X_train_Mean_Std,y = X_test_Mean_Std, all=T)
    ```

7. We now Add columns names to merged data frame
    + Here we are also adding the Subject and Activity columns

    ```
    colnames(X_Merged_Data) <- c("Subject","Activity",X_ColNames_vector[X_ColNumbers_grep])
    ```

8. We now replace the activity numbers with proper names 
    + Using this manual method permits us to change the names to anything
    + and not be limited to what the dataset provides
    
    ```
    X_Merged_Data$Activity[X_Merged_Data$Activity == 1] <- "Walking"
    X_Merged_Data$Activity[X_Merged_Data$Activity == 2] <- "Walking_Upstairs"
    X_Merged_Data$Activity[X_Merged_Data$Activity == 3] <- "Walking_Downstairs"
    X_Merged_Data$Activity[X_Merged_Data$Activity == 4] <- "Sitting"
    X_Merged_Data$Activity[X_Merged_Data$Activity == 5] <- "Standing"
    X_Merged_Data$Activity[X_Merged_Data$Activity == 6] <- "Laying"
    ```

#### We now have a clean data set with column names and clear activity names

### Creating the new data set
#### Section #2 for steps 5 of the project (described above)

1. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    + For this we will be using sqldf
    + sqldf permit us to create this new data frame quickly
    + but first we need to create the sql statment, using the **for** loop 
    + so **sqldf**, **for**, **paste** and other functions have been used for this

    ```
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
    ```
2. Write the new data frame to a txt file

    ``` 
    write.table(X_Merge_Data_Averages_Grouped,file = "X_Merge_Data_Averages_Grouped.txt",row.names=F)
    ```
