/*******************************************************************************/
/*  CREATE DEMONSTRATION DATA                                                  */
/*******************************************************************************/
/* REQUIREMENTS: SAS VIYA MUST BE ENABLED TO DOWNLOAD DATA FROM THE INTERNET   */
/*******************************************************************************/
/*  Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved. */
/*  SPDX-License-Identifier: Apache-2.0                                        */
/*******************************************************************************/


/******************************************/
/* FIND PATH FOR THE PROJECT FOLDER       */
/******************************************/
/* REQUIRED: Specify the location in your explorer where you want to create the data */
/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path macro variable. Valid in SAS Studio.  */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let datapath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

/* Confirm the path is as expected */
%put &=datapath;


/******************************************/
/* CREATE FOLDER                          */
/******************************************/
/* Create data folder in your SAS environment within this project */
options dlcreatedir;
libname mydata "&datapath";



/*****/
/* 1 */
/***************************************************/
/* DOWNLOAD DATA FROM THE INTERNET                 */
/***************************************************/
/* Run this program to load the home_equity.csv    */
/* to download the CSV file from the SAS Viya      */
/* examples website                                */
/***************************************************/

 /* Read the home_equity.csv sample data from the SAS Support Example Data website */
filename data "&datapath./home_equity.csv";
proc http 
   method="GET" 
   url="https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/home_equity.csv" 
   out=data;
run;



/************************/
/* CREATE SAS7BDAT FILE */
/************************/
/*  Import home_equity.csv and create DATA.HOME_EQUITY */
proc import file="data"
			dbms=csv 
			out=mydata.home_equity replace;
    guessingrows=max;
run;

/* Clean up labels and formats */
proc datasets lib=mydata memtype=data nolist;
    modify home_equity;
    label APPDATE="Loan Application Date"
          BAD="Loan Status"
          CITY="City"
          CLAGE="Age of Oldest Credit Line (months)"
          CLNO="Number of Credit Lines"
          DEBTINC="Debt to Income Ratio"
          DELINQ="Number of Delinquent Credit Lines"
          DEROG="Number of Derogatory Reports"
          DIVISION="Division"
          JOB="Job Category"
          LOAN="Amount of Loan Request"
          MORTDUE="Amount Due on Existing Mortgage"
          NINQ="Number of Recent Credit Inquiries"
          REASON="Loan Purpose"
          REGION="Region"
          STATE="State"
          VALUE="Value of Current Property"
          YOJ="Years at Present Job";
    format APPDATE date9.
           CLAGE comma8.1
           LOAN MORTDUE VALUE dollar12.
           DEBTINC 8.1
           BAD CITY CLNO DELINQ DEROG DIVISION JOB NINQ REASON REGION STATE YOJ;
    attrib _all_ informat=;
run;

/* Clear downloaded file */
filename data clear;


/************************/
/* CREATE XLSX FILE     */
/************************/
proc export data=mydata.home_equity 
			dbms=xlsx 
			outfile="&datapath./home_equity.xlsx";
run;


/************************/
/* CREATE JSON FILE     */
/************************/
proc json out="&datapath./home_equity.json" pretty;
   export mydata.home_equity;
run;


/********************************/
/* CREATE ADDITIONAL SAS TABLES */
/********************************/
data mydata.us_data;
	set sashelp.us_data;
run;

data mydata.cars;
	set sashelp.cars;
run;

libname mydata clear;









/*  Load the HOME_EQUITY into memory in the CASUSER caslib. */
/*  Save HOME_EQUITY.sashdat in the CASUSER caslib so it is saved on disk.  */
/*  */
/* cas mysession; */
/* proc casutil; */
/*     droptable casdata="home_equity" incaslib="casuser" quiet; */
/*     load data=work.home_equity outcaslib="casuser" casout="home_equity"; */
/*     save casdata="home_equity" incaslib="casuser" casout="home_equity" outcaslib="casuser" replace; */
/*     list files incaslib="casuser"; */
/* quit; */
/* cas mysession terminate; */