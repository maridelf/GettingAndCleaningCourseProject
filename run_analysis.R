## main function that calls the other function
run_analysis <- function (urlzipfile = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                          tidyfile = "./data/tidydata.txt") {
        ## load libraries
        library(dplyr)
        library(plyr)
        library(tidyr)
        library(reshape2)
        
        ## create the data directory if not exists
        if(!file.exists("./data")) {dir.create("./data")}

        ## download file if not exists
        filedownl = "./data/datos.zip"
        if(!file.exists(filedownl)) { filedownl <- downlFunc(urlzipfile, filedownl) }
        
        ## extract files from zip
        filelist <- data.frame()
        if(file.exists(filedownl)) { filelist <- unzipFunc(filedownl) }
        
        ## if there are no files end function
        if(length(filelist)==0){
                print("No data to process")
                return()
        }
        
        # directory name to process
        d <- "./data/UCI HAR Dataset/train/Inertial Signals/"

        ## the processFunc merge the train and test data adding nrel column
        ## and return a frame with mean and sd of them
        
        ##---------------------------
        ## windows body acceleration
        ##---------------------------
        bax <- processFunc(paste0(d,"body_acc_x_train.txt"),"wBodyAccX")
        bay <- processFunc(paste0(d,"body_acc_y_train.txt"),"wBodyAccY")
        baz <- processFunc(paste0(d,"body_acc_z_train.txt"),"wBodyAccZ")

        ##-----------------------
        ## windows body gyroscope 
        ##-----------------------
        bgx <- processFunc(paste0(d,"body_gyro_x_train.txt"),"wBodyGyroX")
        bgy <- processFunc(paste0(d,"body_gyro_y_train.txt"),"wBodyGyroY")
        bgz <- processFunc(paste0(d,"body_gyro_z_train.txt"),"wBodyGyroZ")

        ##---------------------------
        ## windows total acceleration
        ##---------------------------
        tax <- processFunc(paste0(d,"total_acc_x_train.txt"),"wTotalAccX")
        tay <- processFunc(paste0(d,"total_acc_y_train.txt"),"wTotalAccY")
        taz <- processFunc(paste0(d,"total_acc_z_train.txt"),"wTotalAccZ")
        
        ##------------------------------------------
        ## join all mean and std measurement together.
        ##------------------------------------------
        # The resultdata frame contain 19 column (nrel and mean/std for each 9 measurement)
        dflist <- list(bax, bay, baz, bgx, bgy, bgz, tax, tay, taz)
        resultdata <- join_all(dflist, "nrel")

        # delete object in memory
        rm("bax"); rm("bay"); rm("baz")
        rm("bgx"); rm("bgy"); rm("bgz")
        rm("tax"); rm("tay"); rm("taz")
        rm(dflist) 
        

        ##----------------
        ## Feature
        ##----------------
        feature <- read.table("./data/UCI HAR Dataset/features.txt")
        ## get index and labels of features that contains "mean" or "std", and not contains "meanFreq"
        feat_meanstd_ind <- grep("mean[^Freq]|std", feature$V2)  ## index
        feat_meanstd_lab <- grep("mean[^Freq]|std", feature$V2, value = TRUE) ## labels
        rm("feature")
        
        ## add "V" to complete the name of the variables to get
        feat_meanstd_ind <- paste0("V",feat_meanstd_ind) ## "V1", "V2", ...
        
        ## read the time and frequency data files
        tfd_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
        tfd_test <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
        
        ## select only columns that contain "mean" or "std" by the subseting "Vn" (feat_meanstd_ind)
        tfd_train <- select(tfd_train, one_of(feat_meanstd_ind))
        tfd_test <- select(tfd_test, one_of(feat_meanstd_ind))
        rm("feat_meanstd_ind")
        
        ## add "Mean" or "_Std" at the end in the variable label that contains "mean" or "std"
        ind <- grep("mean",feat_meanstd_lab)
        feat_meanstd_lab[ind]<-paste0(feat_meanstd_lab[ind],"_Mean")
        ind <- grep("std",feat_meanstd_lab)
        feat_meanstd_lab[ind]<-paste0(feat_meanstd_lab[ind],"_Std")

        ## rename features label 
        ## delete "mean()" and "std()" in all labels
        feat_meanstd_lab <- gsub("mean()|std()","",feat_meanstd_lab)
        feat_meanstd_lab <- gsub("-|[/()]","",feat_meanstd_lab)  ## delete "-" and "()"

        #feat_meanstd_lab <- tolower(feat_meanstd_lab)  ## lowercase
        
        ## assign the features labels to column names 
        names(tfd_train) <- feat_meanstd_lab
        names(tfd_test) <- feat_meanstd_lab
        rm("feat_meanstd_lab")
        
        ## merge train and test time-frequency-data adding nrel
        tfd <- mergeframeFunc(tfd_train, tfd_test)
        rm(tfd_train); rm(tfd_test)
        
        ## join the time-frequency data and the main result frame
        dflist <- list(resultdata, tfd)
        resultdata <- join_all(dflist, "nrel")
        rm("tfd")
        
        ##----------------
        ## Subject
        ##----------------
        ## merge train and test subjects adding nrel column
        subject <- mergefileFunc("./data/UCI HAR Dataset/train/subject_train.txt",
                              "./data/UCI HAR Dataset/test/subject_test.txt")
        subject <- rename(subject, c("V1" = "subject"))
        
        ##----------------
        ## Activity
        ##----------------
        ## merge train and test activity number adding nrel column
        activ <- mergefileFunc("./data/UCI HAR Dataset/train/y_train.txt",
                             "./data/UCI HAR Dataset/test/y_test.txt")
        activlab <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
        
        ## merge data activity with label activity
        activ<- merge(activ,activlab, by = "V1")
        rm("activlab")
        
        ## select only nrel and activity columns, drop V1
        activ <- select(activ, nrel, activity=V2, -V1)
        
        
        ## join the subject and activity data with de result frame
        dflist <- list(subject, activ, resultdata)
        resultdata <- join_all(dflist, "nrel")
        rm("subject"); rm("activ")
        
        ## here the resultdata frame contains the data request in point 4
        
        
        ##------------------------------------------------------------
        ## point 5
        ## melt the variables that start with w (window) or t (time) or f (frequency) into a column
        indvar=grep("^w|^t|^f",names(resultdata))
        tidydata <- melt(resultdata, id=c("subject", "activity"), 
                           measure.vars=indvar)
        
        ## now the tidydata frame has 4 columns (subject, activity, variable and value)
        ## summarize all group by subject, activity and variable by averaging value
        tidydata <- ddply(tidydata, .(subject, activity, variable), summarise, average=mean(value))

        ## Separate the column "variable"" in 2 columns
        ## creating another column named "calculate" that contain "Mean" or "Std"
        tidydata <- separate(tidydata, variable, c("variable","calculate"), sep="_")
        tidydata$variable <- as.factor(tidydata$variable)
        tidydata$calculate <- as.factor(tidydata$calculate)
        
        ## create the directory to output file
        if(!file.exists(dirname(tidyfile))){dir.create(dirname(tidyfile),recursive = TRUE)}
        ## write a new file with tidydata
        write.table(tidydata,tidyfile, row.name=FALSE)
        
        tidydata
        ## delete de train and test data files
        #deleteOriginData(filelist$Name)
}

