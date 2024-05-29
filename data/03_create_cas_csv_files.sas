/*************************************************************************************************
 CREATE A SERIES OF CSV FILES IN A SUBDIRECTORY IN THE CASUSER CASLIB
 - Creates a subdirectory named 
**************************************************************************************************
 XXX
**************************************************************************************************/

/******************************************
 a. Load the sample file into memory in CAS 
******************************************/
proc casutil;
	load casdata='WARRANTY_CLAIMS_0117.sashdat' incaslib='samples'
		 casout='warranty_claims' outcaslib='casuser' 
		 replace;
quit;



/******************************************
 b. Rename and drop columns for a smaller, cleaner table
******************************************/
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
	castbl = {name='warranty_claims', caslib='casuser'};

/* Create a CSV file for each year */
	simple.freq result=freq / table=castbl, inputs = 'Model_Year';  /* Find distinct years */
	unique_years =  freq['Frequency'][,'CharVar'];	
	print unique_years;         

/* Create each parquet/csv file in the subdirectory */

	/* Load function to save CAS table as flat files */
 	myFunctions = readpath("&path/utility_macros_func/utility_casl_func.sas");
	execute(myFunctions);

	do year over unique_years;
		year = strip(year);
		filter= {where=cats("Model_Year='",year,"'")};
		print filter;
		/* Create parquet/csv files */
		create_files(castbl || filter, 'parquet');
		create_files(castbl || filter, 'csv');
	end;

/* View the sub directory in the Casuser caslib */
	table.fileInfo / allFiles = TRUE, caslib = 'casuser';

/* View all files in the csv_file_blogs subdirectory */
    table.fileInfo / path='multiple_files', caslib='casuser';
quit;


proc cas;
	table.fileInfo / path='multiple_files', caslib='casuser';
quit;




proc cas;
	castbl = {name='warranty_claims', caslib='casuser'};
	year = '2019';
	
	
	print castbl || filter;
quit;


quit;



    for year in list(castbl.Model_Year.unique()):      
        (cas_table_reference
         .query(f"Model_Year ='{year}'")
         .save(name = f'csv_file_blogs/warranty_claims_{year}.csv', 
               caslib = 'casuser',
               replace = True)
        )
 
    ## Drop the CAS Table
    cas_table_reference.dropTable()
 
    ## View files in the csv_file_blogs subdirectory
    fi = conn.fileInfo(allFiles = True, caslib = 'casuser')
    fi_subdir = conn.fileInfo(path = 'csv_file_blogs', caslib = 'casuser')
    display(fi, fi_subdir)