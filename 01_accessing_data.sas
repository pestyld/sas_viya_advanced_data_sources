/****************************************************
 ACCESS BASIC DATA SOURCES USING SAS9                                           
*****************************************************  
> 1. Base SAS Engine  
> 2. CSV File                         
> 3. XLSX Engine                              
> 4. JSON Engine                              
> 5. Database                                                         
*****************************************************/


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
%showImage("&path./images/02_compute_libraries.png")



/**************************
 1. READ SAS TABLES 
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
/* 1 .Import a worksheet from the workbook as a SAS table */
proc import datafile="&path./data/home_equity.xlsx"
            dbms=xlsx
            out=work.import_xlsx;
	sheet='home_equity';
run;

proc print data=work.import_xlsx(obs=10);
run;
proc contents data=work.import_xlsx;
run;



/* 2. Connect directly to the XLSX file using the LIBNAME engine */
/* This method accesses every worksheet in the workbook if it contains multiple worksheets */
/* Enables you to read from and write to the same workbook */

/* Connect to the Excel workbook directly and treat it as a SAS library */
libname myxl xlsx "&path./data/home_equity.xlsx";

proc print data=myxl.home_equity(obs=10);
run;

proc contents data=myxl.home_equity;
run;

/* Write back to the same Excel workbook as a new worksheet */
data myxl.bad_1;          /* Create new worksheet in Excel */
	set myxl.home_equity; /* read from Excel */
	where BAD=1;
run;


/* Create a new XLSX file name home_equity_final.xlsx */
libname outxl xlsx "&path./data/home_equity_final.xlsx";

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

/* View the JSON file */
data _null_;
	viewJSON = jsonpp('jsonfile','log');
run;

/* Use the JSON engine */
libname myjson JSON fileref=jsonfile noalldata;

/* Many JSON files can include a lot of information. This is a simple flat table */                  
proc contents data=myjson._all_;
run;

proc print data=myjson.sastabledata_home_equity(obs=10);
run;

/* Clear the connection to the JSON file */
libname myjson clear;



/********************************
 5. READ DATABASE DATA
*********************************/
/* add code */



/* CLASSES */
/* SAS® Programming Methods to Read, Process, and Write Database Tables - https://learn.sas.com/course/view.php?id=139 */
/* Efficiency Tips for Database Programming in SAS® - https://learn.sas.com/course/view.php?id=136 */