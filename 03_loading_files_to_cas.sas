/****************************************************************************
 DYNAMICALLY LOADING DIFFERENT FILE TYPES TO CAS
*****************************************************************************
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
*****************************************************************************
 Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 SPDX-License-Identifier: Apache-2.0                                       
*****************************************************************************/


/******************************************
 1. PATH FOR THE WORKSHOP FOLDER      
******************************************/
%getcwd(path)
%put &=path;


/**********************************************************
 2. GET A LIST OF FILES IN A CASLIB AND STORE IN A MACRO VARIABLE
***********************************************************/

/* View the name of the output table*/
ods trace on;
proc casutil;
	list files incaslib='casuser';
quit;
ods trace off;


/* Create a SAS table with the files */
ods output FileInfo=work.CasuserFiles;  
proc casutil;
	list files incaslib='casuser';
quit;

/* View the SAS table */
proc print data=work.CasuserFiles;
run;


/* Store the file names that begin wtih casl_warranty_claims in a macro variable */
proc sql noprint;
	select Name
	into :filesToLoad separated by ','
	from work.CasuserFiles
	where Name like 'casl_warranty_claims%';
quit;
%put &=filesToLoad;



/**********************************************************
 3. LOAD A DYNAMIC LIST OF FILES INTO MEMORY IN CAS USING A MACRO  
***********************************************************/


/******************
 a. First iteration
******************/

options mprint;

%macro loadFiles(caslib);

	/* Create a SAS table with the files */
	ods output FileInfo=CasuserFiles;  
	proc casutil;
		list files incaslib=&caslib;
	quit;
	
	/* Store the file names that begin wtih casl_warranty_claims in a macro variable */
	proc sql noprint;
		select Name
		into :filesToLoad separated by ','
		from work.CasuserFiles
		where Name like 'casl_warranty_claims%';
	quit;
	%put NOTE:**********************************************;
	%put NOTE: LIST OF FILES TO LOAD: &=filesToLoad;
	%put NOTE:**********************************************;
	
	/* Count total number of files to load */
	data _null_;
		total_files = countw("&filesToLoad",',');
		call symputx('total_files', total_files);
	run;
	%put NOTE:**********************************************;
	%put NOTE: TOTAL FILES TO LOAD: &=total_files;
	%put NOTE:**********************************************;

	/* Loop over the list of files to load */
	%do file=1 %to &total_files;
		
		/* Pull the file name to load from the list and create CAS table name */
		data _null_;
			/* File to load */
			loadFile = scan("&filesToLoad",&file,',');     
			call symputx('loadFile',loadFile);

			/* CAS table name (replace . with _) */
			casTableName = tranwrd(loadFile,'.','_');      
			call symputx('casTableName',casTableName);
		run;
		%put NOTE:**********************************************;
		%put NOTE:FILE TO LOAD: &=loadFile;
		%put NOTE:CAS TABLE NAME: &=casTableName;
		%put NOTE:**********************************************;

	%end;

%mend;

%loadFiles(caslib="casuser")



/******************
 b. Final macro
******************/

%macro loadFiles(caslib);

	/* Create a SAS table with the files */
	ods output FileInfo=CasuserFiles;  
	proc casutil;
		list files incaslib=&caslib;
	quit;
	
	/* Store the file names that begin wtih casl_warranty_claims in a macro variable */
	proc sql noprint;
		select Name
		into :filesToLoad separated by ','
		from work.CasuserFiles
		where Name like 'casl_warranty_claims%';
	quit;
	
	/* If files found to load, load the files */
	%if %symexist(filesToLoad) %then %do;

		%put NOTE:**********************************************;
		%put NOTE: LIST OF FILES TO LOAD: &=filesToLoad;
		%put NOTE:**********************************************;
	
		/* Count total number of files to delete */
		data _null_;
			total_files = countw("&filesToLoad",',');
			call symputx('total_files', total_files);
		run;
		%put NOTE:**********************************************;
		%put NOTE: TOTAL FILES TO LOAD: &=total_files;
		%put NOTE:**********************************************;
	
		/* Loop over the list of files to delete */
		%do file=1 %to &total_files;
			
			/* Pull the file name to load from the list and create CAS table name */
			data _null_;
				loadFile = scan("&filesToLoad",&file,',');
				casTableName = tranwrd(loadFile,'.','_');
				call symputx('loadFile',loadFile);
				call symputx('casTableName',casTableName);
			run;
			%put NOTE:**********************************************;
			%put NOTE:FILE TO LOAD: &=loadFile;
			%put NOTE:CAS TABLE NAME: &=casTableName;
			%put NOTE:**********************************************;

			/* Load file */
			proc casutil;
				load casdata="&loadFile" incaslib=&caslib 
					 casout="&casTableName" outcaslib=&caslib
					 replace;
			quit;
			
		%end;
	%end;
	%else %do;
		%PUT NOTE:*****************************;
		%put NOTE: NO FILES AVAILABLE TO LOAD;
		%PUT NOTE:*****************************;
	%end;

	/* View all in-memory tables */
	proc casutil;
		list tables incaslib=&caslib;
	quit;
%mend;

%loadFiles(caslib="casuser")



/******************************************
 4. Loading files using CASL     
******************************************/

/* Get list of files */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib; /* Stores the results in a dictionary named files */

	/* View dictionary returned */
	print files;
	describe files;
quit;


/* Get a list of file names */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* Obtain file nams from the dictionary table */
	fileNames = files['FileInfo']                            /* Access the table */
				.where(Name like 'casl_warranty_claims%')    /* Filter for casl_warranty_claims... */
				[,'Name'];                                   /* Select all rows and only the column Name in a list */
	print fileNames;
quit;


/* Loop over each filename and create the CAS table name */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* Obtain file nams from the dictionary table */
	fileNames = files['FileInfo']                            /* Access the table */
				.where(Name like 'casl_warranty_claims%')    /* Filter for casl_warranty_claims... */
				[,'Name'];                                   /* Select all rows and only the column Name in a list */
	
	/* Loop over each file */
	do file over fileNames;

		/* File name */
		print 'FILE NAME: ' || file;
	
		/* CAS table name */
		casTableName = tranwrd(file,'.','_');
		print 'CAS TABLE NAME: ' || casTableName;
	end;
quit;



/* Load each file */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* Obtain file nams from the dictionary table */
	fileNames = files['FileInfo']                            /* Access the table */
				.where(Name like 'casl_warranty_claims%')    /* Filter for casl_warranty_claims... */
				[,'Name'];                                   /* Select all rows and only the column Name in a list */

	/* Load each file */
	if dim(fileNames) > 0 then do;

		do file over fileNames;
			print (NOTE) 'LOADING FILE: ' || file;     /* (NOTE) is not valid in Viya 3.5 */

			casTableName = tranwrd(file,'.','_');
			print (NOTE) 'CAS TABLE NAME: ' || casTableName;

			table.loadTable / 
				path=file, caslib='casuser',  /* File to load */
				casout={name=casTableName,    /* CAS table name */
						caslib='casuser', 
						replace=TRUE};
		end;
	end;
	else;
		print (WARNING) "No files exist in the caslib";
	end;

	/* View in-memory tables */
	table.tableInfo / caslib='casuser';
quit;


/* OPTIONAL - Create a function you can call like the previous example. */