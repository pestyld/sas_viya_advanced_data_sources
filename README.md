# Advanced Data Source Techniques with the SAS Viya Platform

Macro programs and code provided as is. 

## Requirements
- Access to SAS Viya.

## Duration
- About 3 hours

## Description
In this workshop, participants will learn a comprehensive set of dynamic techniques for accessing and manipulating data from various sources, as well as performing data engineering tasks in the SAS Viya Platform. 

Here's a breakdown of the key topics covered:

1. **Accessing Compute Server (SAS9) Data Sources**: Participants gained proficiency in accessing data from diverse sources including CSV, Excel, JSON, SAS7BDAT, and Snowflake database, leveraging the power of SAS9.

> Program: 01_accessing_data.sas

2. **Dynamic File Creation in CAS using Macro and CASL**: Through practical exercises, attendees learned to dynamically generate files within the CAS environment using macros and CASL (CAS Language).

**NOTE:** This will create a series of files in your **Casuser** caslib.

> Program: 02_create_casuser_files.sas

3. **Dynamic File Loading into CAS Memory**: A crucial aspect of efficient data processing, participants acquired skills to dynamically load files into memory within the CAS environment, enhancing data manipulation capabilities.

> Program: 03_loading_files_to_cas.sas

4. **Dynamic Data Source File Deletion in Caslib**: Understanding the importance of data management, participants mastered techniques to dynamically delete data source files within Caslib using macros and CASL.

**NOTE:** This will delete the created files specifically for this workshop. it will delete files starting with casl_warranty_claims% and warranty_claims%.

> Program: 04_delete_files_in_caslib.sas

5. **Consolidation of CSV Files into a Single CAS Table**: A hands-on session enabled attendees to merge multiple CSV files from Caslib into a unified CAS table, facilitating streamlined data analysis.

> Program: 05_create_cas_subdirectory_files.sas

> Program: 05b_create_cas_subdirectory_files.sas - Creates the data for the main program.

6. **PDF Forms Text Extraction**: Participants were equipped with the knowledge and tools to extract text from PDF forms, enabling them to unlock valuable insights from unstructured data.

**NOTE:** The PDFs must be in a location accessible to the CAS server.

> Program: 06_extract_text_from_pdfs.sas


7. **Locating Data Source Files in Specified Caslibs**: Through practical demonstrations, participants learned dynamica methods to locate and document all data source files within the specified Caslibs to create a structured table for reporting and governance.


## Setup (REQUIRED)
1. You will need to run the **utility_macros.sas** program from the **utility** folder to create the necessary macro programs for the workshop.

## Workshop Notes
Most of the this workshop should run in your SAS Viya environment as is. Based on your setup there will be a few modifications required.
1. To connect to Snowflake you will have to use your own connection information (or other database).
2. When working with PDF files in program **07_extract_text_from_pdfs.sas**, they will need to be placed in a location that CAS can access. Notes are in the program to help guide you.


## Folder descriptions

### data
Contains the data used in the **01_accessing_data.sas** program for traditional SAS data source connections using the Compute server. 

### images 
Contains images that are displayed throughoug the workshop to help visualize the architecture.

### PDF_Files
Contains 3 PDF files that you will use in **07_extract_text_from_pdfs.sas**. Depending on your enviornment you will have to copy this folder to a location CAS can access if it can't access it by default.

### utility
Contains two programs:
- **casl_func.sas** - Series of CASL functions that are called from a PROC CAS.
- **utility_macros.sas** - Series of SAS macro programs used in this workshop.