proc cas;
	function save_multiple_formats(tableName, inputCaslib, filetypes);
/*
Creates a series of flat files based on the specified fileType in the csv_file_blogs subdirectory
named warranty_claims.<file extension>

args:
	tableName (str)  : Specify the CAS table name.
	inputCaslib (str): Specify the input Caslib.
	fileTypes (list) : Specify a list of file extensions you would like to save the CAS table as.
					   Example: {'csv','parquet','sas7bdat','sashdat'}

returns:
	A series of files based on the fileTypes.
*/
		castbl = {name=tableName, caslib=inputCaslib};
	
		/* Save the CAS table as each file type */
		do type over fileTypes;
			/* Create the file name with extension */
			saveFileAs = cats('casl_warranty_claims.',type);
	
			table.save / 
				table=castbl,                       /* Input cas table  */
				name=saveFileAs, caslib='casuser' replace=TRUE;  /* Output cas table */
		end;
	end;




	function create_files(castbl, fileType) ; 
/*
Creates a series of flat files based on the specified fileType in the csv_file_blogs subdirectory
named warranty_claims.<file extension>

args:
	fileType (str): Specify the file type you want to save (CSV, parquet)

returns:
	A series of flat files. One file for each year
*/
		table.save / 
			table=castbl,
			name='multiple_files/warranty_claims_'||year||'.'||fileType, 
			caslib='casuser', 
			replace=TRUE;
end;


/* Make sure to use RUN instead of QUIT */
run;