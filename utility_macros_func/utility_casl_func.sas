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
		name='csv_file_blogs/warranty_claims_'||year||'.'||fileType, 
		caslib='casuser', 
		replace=TRUE;
end;
	