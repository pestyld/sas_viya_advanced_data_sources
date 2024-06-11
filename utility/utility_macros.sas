/*********************************************************
 UTILITY MACROS
*********************************************************/



/******************************************
 FIND PATH FOR THE PROJECT FOLDER    
******************************************/
/* 
	Dynamically finds the current directory path based on where the program is saved and stores it in 
    the path macro variable. Valid in SAS Studio.  

    Parameter:
        variable - specify the name of the macro variable you want to use. No quotes.
*/
%macro getcwd(variable);
	%global &variable;

	%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
	%let current_path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

	%let &variable=&current_path;
	
	%let &variable=&current_path;
	%PUT NOTE: *****************************************************;
	%PUT NOTE: Current directory path: &current_path;
	%PUT NOTE: *****************************************************;

%mend;






/******************************************
 DISPLAY IMAGE
******************************************/
/* 
    The macro renders images in the SAS notebook or SAS results.

    Parameter:
        image - specify the full path and file name within quotes.
*/
%macro showImage(image);

    data _null_;
        declare odsout obj();
        obj.image(file:&image);
    run;
%mend;




/* 
    The macro deletes the CSV subdirectory created in this workshop

    Parameter:
        fileDirectory (str): Specify the subdirectory to delete
*/
%macro DeleteSubDirectory(fileDirectory='multiple_files');

proc cas;
	table.fileInfo result=fi / caslib='casuser', path=&fileDirectory;
	listOfFilesDelete = fi['FileInfo'][,'Name'];

	do file over listOfFilesDelete;
		table.deleteSource / caslib='casuser', source=cats(&fileDirectory,'/',file) quiet=TRUE;	
	end;
	
	table.deleteSource / source = &fileDirectory, caslib = 'casuser' quiet=TRUE;
	
quit;
%mend;