#-------------------------------------------#
# downlFunc download the files from the URL #
#-------------------------------------------#
downlFunc <- function(urlzipfile, destfile) {
        
        ## download de zip file
        download.file(urlzipfile, destfile = destfile, method = "auto")
        if(file.exists(destfile)) {
                dateDownloaded <- date()
                return(destfile)
        }
}

#---------------------------------------------------#
# unzipFunc unzip the files into the folder dirdest #
#---------------------------------------------------#
unzipFunc <- function(zipfile, dirdest="./data/") {

        ## extract the files into de zip
        unzip(zipfile, exdir = paste(dirdest,".",sep=""))
        
        ## Return list with extracted files with relative path
        filelist<-unzip(zipfile, list=TRUE)
        mutate(filelist, Name = paste(dirdest,Name, sep = ""))
}

#------------------------------------------------------#
# processFunc process the data train and the data test #
# by merge and adding mean and sd                      #
#------------------------------------------------------#
processFunc <- function (filetrain, measurename = "") {
        ## compose the name of test file by replace "train" with "test"
        filetest = gsub("train","test",filetrain)
        
        ## call mergefileFunc that return a frame with all rows of both keeping the original order through nrel
        fall <- mergefileFunc(filetrain,filetest)
        
        ## calculate mean and sd of each row
        fall <- mutate(fall, mean = rowMeans(fall), sd = apply(fall,1,sd))

        ## take only nrel, mean and sd columns 
        fall <- select(fall, nrel, mean, sd)
        
        ## renames cols mean and sd adding the measurment name
        coln <- c("nrel", paste0(measurename,"_Mean"), paste0(measurename,"_Std"))
        colnames(fall) <- coln
        
        ## return frame all
        fall
}

##-------------------------------------------------------------------------------#
## mergefileFunc read 2 files and call to mergeframeFunc                         #
##-------------------------------------------------------------------------------#
mergefileFunc <- function(filetrain, filetest){
        ## read the first file
        fr <- tbl_df(read.table(filetrain))
        ## read the second file
        fs <- tbl_df(read.table(filetest))
        ## call to mergeframeFunc to merge both
        mergeframeFunc(fr, fs)
}


##------------------------------------------------------------------------------------#
## mergeframeFunc merge 2 frame adding and renumber relation column from the rownames #
##------------------------------------------------------------------------------------#
mergeframeFunc <- function(f1, f2){
        ## get the numbers of rows of the first frame
        numrows = nrow(f1)
        ## add the nrel column to the first frame asigning the rownames to it
        f1 <- mutate(f1, nrel = as.numeric(rownames(f1)))
        ## add the nrel column to the second frame asigning the rownames+numrows to be consecutive
        f2 <- mutate(f2, nrel = as.numeric(rownames(f2))+numrows)
        ## merge both
        merge(f1, f2, all=TRUE)
}


#----------------------------------------------------------------------#
# deleteOriginData delete the data train files and the data test files #
# note: the files in the main directory are not deleted
#----------------------------------------------------------------------#
#deleteOriginData <- function(filelist) {
#        filetodelete <- grep("(train|test).*txt",filelist,value = TRUE)
#        file.remove(filetodelete)
#        dirtodelete <- grep("[^txt]$",filelist,value = TRUE)
#        file.remove(dirtodelete)
#}


