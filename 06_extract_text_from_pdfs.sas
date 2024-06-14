/*************************************************************************************************
 READ PDF FILES INTO CAS
**************************************************************************************************
 Requirements: The folder with the PDF files must be accessible to the CAS server  
 Blog: https://blogs.sas.com/content/sgf/2023/11/08/extract-text-from-a-pdf-file-using-sas-viya/ 
**************************************************************************************************/

/****************************************************
 Folder structure of PDF files                          
*****************************************************
 > Casuser caslib
	> PDF_files (3 sample PDF files)                 
	   -- PDF_Form_1.pdf                              
	   -- PDF_Form_2.pdf                              
	   -- PDF_Form_3.pdf  
	> Other files                                            
****************************************************/


/******************************************
 1. PATH FOR THE WORKSHOP FOLDER      
******************************************/
%getcwd(path)



/********************************************************************
 2. CONNECT TO CAS AND LOAD PDF FILES INTO A CAS TABLE     
	- I have the PDF files located in a subdirectory in the Casuser caslib.
	- You can place the folder anywhere CAS can access. If you place
	  the folder in another location, make a caslib to that folder.
*********************************************************************/

/* Modify the path here to the location of your PDF files if you have them in a different location */
/*caslib my_pdfs path="path-to-folder/PDF_files" subdirs; */

/* View all files in the my_pdfs caslib. 3 PDF files should exist. */
proc casutil;
	list files incaslib='casuser' subdir='PDF_files'; 
quit;


/* Read in all of the PDF files in the caslib as a single CAS table */
/* Each PDF will be one row of data in the CAS table                */
proc casutil;
    load casdata='PDF_files'                     /* For a single PDF file specify the name and extension */
         incaslib='casuser'                      /* The location of the PDF files to load */
         importoptions=(fileType="document"      /* Specify document import options   */
                        fileExtList = 'PDF' 
                        tikaConv=True)   
		 casout='pdf_data' outcaslib='casuser' replace;  /* Specify the output cas table info */
quit;

libname casuser cas caslib='casuser';

/* Preview the new CAS table */
proc print data=casuser.pdf_data(obs=10);
run;



/**************************************************
 Using native CAS Language (CASL) - OPTIONAL     
**************************************************
 The CASUTIL procedure uses the loadTable        
 action through the CAS engine behind the scenes.
 Instead of using CASUTIL you can call the action
 directly. See below.                           
**************************************************/

/* proc cas; */
/* 	table.loadTable / */
/* 		path = "PDF_files",                                */
/*         caslib = 'casuser',            */
/*         importOptions = {               */
/*               fileType = 'DOCUMENT', */
/*               fileExtList = 'PDF', */
/*               tikaConv = TRUE */
/*         }, */
/*         casOut = {                      */
/* 				  name = 'pdf_data',  */
/* 				  caslib = 'casuser',  */
/* 				  replace = True */
/* 		}; */
/*  */
/* 	table.fetch / table={name = 'pdf_data', caslib = 'casuser'}; */
/* quit; */



/*****************************************************************************
 3. CLEAN THE UNSTRUCTURED DATA    
******************************************************************************                                         
 The data is small, so all processing will be done using the SAS9 Compute server.
 No CAS required. For larger files or advanced analytics you might want to use the CAS server
******************************************************************************
 Step 1 - Build some logic to figure out how to clean the unstructured data 
 Step 2 - Finalize the ETL pipeline                                        
******************************************************************************/

/* Step 1 - DEVELOPMENT - figure out the general programming logic to clean the unstructured text */
data work.final_pdf_data;
	set casuser.pdf_data;

	/* Create a large column to hold all text */
	length FormFieldsData $10000;  

	/* Drop unnecessary columns */
	drop path fileType fileDate;

	/* Create a column with just the form entries. They start after the Company Name text */
	firstFormField = 'Company Name:';
	formStartPosition = find(content, firstFormField);

	/* Get form field input only and remove leading/trailing blanks */
	FormFieldsData = strip(substr(content,formStartPosition));

	/* Remove random special characters and whitespace from form entries*/
	FormFieldsData = strip(FormFieldsData);
	FormFieldsData = tranwrd(FormFieldsData,'09'x,''); /* Remove tabs */
	FormFieldsData = tranwrd(FormFieldsData,'0A'x,''); /* Remove carriage return line feed */

	/* Find the first input field: Company Name */
	find_first_form_position = find(FormFieldsData,'Company Name:') + length('Company Name:');
	find_second_form_position = find(FormFieldsData, 'First Name:');
	find_length_of_value = find_second_form_position - find_first_form_position;
	Company = substr(FormFieldsData,find_first_form_position, find_length_of_value);

	/* Find the second input field: First Name */
	find_first_form_position = find(FormFieldsData, 'First Name:') + length('First Name:');
	find_second_form_position = find(FormFieldsData, 'Last Name:');
	find_length_of_value = find_second_form_position - find_first_form_position;
	FirstName = substr(FormFieldsData, find_first_form_position, find_length_of_value);
run;

/* Preview the clean data */
proc print data=work.final_pdf_data;
run;



/***************************************************************************************
 Step 2 - Finalize ETL pipeline (production)                                        
   a. Create user defined function (UDF) to parse each input field to clean up code 
   b. Apply UDF to clean up the unstructure data                                    
****************************************************************************************/

