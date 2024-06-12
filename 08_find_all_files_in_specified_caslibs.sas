
/************************************************************************************
1. First iteration - Loop over specified caslib and check if they exist 
*************************************************************************************/
proc cas;
	/* Create a list of caslib to get files from  */
	exploreCaslibs = {'casuserx','public','samples'}; 


	/* Loop over each caslib name in the list */
	do caslibName over exploreCaslibs;

		/* Upcase caslib name */
		caslibName = upcase(caslibName);

		/* Check if caslib exists */
		print (NOTE): 'Checking if the ' || caslibName || ' exists.';
		table.queryCaslib result=checkCaslib / caslib=caslibName;
		/* Get the boolean value TRUE/FALSE from queryCaslib */
		doesCaslibExist = getvalues(checkCaslib)[1];
		
		/* Execute based on if the caslib was found */
		if doesCaslibExist = FALSE then do;
			print (WARN): caslibName || ' Does not exist. Will skip searching this caslib.';
		end;
		else do;
			print (NOTE): 'Getting files from the caslib: ' || caslibName;
		end;

	end;
quit;




/************************************************************************************
2. Second iteration - Get the files in each caslib and print the results
*************************************************************************************/
proc cas;
	/* Create a list of caslib to get files from  */
	exploreCaslibs = {'casuser', 'casuserx','public','samples'}; 


	/* Loop over each caslib name in the list */
	do caslibName over exploreCaslibs;

		/* Upcase caslib name */
		caslibName = upcase(caslibName);

		/* Check if caslib exists */
		print (NOTE): 'Checking if the ' || caslibName || ' exists.';
		table.queryCaslib result=checkCaslib / caslib=caslibName;
		/* Get the boolean value TRUE/FALSE from queryCaslib */
		doesCaslibExist = getvalues(checkCaslib)[1];
		
		/* Execute based on if the caslib was found */
		if doesCaslibExist = FALSE then do;
			print (WARN): caslibName || ' Does not exist. Will skip searching this caslib.';
		end;
		else do;
			print (NOTE): 'Getting files from the caslib: ' || caslibName;

			/* Get all files from a caslib */
			table.fileInfo result= fi / 
				caslib=caslibName, 
				allfiles=True, 
				kbytes=True;
	
			print fi;
		end;

	end;
quit;









/************************************************************************************
3. third iteration - Create a dictionary with a the caslib name as the key, 
                     and the result table as the value
*************************************************************************************/
proc cas;
	/* Create a list of caslib to get files from  */
	exploreCaslibs = {'casuser', 'casuserx','public','samples'}; 


	/* Loop over each caslib name in the list */
	do caslibName over exploreCaslibs;

		/* Upcase caslib name */
		caslibName = upcase(caslibName);

		/* Check if caslib exists */
		print (NOTE): 'Checking if the ' || caslibName || ' exists.';
		table.queryCaslib result=checkCaslib / caslib=caslibName;
		/* Get the boolean value TRUE/FALSE from queryCaslib */
		doesCaslibExist = getvalues(checkCaslib)[1];
		
		/* Execute based on if the caslib was found */
		if doesCaslibExist = FALSE then do;
			print (WARN): caslibName || ' Does not exist. Will skip searching this caslib.';
		end;
		else do;
			print (NOTE): 'Getting files from the caslib: ' || caslibName;

			/* Get all files from a caslib */
			table.fileInfo result= fi / 
				caslib=caslibName, 
				allfiles=True, 
				kbytes=True;
	
			/* Find the table that is in the dictionary from fileInfo. Compute creates a new column with the calsib name */
			getTable = findTable(fi).compute('Caslib', caslibName);
	
	
			/* Combines each result table into a dictionary, each key holds a table for each caslib */
			/* create dictoinary called myFiles with N number of keys. Each key hodls the tables from fileInfo */
			myFiles[caslibName] = getTable;
		end;
		
	
		print myFiles;
		describe myFiles;
	end;
quit;






/************************************************************************************
4. fourth iteration - Create the final table with all files in the specified caslibs
*************************************************************************************/
proc cas;
	/* Create a list of caslib to get files from  */
	exploreCaslibs = {'casuser', 'casuserx','public','samples'}; 


	/* Loop over each caslib name in the list */
	do caslibName over exploreCaslibs;

		/* Upcase caslib name */
		caslibName = upcase(caslibName);

		/* Check if caslib exists */
		print (NOTE): 'Checking if the ' || caslibName || ' exists.';
		table.queryCaslib result=checkCaslib / caslib=caslibName;
		/* Get the boolean value TRUE/FALSE from queryCaslib */
		doesCaslibExist = getvalues(checkCaslib)[1];
		
		/* Execute based on if the caslib was found */
		if doesCaslibExist = FALSE then do;
			print (WARN): caslibName || ' Does not exist. Will skip searching this caslib.';
		end;
		else do;
			print (NOTE): 'Getting files from the caslib: ' || caslibName;

			/* Get all files from a caslib */
			table.fileInfo result= fi / 
				caslib=caslibName, 
				allfiles=True, 
				kbytes=True;
	
			/* Find the table that is in the dictionary from fileInfo. Compute creates a new column with the calsib name */
			getTable = findTable(fi).compute('Caslib', caslibName);
	
	
			/* Combines each result table into a dictionary, each key holds a table for each caslib */
			/* create dictoinary called myFiles with N number of keys. Each key hodls the tables from fileInfo */
			myFiles[caslibName] = getTable;
		end;
		
	end;

	/* Combine all tables and view  */
	allFiles = combine_tables(myFiles);
	print allFiles;
