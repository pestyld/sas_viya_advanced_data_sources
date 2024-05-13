/****************************************************
 ACCESS DATA SOURCES USING SAS                                           
*****************************************************  
> 1. Base SAS Engine  
> 2. CSV File                         
> 3. XLSX Engine                              
> 4. JSON Engine                              
> 5. Postgres Engine                                                         
*****************************************************/


/**********************************************
 SET PATH TO WORKSHOP ROOT FOLDER
 Dynamically finds the current working folder.
**********************************************/
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));
%put &=path;

/* Create utility macros */
%include "&path./utility_macros/utility_macros.sas";



/*******************************************************************************************
 LIBNAME Engines           
********************************************************************************************
 - The SAS LIBNAME engine is a common interface into accessing different data sources 
 - Example: libname <library reference name> <engine to use> <connection information>; 
********************************************************************************************/
%showImage("&path./images/WellsFargo SAS Viya Workshop.png")



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
/* Import the home_equity.csv file as a SAS table (pd.read_csv) */
proc import datafile="&path./data/home_equity.csv"
            dbms=csv
            out=work.import_csv;
	guessingrows=max;
run;

proc print data=work.import_csv(obs=10);
run;

/* CLASS */
/* SAS® Programming 1: Essentials - https://learn.sas.com/course/view.php?id=118 */



/**************************
 3. READ XLSX FILES        
**************************/

/* Read an XLSX file */
libname myxl xlsx "&path./data/home_equity.xlsx";

proc print data=myxl.home_equity(obs=10);
run;

proc contents data=myxl.home_equity;
run;


/* Create a new XLSX file name home_equity_final.xlsx */
libname outxl xlsx "&path./data/home_equity_final.xlsx";

data outxl.bad_0;         /* Create new worksheet in Excel */
	set myxl.home_equity; /* read from Excel */
	where BAD=0;
run;

data outxl.bad_1;         /* Create new worksheet in Excel */
	set myxl.home_equity; /* read from Excel */
	where BAD=1;
run;

/* Close Excel connection */
libname outxl clear;

/* Clear the connection to the input Excel file */
libname myxl clear;

/* CLASSES */
/* SAS® Programming 1: Essentials - https://learn.sas.com/course/view.php?id=118        */
/* Working with SAS® and Microsoft Excel - https://learn.sas.com/course/view.php?id=688 */



/**************************
 4. READ JSON FILES        
**************************/
/* Reference the JSON file (import json) */
filename jsonfile "&path./data/home_equity.json";
/* Use the JSON engine */
libname myjson JSON fileref=jsonfile;

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