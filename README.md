In this practicum you will build a database that can be used to analyze restaurant visits. Using data collected by a Point-of-Sale System (POS) for a restaurant group and made available in several CSV files, you will build a logical data model and from that a normalized relational schema with an implementation of the database in MySQL. In addition, you will load data from the CSV files into the database, execute SQL queries, implement a stored procedure, a finally perform some simple analysis of the data.

Use the provided time estimates for each tasks to time-box your time. Seek assistance if you spend more time than specified on a task -- you are likely not solving the problem correctly. A key objective is to learn how to look things up, how to navigate complex problems, and how to identify and resolve programming errors.

Learning Objectives
In this practicum you will learn how to:

configure cloud MySQL
connect to MySQL from R in an R Notebook
implement a relational schema for an existing data set
load data from CSV files into a relational database through R
execute SQL queries against a MySQL/MariaDB database through R
perform simple analytics in R
identify and resolve programming errors
look up details for R, SQL, and MySQL/MariaDB
time-box work
Format
Complete in pairs or individually; working in pairs is not required. We do not pair up students; finding a partner is the student's responsibility.
Add both team members as authors to the submission in all code files and in the submission comments, but only one person needs to make a submission. Both team members will receive the same grade.
If a team member is not contributing, the other team member may simply quit and continue individually using all work done up to that point. It is expected that both team members do an equal amount of work of similar complexity. You must write a submission comment explaining who you worked with, when you started working together, when you split, and why.
A pair = two members in a team, that means two and no more than two; working in a group of three is not a pair and is not allowed.
Prerequisite Tasks
Read the Hints and Tips section below and go back to them often when you encounter problem. Most problems are addressed in that section. Consult the list before contacting us for help as you'll be able to resolve the issue more quickly.
Create an R Project. If you work in a pair, add both last names to all file names and all headers.
Download these CSV Data Files to your local project folder:
synthsalestxns-Jan2Mar.csvLinks to an external site.
synthsalestxns-Sep2Oct.csvLinks to an external site.
synthsalestxns-Nov2Dec.csvLinks to an external site.
In the final code that you submit, the CSV files must be loaded from their URL.
You may wish to create a new data file that is a subset of the full data that you use for development so loading takes less time. This is a common strategy in practice. 
Read the Hints & Tips section frequently and before posting questions.

Tasks
Before you start, read all of the questions. Inspect one of the CSV data files that you downloaded so you are familiar with its columns, data types, and overall structure. Assume that this database will eventually be used for an app that can be used by analysts to analyze restaurant visits, perhaps for the purpose of market expansion, marketing campaigns, or planning. 

Use functions to structure your code so that it becomes more readable and easier to develop and debug. Follow common coding practices and format your code so it is readable, and use functions to break down complex code.

(5 pts / 2 hrs) Set up and configure a MySQL Server database on either freemysqlhosting.netLinks to an external site. (recommended) or db4free.netLinks to an external site.. Note that you may use SQLite instead of MySQL but you will not get credit for this question nor credit for the question below that asks you to create a stored procedure, as those are not supported in SQLite.

(3 pts / 0.1 hrs) Create an R Program (not an R Notebook) with the name pattern LastNameF.CS5200.Su1.P1.Load2DB.R. If you work in a pair, add both last names to the file name. Add a header comment with the title "Loading of Restaurant Database",  and an author comment with your name(s), and a date comment with "Summer 1 2023".

Add code to connect to your cloud MySQL database using the instructions in Lesson 6.304 -- Configure and Connect to Cloud MySQL from RLinks to an external site.. If you have difficulty connecting to or setting up a remote MySQL database, then use SQLite and proceed. You can always come back to this question and change your configuration so that you connect to MySQL. This is the benefit of relational databases: you can easily switch between databases without changing your code.

(15 pts / 2 hrs) In your R program, use R functions to create the database schema described below. Add appropriate constraints, plus primary key and foreign key definitions. In the schema definitions below, primary keys are underlined and foreign keys are bolded. Create an ERD to help you visualize the tables (but no need to submit the diagram).

(5 pts / 0.5 hrs) Create a table restaurants that stores information about restaurants with this schema:

