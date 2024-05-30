/****************************************************************************
  CREATE FILES IN THE CASUSER CASLIB FOR DEMONSTRATION                        
*****************************************************************************
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
*****************************************************************************
 Creates the following files in the Casuser caslib
- warranty_claims.sas7bdat
- warranty_claims.csv
- warranty_claims.sashdat
- warranty_claims.parquet
- casl_warranty_claims.sas7bdat
- casl_warranty_claims.csv
- casl_warranty_claims.sashdat
- casl_warranty_claims.parquet
*****************************************************************************
 Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 SPDX-License-Identifier: Apache-2.0                                       
*****************************************************************************/

/******************************************
 1. PATH FOR THE WORKSHOP FOLDER      
******************************************/
%getcwd(path)
%put &=path;



/******************************************
 2. SAS VIYA AND CASLIB OVERVIEW     
******************************************/
/* SAS Viya Overview */
%showImage("&path/images/02_SAS_Viya_Overview.png")

/* Caslib Overview */
%showImage("&path/images/03_caslibs.png")

/* SAS Viya data access */
%showImage("&path/images/04_caslibs_libnames.png")



/******************************************
 2. LOAD A SAMPLE FILE INTO MEMORY (REVIEW)      
******************************************/
/* View all available caslibs */
caslib _all_ list;

/* (Review) Load a sample file into memory in CAS */
proc casutil;
	load casdata='WARRANTY_CLAIMS_0117.sashdat' incaslib='samples'
		 casout='warranty_claims' outcaslib='casuser' 
		 replace;
quit;


/* (Review) Save the CAS table as a csv file */
proc casutil;
	save casdata='warranty_claims' incaslib='casuser' 
		 casout="warranty_claims.csv" outcaslib='casuser'
		 replace;

	list files incaslib='casuser';
quit;



/****************************************************************************
 METHOD 1 - Create a macro program to save the CAS table as a variety of file types 
****************************************************************************/

options mprint;

/* Using the SAS macro language */
%macro create_cas_files(createFileTypes);

	/* Count the total number of items in the list and store in a macro variable */
	data _null_;
		total_n=countw(&createFileTypes,',');
		call symputx('total_n',total_n);
	run;
	%put &=total_n;

	/* Loop over the file types */
	%do i=1 %to &total_n;
	
		data _null_;
			fileType = scan(&createFileTypes,&i,',');
			call symputx('fileType',fileType);
		run;
		%put &=fileType;

		/* Save each file type to casuser */
		proc casutil;
			save casdata='warranty_claims' incaslib='casuser' 
		 		 casout="warranty_claims.&fileType" outcaslib='casuser'
		 		 replace;
		quit;
   	%end;

	/* List all files */
   	proc casutil;
		list files incaslib='casuser';
	quit;
%mend;

%create_cas_files(createFileTypes="csv,parquet,sas7bdat,sashdat")

options nomprint;



/****************************************************************************
 METHOD 2 - Use the CASL language 
****************************************************************************/

/* a. Loop over a list in CASL */
proc cas;
	fileTypes = {'csv','parquet','sas7bdat','sashdat'};
	do type over fileTypes;
		print type;
	end;
quit;


/* b. Create a string variable that holds the file name */
proc cas;
	fileTypes = {'csv','parquet','sas7bdat','sashdat'};
	do type over fileTypes;
		saveFileAs = cats('warranty_claims.',type);
		print saveFileAs;
	end;
quit;


/* c. Save the CAS table as each file type */
proc cas;
	fileTypes = {'csv','parquet','sas7bdat','sashdat'};
	castbl = {name='warranty_claims', caslib = 'casuser'};

	/* Save the CAS table as each file type */
	do type over fileTypes;
		/* Create the file name with extension */
		saveFileAs = cats('casl_warranty_claims.',type);

		table.save / 
			table=castbl,                                    /* Input cas table  */
			name=saveFileAs, caslib='casuser' replace=TRUE;  /* Output cas table */
	end;

	/* View files in the Casuser caslib */
	table.fileInfo / caslib = 'casuser';
quit;


/* 
  d. Create a function for resuse. 
     Functions is in workshop/utility/casl_func.sas
*/
proc cas;
	/* Create the CASL functions */
	%include "&path./utility/casl_func.sas"; 

	/* Execute the function */
	save_multiple_formats('warranty_claims','casuser',{'csv','parquet','sas7bdat','sashdat'});

	/* View files in the Casuser caslib */
	table.fileInfo / caslib = 'casuser';
quit;