quit;




/************************************************************************************
5. fifth iteration - Create the final as a SAS data set or other file type
*************************************************************************************/
proc cas;
	/* Create a list of caslib to get files from  */
	exploreCaslibs = {'casuser', 'casuserx','public','samples'}; 


	/* Loop over each caslib name in the list */
	do caslibName over exploreCaslibs;

		/* Upcase caslib name */
		caslibName = upcase(caslibName);

		/* Check if caslib exists */
		print (NOTE): 'Checking if the ' || caslibName || ' exists.';
		table.queryCaslib result=checkCaslib / caslib=caslibName;
		/* Get the boolean value TRUE/FALSE from queryCaslib */
		doesCaslibExist = getvalues(checkCaslib)[1];
		
		/* Execute based on if the caslib was found */
		if doesCaslibExist = FALSE then do;
			print (WARN): caslibName || ' Does not exist. Will skip searching this caslib.';
		end;
		else do;
			print (NOTE): 'Getting files from the caslib: ' || caslibName;

			/* Get all files from a caslib */
			table.fileInfo result= fi / 
				caslib=caslibName, 
				allfiles=True, 
				kbytes=True;
	
			/* Find the table that is in the dictionary from fileInfo. Compute creates a new column with the calsib name */
			getTable = findTable(fi).compute('Caslib', caslibName);
	
	
			/* Combines each result table into a dictionary, each key holds a table for each caslib */
			/* create dictoinary called myFiles with N number of keys. Each key hodls the tables from fileInfo */
			myFiles[caslibName] = getTable;
		end;
		
	end;

	/* Combine all tables and view  */
	allFiles = combine_tables(myFiles);

	/* Save the full table as another file type */

	/* SAS DATA SET */
	saveresult allFiles dataout=work.allFiles;
	
	/* CAS TABLE */
	saveresult allFiles casout='allFiles' caslib='casuser';
quit;


/* View the SAS data set */
proc print data=work.allFiles;
run;








/************************************************************************************
5. Create function and use it
 - You can store the function elsewhere and share it if you want
*************************************************************************************/
proc cas;

	function find_files(exploreCaslibs);
/*
Creates two tables with a list of all files in the specified Caslibs.

args:
	exploreCaslibs (list) : Specify a list of caslibs to search all available files.
					        Example: {'casuser', 'casuserx','public','samples'}

returns:
	A SAS data set in the work library name allFiles.
	A CAS table in the Casuser caslib named allFiles.
*/
	
	
		/* Loop over each caslib name in the list */
		do caslibName over exploreCaslibs;
	
			/* Upcase caslib name */
			caslibName = upcase(caslibName);
	
			/* Check if caslib exists */
			print (NOTE): 'Checking if the ' || caslibName || ' exists.';
			table.queryCaslib result=checkCaslib / caslib=caslibName;
			/* Get the boolean value TRUE/FALSE from queryCaslib */
			doesCaslibExist = getvalues(checkCaslib)[1];
			
			/* Execute based on if the caslib was found */
			if doesCaslibExist = FALSE then do;
				print (WARN): caslibName || ' Does not exist. Will skip searching this caslib.';
			end;
			else do;
				print (NOTE): 'Getting files from the caslib: ' || caslibName;
	
				/* Get all files from a caslib */
				table.fileInfo result= fi / 
					caslib=caslibName, 
					allfiles=True, 
					kbytes=True;
		
				/* Find the table that is in the dictionary from fileInfo. Compute creates a new column with the calsib name */
				getTable = findTable(fi).compute('Caslib', caslibName);
		
		
				/* Combines each result table into a dictionary, each key holds a table for each caslib */
				/* create dictoinary called myFiles with N number of keys. Each key hodls the tables from fileInfo */
				myFiles[caslibName] = getTable;
			end;
			
		end;
	
		/* Combine all tables and view  */
		allFiles = combine_tables(myFiles);
	
		/********************************************
		 Save the full table as another file type
		********************************************/
		/* SAS DATA SET */
		saveresult allFiles dataout=work.allFiles;
		
		/* CAS TABLE */
		saveresult allFiles casout='allFiles' caslib='casuser' replace;

	end;


	find_files({'casuser', 'casuserx','public','samples'});


quit;


/**********************************
 Create an Excel file if you want
**********************************/
/* Get home path */
%let home=%sysget(HOME);

/* Create Excel file in Home */
ods excel file="&home/allfiles.xlsx";

proc print data=work.allFiles;
run;

ods excel close;