restaurants (rid : integer,
                     name : text, date.opened : date,
                     max.capacity : integer ≥ 0,
                     cuisine : {...},
                     isOpen: boolean)

The column max.capacity should be restricted to positive integers. The column cuisine should be restricted to specific values (use a value set definition and not a lookup table). For now, make the column cuisine of type 'text' or 'varchar'; later we will refine that to using a lookup table. There is no information about a restaurant's cuisine in the provided CSV files. Set a default value of "American" and set the cuisine to "Italian" for Ninita, "Continental Spanish" for Olga's.

Make isOpen a Boolean flag and use TRUE if the restaurant is open, FALSE otherwise. Use appropriate data types for the columns and store any date as a date type not as text (subject to the data types the database supports). If date or boolean are not supported, choose another data type that will work or split the dates into month, day, and year columns. Note that some columns contain periods so that will require special treatment in SQL -- investigate how to deal with this common issue.

(3 pts / 0.5 hrs) Create a table that stored customer information called customers and that follows this schema:

customers (cid : integer, cname : text, cphone : text)

(5 pts / 0.5 hrs) Create a table that stores information about visits to restaurants called visits and that follows this schema:

visits (vid : integer, cid : integer, rid : integer, cc : text, vdate : date, amount : numeric > 0, orderedWine : boolean, num.guests : integer > 0)

vid is a synthetic primary key, cc is the credit card number, vdate is the date of the visit. Additional columns should be self-explanatory based on the CSV. cid and rid are foreign keys linking a visit to a customer and a restaurant, respectively.

(2 pts / 0.5 hrs) Create a lookup table called cuisine defined as follows:

cuisine (zid, type, comments)

Link this lookup table to the restaurants table through the cuisine column. This table contains the values of all cuisines, e.g., 'Italian', etc.. Leave the comments column empty (future expansion). Use the information provided in (A) and modify the table definition for (A).

(20 pts / 4 hrs) Using the table definitions and the data from the CSV files, populate the tables with the data from the appropriate columns. You do not need to create any additional tables. Because we are not adding additional tables there will be (unnormalized) data and repetitions, for example for credit card number -- that is acceptable for this practicum due to time constraints but would not be if this were an actual analytics database project. The restaurants table will contain information about the restaurants, extracted from the CSV -- but obviously it is a unique set of restaurants and not just the column "name" from the CSV. Same for the other tables: you are breaking the large table of the CSV into smaller, normalized, tables.

Add functions to your program to structure your code; internal structure, clarity, and readability are essential and are part of this question's grade.

See the Hints below for information on db4free if you have problems using dbWriteTable(). All data manipulation and importing work must occur in R. You may not modify the original data outside of R -- that would not be reproducible work. It may be helpful to create a subset of the data for development and testing as the full file is quite large and takes time to load.

(10 pts / 1 hr) Create a table called restaurant_facts that follows this schema:

restaurant_facts (rid : integer, numGuests : integer, year : integer)

(10 pts / 2 hrs) Write a stored procedure called "PopRestFacts()" that drops all rows in the "restaurant_facts" table (making it empty) and then uses the data from the transactional tables to calculate the number of guests for each restaurant per year. So, there is one row per restaurant per year. Call the stored procedure from R to set up the fact table. If you are not able to write a stored procedure, then write an R program instead that populates the "restaurant_facts" table so you can complete the questions below.

(2 pts / 10 min) Create a (new) R Notebook with the name pattern LastNameF.CS5200.Su1.P1.Report.Rmd. If you work in a pair, add both last names to the file name. Set the title meta parameter of the notebook to "Analysis of Restaurant Visits", author to your name(s), and date to "Summer 1 2023". Connect to your database in an {R} chunk.

