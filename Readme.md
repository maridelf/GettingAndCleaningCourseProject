### Introduction
This R script called run_analysis.R download the file from the link:
https://d396qusza40orc.cloudfront.net/getdata%2Fproject???les%2FUCI%20HAR%20Dataset.zip
and processes the extracted files to obtain a set of tidy data according to course specifications

To run must be the following:
source("run_analysis.R")
tidydata <- run_analysis()

By default the tidy data file is saved in "./data/tidydata.txt"

### General Description
* Merges the training and the test sets by adding a nrel column to keep the original order to matchs rows in different files

* Extracts only the measurements on the mean and standard deviation for each measurement in each file in the directories "train" and "test"

* Extracts from the time and frequency data all columns that contains "mean" or "std" in the name and merge it with the previous data.

* Merge all previous data with subjet and activity names.

* Rename the columns variables without special charaters

* Create a new tidy data set with the previous data set and calculate the average of each variable for each activity and each subject.

* Separate the column variable in 2 columns creating another column named "calculate" that contain "Mean" or "Std"

* Dim of Tidy data is (15120 x 5): 

        15120 rows: 30 subject x 6 activities x 42 variables x 2 calculations
        
        5 columns:
        
        + subject
        + activity
        + variable
        + calculate
        + average

* Write the tidy data in a txt file


### Functions description
In the run_analysis script there are 6 functions:

        * run_analysis ()
        * downloadFunc ()
        * unzipFunc ()
        * processFun ()
        * mergefileFunc ()
        * mergeframeFunc ()


####FUNCTION run_analysis ()
The main function run_analysis () receives 2 parameters,

        1.  the first is the URL to download file, its default value is the exercise URL from the course
        2.  The second parameter indicates the name of the file to save the tidy data resulting from the script. Its default value is "./data/tidydata.txt"

This function calls all other function to process data and save a tidy data set in a file indicates in 2nd parameter.

##### Merge the train and test data
First calls downloadFunc and unzip to extract the files and obtain the list files to process.  Then calls processFunc for each 9 files into the folder "train/inertial signal" and get the result into a frame per file with (nrel, mean, std) columns. (Note: the function processFunc composes the name of the analog test file and merge both)
Finaly join all frames in a new 19 columns frame (nrel and mean/std per each 9 measurments) colled "resultdata".  The columns of 18 variables start with "w" and end with "_Mean" or "_Std"

##### Merge and subseting the features data
Merge the features time-frequency data with label data and get only column that contains "mean" or "std" in the name.
Rename the label deleting the special character and adding "_Mean" or "_Std" in it.
Repeat the same in train and test features data and the merge both througth  mergeframeFunc().
then join it with "resultdata"

##### Process subject and activity files
Read and merge the train and test subject files througth mergefileFunc().  Idem train and test activity files.  Read the activity labels file and merge it with frame of activity.
Join all with "resultdata"

##### Tidy data
First melt the variables that start with w (window) or t (time) or f (frequency) into a column
The tidydata frame has 4 columns (subject, activity, variable and value)
Group by subject, activity and variable averaging value.
Separate the column "variable"" in 2 columns creating another column named "calculate" that contain "Mean" or "Std"
Write tidy data in a txt file



####FUNCTION downloadFunc ()
This function receives 2 parameters:

        1. the first is the URL to download
        2. the second parameter indicates the name of the file to destfile downloaded

This function calls to download.file() and then if the file exists it returns the path and the name of the downloaded file


####FUNCTION unzipFunc ()
This function receives 2 parameters:

        1. the first is the path and name to zipfile
        2. the second parameter indicates the folder to extract the files

This function call to unzip function and extract all files from the zipfile. Then get the list of the files from the zipfile and add the path.  Return this list

####FUNCTION processFunc ()
processFunc receives 2 parameters:

        1. the name of the training set file
        2. the name of the measure included in the file


This function process the data train and the data test by merge and adding mean and sd does the following

* compose the name of test file by replace "train" with "test"
* call mergefileFunc() that return a frame with all rows (10299 x 129) of both files keeping the original order through nrel column
* calculate mean() and sd() of each row on 128 variables
* take only nrel, mean and sd columns 
* renames cols mean and sd adding the measurment name
* return frame all (10299 x 3)

####FUNCTION mergefileFunc ()
This function receive 2 parameters

        1. the name of the first file to merge
        2. the name of the second file to merge
        
Read both files with tbl_df(read.table()) and return the result of mergeframeFunc 


####FUNCTION mergeframeFunc ()
This function receive 2 parameters

        1. the name of the first frame to merge
        2. the name of the second frame to merge
        
First, this function get the numbers of rows of the first frame, then add the nrel column to the first frame asigning the rownames to it. 
Then add the nrel column to the second frame asigning the rownames+numrows to be consecutive with the above.
Finally merge both frames and returns this result

