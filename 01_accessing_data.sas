/****************************************************************************
 ACCESS BASIC DATA SOURCES USING SAS9 ON SAS VIYA (REVIEW)                                          
*****************************************************************************  
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
*****************************************************************************
> 1. Base SAS Engine  
> 2. CSV File                         
> 3. XLSX Engine                              
> 4. JSON Engine                              
> 5. Database                                                         
****************************************************************************/


/**********************************************
 SET PATH TO WORKSHOP ROOT FOLDER
 Dynamically finds the current working folder.
**********************************************/
%getcwd(path)
%put &=path;



/*******************************************************************************************
 LIBNAME Engines           
********************************************************************************************
 - The SAS LIBNAME engine is a common interface into accessing different data sources 
 - Example: libname <library reference name> <engine to use> <connection information>; 
********************************************************************************************/
/* SAS Viya Overview */
%showImage("&path/images/02_SAS_Viya_Overview.png")

/* SAS Compute Libraries (SAS9) */
%showImage("&path./images/01_compute_libraries.png")



/**************************
 1. READ SAS TABLES (review)
**************************/
libname mydata "&path./data";

/* Preview the data (like the Python head method) */
proc print data=mydata.home_equity(obs=10);
run;

/* View column metadata (df.dtypes, df.shape) */
proc contents data=mydata.home_equity;
run;

/* CLASS */
/* SAS® Programming 1: Essentials - https://learn.sas.com/course/view.php?id=118 */



/**********************
 2. IMPORT CSV FILE    
**********************/
/* Import the home_equity.csv file as a SAS table */
/* Creates the DATA step code to read the CSV file. You can copy/paste and modify it if necessary */
proc import datafile="&path./data/home_equity.csv"
            dbms=csv
            out=work.import_csv;
	guessingrows=max; /* MAX scans all rows. Not efficient for large data. Default scan 20 rows. */
run;

proc print data=work.import_csv(obs=10);
run;

/* CLASS */
/* SAS® Programming 1: Essentials - https://learn.sas.com/course/view.php?id=118 */



/**************************
 3. READ EXCEL FILES  
 - 2 methods       
**************************/
/* 3a. Imports a single worksheet at a time from the workbook and creates SAS table */
proc import datafile="&path./data/home_equity.xlsx"
            dbms=xlsx
            out=work.import_xlsx;
	sheet='home_equity';
run;

proc print data=work.import_xlsx(obs=10);
run;
proc contents data=work.import_xlsx;
run;



/* 3b. XLSX Engine: Connect directly to the XLSX file using the LIBNAME engine */
/* - Treats the Excel workbook as a SAS library */
/* - This method accesses every worksheet in the workbook, even if it contains multiple worksheets */
/* - Enables you to read from and write to the same (or different) workbook */

/* Connect to the Excel workbook directly and treat it as a SAS library */
libname myxl xlsx "&path./data/home_equity.xlsx";

/* View the Excel worksheet(s) through the library without creating a SAS table */
proc print data=myxl.home_equity(obs=10);
run;

proc contents data=myxl.home_equity;
run;

/* Write back to the same Excel workbook as a new worksheet */
data myxl.bad_1;          /* Create new worksheet in Excel */
	set myxl.home_equity; /* read from Excel */
	where BAD=1;
run;


/* Create a new Excel file named home_equity_good_loans.xlsx using engine */
libname outxl xlsx "&path./data/home_equity_good_loans.xlsx";

data outxl.bad_0;         /* Create new worksheet in a new Excel workbook */
	set myxl.home_equity; /* read from Excel */
	where BAD=0;
run;


/* Close Excel connectionS */
libname outxl clear;
libname myxl clear;

/* CLASSES */
/* SAS® Programming 1: Essentials - https://learn.sas.com/course/view.php?id=118        */
/* Working with SAS® and Microsoft Excel - https://learn.sas.com/course/view.php?id=688 */



/**************************
 4. READ JSON FILES        
**************************/
/* Reference the JSON file */
filename jsonfile "&path./data/home_equity.json";

/* Use the JSON engine */
libname myjson JSON fileref=jsonfile noalldata;

/* Many JSON files can include a lot of information. This is a simple flat table */                  
proc print data=myjson.sastabledata_home_equity(obs=10);
run;

/* Clear the connection to the JSON file */
libname myjson clear;



/********************************
 5. READ DATABASE DATA (SNOWFLAKE)
*********************************/

/*
 GET AUTHORIZATION INFORMATION
*/
%let home = %SYSGET(HOME);

/* Specify the credentials JSON file */
filename myauth "&home/keys/snow_creds.json";

/* Read the JSON file into SAS */
libname myauth json fileref=myauth;

/* Create variables to store the authentication information */
data _NULL_;
    set myauth.root;
    call symputx('account_url',account_url);
    call symputx('user_name', userName);
    call symputx('password',password);
run;

/* Clear the connection to the JSON file */
libname myauth clear;



/*
 CONNECT TO SNOWFLAKE
*/
options nonotes;
libname snowssd SNOW server="&account_url"
                     user="&user_name"
                     password="&password"
                     warehouse=users_wh
                     database=SNOWFLAKE_SAMPLE_DATA
                     schema=TPCH_SF10;
option notes;




/* View extra information in the log when working with an external database */
options sastrace=',,,d' sastraceloc=saslog nostsuffix sql_ip_trace=note;

/* Simple SQL query and log exploration */
proc sql;
SELECT *
FROM snowssd.PART(obs=10);
quit;

proc sql;
SELECT count(*) format=comma16. AS TOTAL_ROWS
FROM snowssd.PART;
quit;


/* Run in-database procedure to streamline your code and limit data movement */
proc freq data=snowSSD.PART order=freq;
	tables P_MFGR P_BRAND / plots=freqplot;
run;

/* Disconnect from Snowflake */
libname snowssd clear;


/* CLASSES */
/* SAS® Programming Methods to Read, Process, and Write Database Tables - https://learn.sas.com/course/view.php?id=139 */
/* Efficiency Tips for Database Programming in SAS® - https://learn.sas.com/course/view.php?id=136 */