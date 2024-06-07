/*************************************************************************************************
 LOAD A SERIES OF FILES INTO FROM A SUBDIRECTORY INTO A SINGLE CAS TABLE
**************************************************************************************************
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
	- Must run the 05_create_cas_subdirectory_files.sas program to create data
*****************************************************************************
 Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 SPDX-License-Identifier: Apache-2.0                                       
*****************************************************************************/


/****************************************************
 Casuser caslib structure                           
*****************************************************
 > Casuser caslib
	 > multiple_files (subdirectory)                                          
	   -- warranty_claims_2015.csv                                                  
	   -- warranty_claims_2016.csv                               
	   -- warranty_claims_2017.csv                              
	   -- warranty_claims_2018.csv                            
	   -- warranty_claims_2019.csv                                                   
****************************************************/


/******************************************
 1. VIEW SUBDIRECTORY IN THE CASUSER CASLIB     
******************************************/

/* By default you only see the subdirectory */
proc casutil;
	list files incaslib='casuser';
quit;

/* View files in the subdirectory */
proc casutil;
	list files incaslib='casuser' subdir='multiple_files';
quit;



/****************************************************************
 2. LOAD ALL CSV FILES IN A SUBDIRECTORY INTO A SINGLE CAS TABLE   
 Review the following list of requirements:

- The multiFile parameter must be set to true.
- The file names must end with a .csv suffix.
- The CSV files must have the same number of columns and the columns must have the same data type.
****************************************************************/
/* Load a single CSV file */
proc casutil;
	load casdata="multiple_files/warranty_claims_2019.csv" incaslib="casuser"               
		 casout='wc_2019_csv' outcaslib='casuser' replace;   

	list tables incaslib='casuser';
quit;


/* Load all CSV files from a directory in a single step */
proc casutil;
	load casdata="multiple_files" incaslib="casuser"           /* Specify the subdirectory name (multiple_files) and the input caslib name */
		 importoptions=(fileType='CSV',                        /* Specify the import options for the CSV files */
						multifile=TRUE,
                        showFile=TRUE,                         /* Creates a column with the file name */
						showPath=TRUE)                         /* Creates a column name with the path */
		 casout='all_csv_files' outcaslib='casuser' replace;   /* Output cas table information */

	/* View the in-memory table */
	list tables incaslib='casuser';
quit;


/************************** 
 View the new CAS table 
**************************/

/* Create a libref to the caslib using the CAS engine to use SAS code */
libname casuser cas caslib='casuser';

proc print data=casuser.all_csv_files(obs=10);
run;

proc freqtab data=casuser.all_csv_files;
	tables Model_Year path fileName;
quit;


/* Delete a single file in a subdirectory */
proc cas;
	table.deleteSource / source='multiple_files/warranty_claims_2019.csv' caslib='casuser';
quit;

/****************************************************************
 3. DELETE ALL FILES IN SUBDIRECTORY   
- I use CASL here. You can use PROC CASUTIL with a macro program if you prefer
****************************************************************/
proc cas;
	subDirectoryName = 'multiple_files';

	/* Get a list of files in the subdirectory */
	table.fileInfo result=files / 
		caslib='casuser',            /* Caslib */
		path=subDirectoryName;       /* Subdir */

	/* Access the table in the files dictionary and get a list of files */
	fileNamesInSubdirectory = files['FileInfo'][,'Name'];
	print '*******************************';
	print 'Files to delete: ' || fileNamesInSubdirectory;
	print '*******************************';
	/* Delete each file */
	do file over fileNamesInSubdirectory;
		deleteFile = catx('/',subDirectoryName,file);
	
		print '********************************';
		print 'DELETING FILE: ' || deleteFile;
		print '********************************';
		table.deleteSource / source=deleteFile, caslib='casuser' quiet=TRUE;
	end;
quit;