(5 pts / 10 min) Add two level three headers (##) called "Executive Summery", "Data", and "Discussion".

(10 pts / 1 hr) In the section "Data", display a table containing the number of visits and number of guests per restaurant. Use the appropriate R and SQL code to accomplish this analytics query.

(10 pts / 1 hr) In the section "Discussion", add the following narrative, substituting the correct calculated values in the _____ blanks -- but do not hardcode any values -- make sure they are automatically updated with data from the database when the notebook is knitted. You need to write appropriate SQL and R code to find the correct values -- let your creativity shine.

______ had the most overall visits, while _____ had the most guests. _____ was the year where we saw the most visits to our restaurants.

(5 pts / 1 hr) Knit the notebook to a PDF. If you cannot knit the notebook to PDF locally, upload your code to rstudio.cloud and knit there.

(5 pts) Professionally developed code in both the program and the notebook that is well documented, contains appropriate functions and code comments, and where all notebook chunks are labeled.
Hints and Tips
Ask clarifying questions in the Assignments channel on Teams.
If you find it helpful, draw an ERD, but you do not have to submit the ERD.
Ask questions as soon as you encounter them.
While you need to look up details for functions and R, the solution cannot be found via Google.
Do not spend extraordinary time on code errors; ask for help if you cannot resolve them within 30-minutes. First through the Assignment channel on Teams and then by going to TA office hours -- the TAs will alert the instructor if there are doubts they cannot resolve.
If you have trouble connecting, be sure to disable any firewall or anti-virus software that may be clocking port 3306 -- or add port 3306 to the list of open ports in your firewall software configuration.
The function dbWriteTable() is disabled for bulk loading on the MySQL cloud installation on db4free. 
Be sure to click the activation link in the email from db4free.net after you create your database; if you get "Access denied..." error messages then you did not activate your account.
If you use sqldf for manipulating or querying internal data frames, be mindful of conflicts between SQLite and MySQL; see mysql - How to use sqldf in R to manipulate local dataframes? - Stack Overflow.Links to an external site. A potential issue with sqldf can occur when you connect to MySQL or a non-SQLite database as sqldf attempts to use your existing database connection as a backing store for its data; this will often not work due to security constraints. So, you need to add the R code options(sqldf.driver = 'SQLite') which forces sqldf to use SQLite as its backing store.
sqldf is very slow for querying or extracting data from a data frame as it actually copies the data frame to an in-memory SQLite database and then runs a SQL query; so, only use sqldf is there's no simple way to do a native R "query" with logical operations and which() and any(), e.g., use sqldf to do grouping but not much else
If you get errors connecting to MySQL, make sure you have the latest version of R and upgrade R and all packages as necessary.
Using mixed upper and lower case for table names sometimes causes issues with dbSendStatement() and dbWriteTable() when using MySQL; make all table names and attributes names fully lower case; SQL is not case sensitive when it comes to keywords like INSERT vs insert BUT it is when it comes to table and attribute names
Put columns that contain special character such as period (.) or have names that are keywords into backticks, e.g., SELECT `condition` FROM incidents;
If you get a message "Can't initialize character set unknown", see https://stackoverflow.com/questions/52613809/rmysql-error-cant-initialize-character-set-unknownLinks to an external site. and https://github.com/pBlueG/SA-MP-MySQL/issues/203Links to an external site.
There appears to be a bug in MySQL stored procedures that contain a SELECT as the last statement in the procedure; if you get the message "Commands out of sync; you can't run this command now", you must use INTO with your SELECT; see https://stackoverflow.com/questions/6583020/mysql-stored-procedure-caused-commands-out-of-syncLinks to an external site.
All your work must be within your R Notebook; we will run your R Notebook against one of our MySQL servers with a blank database (or SQLite if that's what you used) and it has to run from beginning to end; so if you did work outside of your R Notebook then we cannot reproduce your work you'll get a grade of 0.
Before submitting, test that you code runs and your Notebook knits in a clean environment. So, remove all objects first by either including this code in the beginning of your R Notebook rm(list = ls()) or by clearing your environment in R Studio with the menu item Session/Clear Workspace.
Explain your approaches and any manipulations, omissions, deletions, or modifications of data.
Be sure to install packages within your code (but only if not installed) to ensure they get installed when the graders run your code. Here's an elegant way to do this: https://statsandr.com/blog/an-efficient-way-to-install-and-load-r-packages/Links to an external site.
In R, if you want to change a global variable (one used first outside a function), then you need to use a special assignment operator: <<- instead of <-. 
If your data frames are not written to the database when you use dbWriteTable() then check to see if your data frame contains columns of type date -- there may be issues in converting R dates to SQL dates; for more information on this, see Lesson 6.306 Dates in R and SQLiteLinks to an external 
