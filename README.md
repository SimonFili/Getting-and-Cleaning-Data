---
title: "README.Rmd"
author: "Simon Filiatrault"
date: "Monday, August 18, 2014"
output: html_document
---

# Getting and Cleaning Data

This README explains the content of the project files for the getting and cleaning data coursera course project.
The goal of this project is to:

## Goal of this project
### create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

### Files descriptions                
                    
|Files|Description|Details|
|-------------------------:|-----------------------:|-----------------------------:|
|run_analysis.R|This file is the main analysis script|It will do the 5 steps above|
|CodeBook.Rmd|This is the CookBook explaining the project|Listing all steps in "cooking" the data in details|
|README.Rmd|This file|Explains the files and data input / output|
|README.html|This file in HTML format|In case you want to see a nice output|
|CodeBook.html|The cookbook in HTML|Easier to read|
|X_Merge_Data_Averages_Grouped.txt|The merged data set|Created in step 5 above|

### Data set descriptions
  NOTE: For the details of how the DATA was "Cooked", please open the CookBook.html
  
  The original dataset is seperated in many files with not very descriptive column names.
  The main data set has over 500 columns, so this project goal is to extract part of this dataset
  Another goal is to add the activity and users (two seperated dataset) in the main one
  When this is done, we can merge the two main data set, the training one and the test one.
  See the CookBook.html for details.
  
### Variables
  The column names have been "renamed" to have more descriptive names.  
  The approch I took is to replace terms like "t" with more descriptive name "Time" for example
  The downside of having a more descriptive name is that the column name can become long
  So you can choose what to search&replace to suite your needs and taste.  Finding the balance that work for you.
  Again, details are in the CookBook.html
  
### How to run the analysis
  First you need to download the zip datasets and extract in your working directory.
  This will create this structure:

* UCI HAR Dataset  
    + test  
        + Inertial Signals  
    + train   
        + Inertial Signals  
        
 The datasets we need are located under the test and train subfolder.
 The scripts in run_analysis.R is coded for this.
 

Enjoy!


