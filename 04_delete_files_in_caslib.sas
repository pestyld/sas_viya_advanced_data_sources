/**************************************************************************** 
 DYNAMICALLY DELETING FILES IN A CASLIB
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


/******************************************
 2. Store the name of the files      
******************************************/
libname casuser cas caslib='casuser';

/* View the name of the output table*/
ods trace on;
proc casutil;
	list files incaslib='casuser';
quit;
ods trace off;

/* Create a SAS table with the files */
ods output FileInfo=CasuserFiles;  
proc casutil;
	list files incaslib='casuser';
quit;

/* Store the file names that begin wtih casl_warranty_claims in a macro variable */
proc sql noprint;
	select Name
	into :filesToDelete separated by ','
	from work.casuserFiles
	where Name like 'casl_warranty_claims%';
quit;
%put &=filesToDelete;



/******************************************
 3. Delete files using a SAS macro      
******************************************/


/******************
 First iteration
******************/

options mprint;
%macro deleteFiles(caslib);

	/* Create a SAS table with the files */
	ods output FileInfo=CasuserFiles;  
	proc casutil;
		list files incaslib=&caslib;
	quit;
	
	/* Store the file names that begin wtih casl_warranty_claims in a macro variable */
	proc sql noprint;
		select Name
		into :filesToDelete separated by ','
		from work.casuserFiles
		where Name like 'casl_warranty_claims%';
	quit;
	%put &=filesToDelete;
	
	/* Count total number of files to delete */
	data _null_;
		total_files = countw("&files",',');
		call symputx('total_files', total_files);
	run;
	%put &=total_files;

	/* Loop over the list of files to delete */
	%do file=1 %to &total_files;
		
		/* Pull the file name to delete from the list */
		data _null_;
			delFile = scan("&filesToDelete",&file,',');
			call symputx('delFile',delFile);
		run;
		%put &=delFile;
	%end;

%mend;


%deleteFiles(caslib="casuser")






/******************
 Final macro
******************/

/* Delete a file */
proc casutil;
	deletesource casdata="warranty_claims.parquet" incaslib="casuser" quiet;
	list files incaslib="casuser";
quit;



options mprint;
%macro deleteFiles(caslib);

	/* Create a SAS table with the files */
	ods output FileInfo=CasuserFiles;  
	proc casutil;
		list files incaslib=&caslib;
	quit;
	
	/* Store the file names that begin wtih casl_warranty_claims in a macro variable */
	proc sql noprint;
		select Name
		into :filesToDelete separated by ','
		from work.casuserFiles
		where Name like 'casl_warranty_claims%';
	quit;

	/* If files found to delete, delete the files */
	%if %symexist(filesToDelete) %then %do;
		%put NOTE:**********************************************;
		%put NOTE: LIST OF FILES TO DELETE: &=filesToDelete;
		%put NOTE:**********************************************;

		/* Count total number of files to delete */
		data _null_;
			total_files = countw("&files",',');
			call symputx('total_files', total_files);
		run;
		%put NOTE: Total files to delete: &=total_files;
	
		/* Loop over the list of files to delete */
		%do file=1 %to &total_files;
			
			/* Pull the file name to delete from the list */
			data _null_;
				delFile = scan("&filesToDelete",&file,',');
				call symputx('delFile',delFile);
			run;
			%put NOTE: File to delete: &=delFile;
	
			/* Delete file */
			proc casutil;
				deletesource casdata="&delFile" incaslib=&caslib quiet;
			quit;
		%end;
	
		/* List files */
		proc casutil;
			list files incaslib=&caslib;
		quit;
	%end;
	%else %do;
		%PUT NOTE:*****************************;
		%put NOTE: NO FILES FOUND TO DELETE;
		%PUT NOTE:*****************************;
	%end;
%mend;


%deleteFiles(caslib="casuser")



/******************************************
 4. Delete files using CASL     
******************************************/

/* Get list of files */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* View dictionary returned */
	print files;
	describe files;
quit;


/* Get a list of file names */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* Obtain file nams from the dictionary table */
	fileNames = files['FileInfo'][,'Name'];
	print fileNames;
quit;


/* Loop over each filename */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* Obtain file nams from the dictionary table */
	fileNames = files['FileInfo'][,'Name'];
	
	/* Loop over each file */
	do file over fileNames;
		print file;
	end;
quit;


/* Delete each file */
proc cas;
	searchCaslib = 'casuser';
	table.fileInfo result=files / caslib=searchCaslib;

	/* Obtain file nams from the dictionary table */
	fileNames = files['FileInfo'][,'Name'];
	
	/* Delete each file */
	if exists(fileNames) = 1 then do;
		do file over fileNames;
			print (NOTE) 'DELETING FILE: ' || file;     /* (NOTE) is not valid in Viya 3.5 */
			table.deleteSource / source=file, caslib='casuser';
		end;
	end;
	else;
		print (NOTE) "No files exist";
	end;
quit;