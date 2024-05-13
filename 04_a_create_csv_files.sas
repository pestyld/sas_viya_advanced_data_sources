/*************************************************************************************************
 CREATE A SERIES OF CSV FILES IN A SUBDIRECTORY IN THE CASUSER CASLIB
**************************************************************************************************
 XXX
**************************************************************************************************/

/* Load the sample file into memory in CAS */
proc cas;
	table.loadTable /
		path='WARRANTY_CLAIMS_0117.sashdat', caslib='samples',
        casout={name='warranty_claims', 
                caslib='casuser',
                replace=True};
quit;


/* Rename columns to more readable names */ 
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

	table.columnInfo / table=castbl;
quit;