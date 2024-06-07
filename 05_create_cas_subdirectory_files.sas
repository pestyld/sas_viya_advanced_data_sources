/*************************************************************************************************
 CREATE A SERIES OF CSV FILES IN A SUBDIRECTORY IN THE CASUSER CASLIB
 - Creates a subdirectory named multiple_files in the Casuser caslib
 - Creates multiple CSV files
 - Creates multiple parquet files
**************************************************************************************************
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
*****************************************************************************
 Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 SPDX-License-Identifier: Apache-2.0                                       
*****************************************************************************/

%getcwd(path)
%put &=path;

/******************************************
 a. Load the sample file into memory in CAS 
******************************************/
proc casutil;
	load casdata='WARRANTY_CLAIMS_0117.sashdat' incaslib='samples'
		 casout='warranty_claims' outcaslib='casuser' 
		 replace;

	list tables incaslib='casuser';
quit;



/*********************************************************
 b. Rename and drop columns for a smaller, cleaner table
*********************************************************/
proc cas;
	/* Specify the CAS table */
	castbl = {name='warranty_claims', caslib='casuser'};

	/* 
		Clean up column names 
	*/
	table.columnInfo result=ci / table=castbl; /* Obtain column names */
	print ci; /*View results */

	/* Create a list of dictionaries to rename columns using the labels */
	renameColumns = {};
	do col over ci['ColumnInfo'];
		colName = col['Column'];
		newColName = tranwrd(col['Label'],' ','_');
		renameColumns = renameColumns || {{name=colName, rename=newColName}};
	end;
	print renameColumns;/*View results */

	/* Rename and drop columns */
    keepColumns = {'Campaign_Type', 'Platform','Trim_Level','Make','Model_Year','Engine_Model',
                   'Vehicle_Assembly_Plant','Claim_Repair_Start_Date', 'Claim_Repair_End_Date'};

	/* Execute rename */
	table.alterTable / 
		name=castbl['name'], 
		caslib=castbl['caslib'], 
		columns=renameColumns
		keep=keepColumns;

	/* Confirm column names */
	table.columnInfo / table=castbl;

	table.fetch / table=castbl;
quit;



/*******************************************************************
 c. Create a subdirectory in Casuser and save mutliple files in it
    based on each year.
********************************************************************/

/* Create a subdirectory in the Casuser caslib named csv_file_blogs */
proc cas;
	table.addCaslibSubdir / name = 'casuser', path = 'multiple_files';
quit;

/* Confirm subdirectory was created */
proc casutil;
	list files;
quit;


/* Create files in subdirectory */
proc cas;
	/* Load function to save CAS table as flat files */
 	%include "&path/utility/casl_func.sas";

	castbl = {name='warranty_claims', caslib='casuser'};

/* Create a CSV file for each year */
	simple.freq result=freq / table=castbl, inputs = 'Model_Year';  /* Find distinct years */
	unique_years =  freq['Frequency'][,'CharVar'];	
	print unique_years;         

/* Create each csv file in the subdirectory */

	do year over unique_years;
		year = strip(year);
		filter= {where=cats("Model_Year='",year,"'")};
		print filter;

		/* Create csv files */
		create_files(castbl || filter, 'csv');
	end;
quit;



/* View files in the subdirectory */
proc cas;
/* View the sub directory in the Casuser caslib */
	table.fileInfo / caslib = 'casuser';

/* View all files in the multiple_files subdirectory */
    table.fileInfo / path='multiple_files', caslib='casuser';
quit;