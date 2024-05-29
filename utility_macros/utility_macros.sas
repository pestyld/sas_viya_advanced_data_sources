%macro showImage(image);
/* 
    The macro renders images in the SAS notebook or SAS results.

    Parameter:
        image - specify the full path and file name within quotes.
*/

    data _null_;
        declare odsout obj();
        obj.image(file:&image);
    run;
%mend;




%macro DeleteSubDirectory();
/* 
    The macro deletes the CSV subdirectory created in this workshop

    Parameter:
        N/A
*/

proc cas;
	table.fileInfo result=fi / caslib='casuser', path='csv_file_blogs';
	listOfFilesDelete = fi['FileInfo'][,'Name'];

	do file over listOfFilesDelete;
		table.deleteSource / caslib='casuser', source=cats('csv_file_blogs/',file);	
	end;
quit;
%mend;

%DeleteSubDirectory()