/***********************/
/* a. CREATE UDF       */
/***********************/
proc fcmp outlib=work.funcs.trial;
	function find_pdf_value(formFieldsData $, field_to_find $, next_field $) $;
/*
This function will obtain the text input field between two input objects and return the value as a character

- formFieldsData (char) - The string that contains the text from the PDF
- field_to_find (char) - The name of the first input field object (includes the :)
- next_field (char) - The field to parse the input field to (includes the :)
*/

		/* Find position of the text to obtain */
		find_first_form_position = find(FormFieldsData, field_to_find) + length(field_to_find);
		find_second_form_position = find(FormFieldsData, next_field);
		find_length_of_value = find_second_form_position - find_first_form_position;

		/* Get the PDF input field value */
		length pdf_values $1000;
		pdf_values = substr(FormFieldsData, find_first_form_position, find_length_of_value);
		return(pdf_values);

    endsub;
run;


/***********************/
/* b. CLEAN DATA       */
/***********************/

/* Point to the FCMP function */
options cmplib=work.funcs;

/* Clean the data */
data final_pdf_data;
	set casuser.pdf_data;

	/* Sent length of extract text column */
	length FormFieldsData $10000;

	/* Drop unncessary columns */
	drop fileDate content FormFieldsData path fileType fileSize firstFormField formStartPosition;

	/* Create a column with just the form entries */
	firstFormField = 'Company Name:';
	formStartPosition = find(content, firstFormField);

	/* Get form field input only */
	FormFieldsData = strip(substr(content,formStartPosition));

	/* Remove random special characters and whitespace from form entries*/
	FormFieldsData = strip(FormFieldsData);
	FormFieldsData = tranwrd(FormFieldsData,'09'x,''); /* Remove tabs */
	FormFieldsData = tranwrd(FormFieldsData,'0A'x,''); /* Remove carriage return line feed */

	/* Extract values */
	Date = input(find_pdf_value(FormFieldsData, 'Date:','Group2:'), mmddyy10.); 
	Company_Name = find_pdf_value(FormFieldsData, 'Company Name:', 'First Name:');
	Membership = find_pdf_value(FormFieldsData,'Group2:','Member ID:'); /* Group2: */
	Member_ID = find_pdf_value(FormFieldsData, 'Member ID:','Group3:');
	First_Name = find_pdf_value(FormFieldsData, 'First Name:', 'Last Name:');
	Last_Name = find_pdf_value(FormFieldsData, 'Last Name:', 'Address:');
	Address = find_pdf_value(FormFieldsData, 'Address:', 'City:');
	City = find_pdf_value(FormFieldsData, 'City:','State:');
	State = find_pdf_value(FormFieldsData, 'State:', 'Zip:');
	Zip = find_pdf_value(FormFieldsData, 'Zip:', 'Phone:');
	Phone = find_pdf_value(FormFieldsData, 'Phone:', 'Email:');
	Email = find_pdf_value(FormFieldsData, ' Email:', 'undefined_2:');
	Membership_Status = find_pdf_value(FormFieldsData, 'Group3:','undefined:');         /* Group3: */
	Service_Consulting = find_pdf_value(FormFieldsData, 'undefined:', 'Comments:');     /* undefined: */
	Service_Mentoring = find_pdf_value(FormFieldsData, 'undefined_2:', 'undefined_3:'); /* undefined_2: */
	Service_Live_Training = find_pdf_value(FormFieldsData, 'undefined_3:', 'Date:'); 	/* undefined_3: */
	
	/* Comments is the last value. Find Comments: then read the rest of the text */
	Comments = substr(FormFieldsData,find(FormFieldsData,'Comments:')+length('Comments:'));

	/* Format */
	format Date mmddyy10.;

	/* Add clean labels for Visual Analytics dashboard */
	label
		Company_Name = 'Company Name'
		Member_ID = 'Member ID'
		First_Name = 'First Name'
		Last_Name = 'Last Name'
		Membership_Status = 'Membership Status'
		Service_Consulting = 'Service Consulting'
		Service_Mentoring = 'Service Mentoring'
		Service_Live_Training = 'Service Live Training'
		Comments = 'Customer Comments'
	;
run;

/* Preview the final data */
proc print data=work.final_pdf_data label;
run;



/************************************************************
 Load the file to another location to create a dashboard 
*************************************************************
 Multiple ways to do this:
	- 1. Create the final table in a library that's accessible to the CAS server already, not WORK. This technique is better for larger data.
	- 2. Simply load the SAS7BDAT file to CAS and save it back to disk in any file format you wish.
************************************************************/

/* METHOD 2 - Load to CAS from Compute and save to disk */
proc casutil;
	/* Load file into memory */
	load data=work.final_pdf_data
		 casout='final_pdf_data' outcaslib='casuser' replace;

	/* Save the CAS table as a sashdat (or whatever file you want) in a location CAS can access */
	save casdata='final_pdf_data' incaslib='casuser'
		 casout='final_pdf_data.sashdat' outcaslib='casuser'
		 replace;
quit;
	

/************************************************************
 FIND THE FILE USING SAS VISUAL ANALYTICS AND CREATE A DASHBOARD
 - NOTE: The UI in SAS Viya 3.5 is slightly different then here in Viya 4
*************************************************************