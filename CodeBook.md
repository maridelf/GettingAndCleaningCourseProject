##TidyData.txt

* subject
        1
        integer
        [1:30]
        
* activity
        18
        factor: 6 levels activity name
        
        + LAYING 
        + SITTING 
        + STANDING 
        + WALKING 
        + WALKING_DOWNSTAIRS 
        + WALKING_UPSTAIRS

* variable
        factor: 42 levels variable name

        + wBodyAccX"
        + wBodyAccY"              
        + wBodyAccZ"             
        + wBodyGyroX"             
        + wBodyGyroY"             
        + wBodyGyroZ"            
        + wTotalAccX"             
        + wTotalAccY"             
        + wTotalAccZ"            
        + tBodyAccX"            
        + tBodyAccY"            
        + tBodyAccZ"        
        + tGravityAccX"         
        + tGravityAccY"         
        + tGravityAccZ"        
        + tBodyAccJerkX"        
        + tBodyAccJerkY"        
        + tBodyAccJerkZ"       
        + tBodyGyroX"           
        + tBodyGyroY"           
        + tBodyGyroZ"          
        + tBodyGyroJerkX"       
        + tBodyGyroJerkY"       
        + tBodyGyroJerkZ"      
        + tBodyAccMag"          
        + tGravityAccMag"       
        + tBodyAccJerkMag"     
        + tBodyGyroMag"         
        + tBodyGyroJerkMag"     
        + fBodyAccX"           
        + fBodyAccY"            
        + fBodyAccZ"            
        + fBodyAccJerkX"       
        + fBodyAccJerkY"        
        + fBodyAccJerkZ"        
        + fBodyGyroX"          
        + fBodyGyroY"           
        + fBodyGyroZ"           
        + fBodyAccMag"         
        + fBodyBodyAccJerkMag"  
        + fBodyBodyGyroMag"     
        + fBodyBodyGyroJerkMag"
        
* calculate
        factor: 2 levels
        + Mean
        + Std
        
* average
        numeric
        this value is calculate by group subject-activity and mean all values in the group.  
        For the triaxial measurements first the average of the sliding windows is calculated and then the group by
