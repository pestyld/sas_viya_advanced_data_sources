/*************************************************************************************************
 CREATE A SERIES OF CSV FILES IN A SUBDIRECTORY IN THE CASUSER CASLIB
 - Creates a subdirectory named 
**************************************************************************************************
 XXX
**************************************************************************************************/

/******************************************
 Load the sample file into memory in CAS 
******************************************/
proc cas;
	table.loadTable /
		path='WARRANTY_CLAIMS_0117.sashdat', caslib='samples',
        casout={name='warranty_claims', 
                caslib='casuser',
                replace=True};
quit;



/******************************************
 Rename columns to more readable names 
******************************************/
proc cas;
	/* Specify the CAS table */
	castbl = {name='warranty_claims', caslib='casuser'};

	/* Clean up column names */
	table.columnInfo result=ci / table=castbl;
	renameColumns = {};
	do col over ci['ColumnInfo'];
		colName = col['Column'];
		newColName = tranwrd(col['Label'],' ','_');
		renameColumns = renameColumns || {{name=colName, rename=newColName}};
	end;

	/* Rename and drop columns */
    keepColumns = {'Campaign_Type', 'Platform','Trim_Level','Make','Model_Year','Engine_Model',
                   'Vehicle_Assembly_Plant','Claim_Repair_Start_Date', 'Claim_Repair_End_Date'};

	table.alterTable / 
		name=castbl['name'], 
		caslib=castbl['caslib'], 
		columns=renameColumns
		keep=keepColumns;
quit;



/*******************************************************************
 Create a subdirectory in Casuser and save mutliple CSV files in it 
********************************************************************/
proc cas;
	castbl = {name='warranty_claims', caslib='casuser'};

/* Create a subdirectory in the Casuser caslib named csv_file_blogs */
	table.addCaslibSubdir / name = 'casuser', path = 'csv_file_blogs' ;
 
/* Create a CSV file for each year */
	simple.freq result=freq / table=castbl, inputs = 'Model_Year';  /* Find distinct years */
	unique_years =  freq['Frequency'][,'CharVar'];               

/* Create each CAS table in the subdirectory */
	do year over unique_years;
		year = strip(year);
		filter= {where=cats("Model_Year='",year,"'")};
		
		table.save / 
			table=castbl || filter,
			name='csv_file_blogs/warranty_claims_'||year||'.parquet', 
            caslib='casuser', 
            replace=TRUE;
	end;

/* View the sub directory in the Casuser caslib */
	table.fileInfo / allFiles = True, caslib = 'casuser';

/* View all files in the csv_file_blogs subdirectory */
    table.fileInfo / path='csv_file_blogs', caslib='casuser';
quit;

proc cas;
	table.fileInfo / path='csv_file_blogs/warranty_claims_2015.parquet', caslib='casuser';
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