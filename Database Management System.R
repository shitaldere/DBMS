---
  title: "Loading of Restaurant Database"
  name:  "Shital dilip dere"
  Term:  "Summer 1 2023"
---
    
#2.  Connection to mySQL database
   library(RMySQL)
  

  db_user <- 'sql9623315'            # use your value from the setup
  db_password <- '6PHeg5saHJ'    # use your value from the setup
  db_name <-    'sql9623315'         # use your value from the setup
  db_host <- 'sql9.freemysqlhosting.net'           # for db4free.net
  db_port <- 3306
  
  
  # 3. Connect to remote server database
  mydb <-  dbConnect(MySQL(), user = db_user, password = db_password,
                     dbname = db_name, host = db_host, port = db_port)
  
  
--------------------------------------------------------------------------------------------------------------- 
    
    
 #3.Creating the database schemas  
  
  createRestaurantTable <- function() {
    
    # Define the SQL query for creating the table
    query <- " CREATE TABLE restaurants (
                     rid INTEGER PRIMARY KEY ,
                     name TEXT ,
                     `date.opened` DATE,
                     `max.capacity` INTEGER CHECK (`max.capacity` >= 0),
                     cuisine VARCHAR(50) DEFAULT 'American'  , 
                     isOpen BOOLEAN
                );"
      
  
    dbExecute(mydb, query )
    
  }
  
  createRestaurantTable()
  
--------------------------------------------------------------------------------------------------------------- 
    
    
query <- "ALTER TABLE restaurants
  MODIFY COLUMN cuisine INT;" 
  

dbExecute(mydb, query) 
  
--------------------------------------------------------------------------------------------------------------- 
  
createCustomersTable <- function() {
    
    # Define the SQL query for creating the table
    query <- "
                CREATE TABLE customers  (
                     cid INTEGER PRIMARY KEY ,
                     cname TEXT ,
                     cphone TEXT );"
    
    dbExecute(mydb, query )
    
}
  
createCustomersTable() 

--------------------------------------------------------------------------------------------------------------- 
  
  
createVisitsTable <- function() {
    
   
    query <- "
    CREATE TABLE visits   (
         vid INTEGER PRIMARY KEY ,
         cid INTEGER ,
         rid INTEGER ,
         cc TEXT,
         vdate DATE,
         amount NUMERIC CHECK (amount > 0) , 
         orderedWine BOOLEAN,
         `num.guests` INTEGER CHECK (`num.guests` > 0) ,
         FOREIGN KEY (cid) REFERENCES customers(cid),
         FOREIGN KEY (rid) REFERENCES restaurants(rid)
         
         );"
    dbExecute(mydb, query )
    
}

createVisitsTable()   
  
--------------------------------------------------------------------------------------------------------------- 

createCuisineTable <- function() {
  
  query <- "
    CREATE TABLE cuisine (
      zid INTEGER PRIMARY KEY,
      type TEXT,
      comments TEXT
    );"

  
  dbExecute(mydb, query)
}

createCuisineTable()  
--------------------------------------------------------------------------------------------------------------- 
query <- "
  ALTER TABLE cuisine
  MODIFY COLUMN zid INTEGER(10);"

dbExecute(mydb, query)  

--------------------------------------------------------------------------------------------------------------- 


query <- "
 ALTER TABLE restaurants
  ADD CONSTRAINT fk_cuisine
  FOREIGN KEY (cuisine)
  REFERENCES cuisine  (zid);"

dbExecute(mydb, query) 
  
--------------------------------------------------------------------------------------------------------------- 

createRestaurant_factsTable  <- function() {
  
  query <- "
    CREATE TABLE restaurant_facts  (
      rid INTEGER ,
      numGuests  INTEGER,
      year  INTEGER,
      FOREIGN KEY (rid) REFERENCES restaurants(rid)
    );"
  
  
  dbExecute(mydb, query)
}

createRestaurant_factsTable()  



--------------------------------------------------------------------------------------------------------------------

#4. Reading the CSV and populating the tables with csv data.
# Finding unique values for restaurant name
# First we find the unique values for restaurant and then populate the restaurant table.
# then the cuisine table is created as given.
# Finally csv records are iterated one by one to get the customer and corresponding visit record. 



Jan2Marchdf <- read.csv("https://s3.us-east-2.amazonaws.com/artificium.us/assignments/80.xml/a-80-305/gen-xml/synthsalestxns-Jan2Mar.csv", header = TRUE, sep = ",")

Sep2Octdf <- read.csv('https://s3.us-east-2.amazonaws.com/artificium.us/assignments/80.xml/a-80-305/gen-xml/synthsalestxns-Sep2Oct.csv', header = TRUE, sep = ",")

Nov2Decdf <- read.csv('https://s3.us-east-2.amazonaws.com/artificium.us/assignments/80.xml/a-80-305/gen-xml/synthsalestxns-Nov2Dec.csv', header = TRUE, sep = ",")

## Combining 3 data frames

csv_data <- rbind(Jan2Marchdf, Sep2Octdf, Nov2Decdf)

head(csv_data)

# creating a data frame
cuisine_df <- data.frame(zid = c(1,2,3),type = c("American",
                                     "Italian","Continental Spanish"), comments = c("","",""))

