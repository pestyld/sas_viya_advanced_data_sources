/****************************************************************************
 CREATE DEMONSTRATION DATA FOR SAS COMPUTE SERVER                          
*****************************************************************************
 Creates the following files in the workshop/data folder
- cars.sas7bdat
- home_equity.csv
- home_equity.json
- home_equity.sas7bdat
- home_equity.xlsx
- us_data.sas7bdat
*****************************************************************************
 REQUIREMENTS: SAS VIYA MUST BE ENABLED TO DOWNLOAD DATA FROM THE INTERNET  
*****************************************************************************
 Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 SPDX-License-Identifier: Apache-2.0                                       
*****************************************************************************/


/******************************************/
/* FIND PATH FOR THE PROJECT FOLDER       */
/******************************************/

/* REQUIRED: Specify the location in your explorer where you want to create the data */
%getcwd(datapath)

/* Confirm the path is as expected */
%put &=datapath;

/* Create library */
libname mydata "&datapath";


%include "&datapath./01_create_flat_data.sas";