# creating the query
query <- "insert into cuisine(zid,type,comments) VALUES"

# inserting values in sql query
query <- paste0(query, paste(sprintf("(%d,'%s', '%s')",
                                     cuisine_df$zid, cuisine_df$type,cuisine_df$comments), collapse = ","))
print(query)

dbExecute(mydb, query)  

--------------------------------------------------------------------------------------------------------------- -----
  
  
unique_values <- unique(csv_data[["restaurant"]])
print(unique_values)

counter <- 1

restaurant_df <- data.frame()

for (value in unique_values) {
 
  cuisine_id <- 1 
 
  if(value == 'Olga\'s') {
    cuisine_id <- 3
  }else if(value == 'Ninita') {
    cuisine_id <- 2
  }
    
    # Escape the special characters in the value
    escaped_value <- dbEscapeStrings(mydb, value)
  
    # creating a data frame
    new_record_df <- data.frame(rid = c(counter), name = c(escaped_value),date_opened=c("1996-01-01"),max_capacity=c(200),cuisine=c(cuisine_id),isOpen=c("TRUE"))
    
    
    # creating the query
    query <- "INSERT INTO restaurants (rid, name, `date.opened`, `max.capacity`, cuisine, isOpen) VALUES"
    
    # inserting values in sql query
    query <- paste0(query, paste(sprintf("(%d,'%s','%s',%d ,%d, %s)",
                                         new_record_df$rid, new_record_df$name,new_record_df$date_opened,new_record_df$max_capacity,new_record_df$cuisine,new_record_df$isOpen), collapse = ","))
    
    print(query)
    
    dbExecute(mydb, query)
    
    restaurant_df <- rbind(restaurant_df, new_record_df)
    
    counter <- counter +1
}

print(restaurant_df)
------------------------------------------------------------------------------------------------------------------

visit_id <- 100
customer_id <- 1

for (i in 1:nrow(csv_data)) {
  
  cname <- csv_data$name[i]
  cphone <- csv_data$phone[i]

  
  # Convert special characters using escape character
  cname <-  dbEscapeStrings(mydb, cname)
  
  customer_df <- data.frame(cid = c(customer_id), cname = c(cname),cphone=c(cphone))
  
  
  query <- "insert into customers(cid,cname,cphone) VALUES"
  
  
  query <- paste0(query, paste(sprintf("(%d,'%s', '%s')",
                                       customer_df$cid, customer_df$cname,customer_df$cphone), collapse = ","))
  
   
  print(query)
  
  dbExecute(mydb, query)
  
  credit_card <- csv_data$cc[i]
  vdate <- csv_data$date[i]
  amount_str <- csv_data$amount[i]
  
  # Remove the "$" symbol
  amount <- gsub("\\$", "", amount_str)
  
  
  orderedWine_str <- csv_data$wine[i]


  if (orderedWine_str == 'Yes') {
    orderedWine = TRUE
  }else {
    orderedWine = FALSE
  }
  
  num_guests <- csv_data$guests[i]
  restaurant_name <- csv_data$restaurant[i]
  
  print(vdate)

  # Convert special characters using escape character
  restaurant_name <-  dbEscapeStrings(mydb, restaurant_name)
  
  result <- restaurant_df[restaurant_df$name == restaurant_name, ]
  print(restaurant_name)
  print(result)
  rid <- result$rid
  print(rid)

  formated_date <- as.Date(vdate, format = "%m/%d/%y")



  # creating a data frame
  visits_df <- data.frame( vid = c(visit_id),cid = c(customer_id),rid = c(rid),credit_card = c(cc), vdate = c(formated_date),amount = c(amount),orderedWine = c(orderedWine),num_guests = c(num_guests))
  
  # creating the query
  query <- "insert into visits(vid,cid,rid,cc,vdate,amount,orderedWine,`num.guests`) VALUES"
  
  # inserting values in sql query
  query <- paste0(query, paste(sprintf("(%d,%d,%d,'%s','%s','%s',%s,%d)",
                                       visits_df$vid,visits_df$cid,visits_df$rid,visits_df$credit_card, visits_df$vdate, visits_df$amount,visits_df$orderedWine,visits_df$num_guests), collapse = ","))
  
  print(query)

  dbExecute(mydb, query)  
  
  
  visit_id <- visit_id + 1
  
  customer_id <- customer_id +1

}

  
-------------------------------------------------------------------------------------------------------------

#6 Creating a procedure PopRestFacts
  
procedure <- "
CREATE PROCEDURE PopRestFacts()
BEGIN
  -- Drop all rows in the restaurant_facts table
  DELETE FROM restaurant_facts;
  
  -- calculate number of guests per restaurant per year 
  INSERT INTO restaurant_facts (rid, numGuests, year)
  SELECT rid, sum(`num.guests`) as totalGuests, YEAR(vdate) AS year
  FROM visits
  GROUP BY rid, YEAR(vdate);
END
"

# Execute the stored procedure creation
dbExecute(mydb, procedure)

# Call the stored procedure
dbExecute(mydb, "CALL PopRestFacts()")







                           




                           
                                

